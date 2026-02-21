#include "game_logic.h"
#include "core/buff_runtime.h"
#include "core/achievement_rules.h"
#include "core/choice_runtime.h"
#include "core/game_rules.h"
#include "core/level_runtime.h"
#include "adapter/ghost_store.h"
#include "adapter/level_applier.h"
#include "adapter/level_loader.h"
#include "adapter/level_script_runtime.h"
#include "adapter/ui_action.h"
#include "adapter/input_semantics.h"
#include "fsm/states.h"
#include "profile_manager.h"
#include <QCoreApplication>
#include <QRandomGenerator>
#include <QDateTime>
#include <QJSValue>
#include <QAccelerometer>
#include <QDebug>
#ifdef Q_OS_ANDROID
#include <QJniObject>
#include <QtCore/qnativeinterface.h>
#endif
#include <algorithm>
#include <array>
#include <cmath>

using namespace Qt::StringLiterals;

namespace {
    constexpr int InitialInterval = 200;
    constexpr int BuffDurationTicks = 40; 

    auto rollWeightedPowerUp(QRandomGenerator &rng) -> GameLogic::PowerUp {
        // Lower Mini probability while keeping other fruits reasonably common.
        static constexpr std::array<std::pair<GameLogic::PowerUp, int>, 9> weightedTable{{
            {GameLogic::Ghost, 3},
            {GameLogic::Slow, 3},
            {GameLogic::Magnet, 3},
            {GameLogic::Shield, 3},
            {GameLogic::Portal, 3},
            {GameLogic::Double, 3},
            {GameLogic::Rich, 2},
            {GameLogic::Laser, 2},
            {GameLogic::Mini, 1}
        }};
        int totalWeight = 0;
        for (const auto &item : weightedTable) {
            totalWeight += item.second;
        }
        int pick = rng.bounded(totalWeight);
        for (const auto &item : weightedTable) {
            if (pick < item.second) {
                return item.first;
            }
            pick -= item.second;
        }
        return GameLogic::Ghost;
    }

    auto stateName(int state) -> const char * {
        switch (state) {
            case GameLogic::Splash: return "Splash";
            case GameLogic::StartMenu: return "StartMenu";
            case GameLogic::Playing: return "Playing";
            case GameLogic::Paused: return "Paused";
            case GameLogic::GameOver: return "GameOver";
            case GameLogic::Replaying: return "Replaying";
            case GameLogic::ChoiceSelection: return "ChoiceSelection";
            case GameLogic::Library: return "Library";
            case GameLogic::MedalRoom: return "MedalRoom";
            default: return "Unknown";
        }
    }
}

GameLogic::GameLogic(QObject *parent)
    : QObject(parent),
      m_rng(QRandomGenerator::securelySeeded()),
      m_timer(std::make_unique<QTimer>()),
      m_accelerometer(std::make_unique<QAccelerometer>()),
      m_profileManager(std::make_unique<ProfileManager>()),
      m_fsmState(nullptr) {

    connect(m_timer.get(), &QTimer::timeout, this, &GameLogic::update);

    connect(this, &GameLogic::foodEaten, this, [this](float pan) -> void {
        emit audioSetScore(m_score);
        emit audioPlayBeep(880, 100, pan);
        triggerHaptic(3);
    });

    connect(this, &GameLogic::powerUpEaten, this, [this]() -> void {
        emit audioPlayBeep(1200, 150, 0.0f);
        triggerHaptic(6);
    });

    connect(this, &GameLogic::playerCrashed, this, [this]() -> void {
        emit audioPlayCrash(500);
        triggerHaptic(12);
    });

    connect(this, &GameLogic::uiInteractTriggered, this, [this]() -> void {
        emit audioPlayBeep(200, 50, 0.0f);
        triggerHaptic(2);
    });

    connect(this, &GameLogic::stateChanged, this, [this]() -> void {
        qInfo().noquote() << "[AudioFlow][GameLogic] stateChanged ->"
                          << stateName(m_state) << "(musicEnabled=" << m_musicEnabled << ")";
        if (m_state == StartMenu) {
            const int token = m_audioStateToken;
            QTimer::singleShot(650, this, [this, token]() -> void {
                if (token != m_audioStateToken) {
                    qInfo().noquote() << "[AudioFlow][GameLogic] menu BGM deferred start canceled by token";
                    return;
                }
                if (m_state == StartMenu && m_musicEnabled) {
                    qInfo().noquote() << "[AudioFlow][GameLogic] emit audioStartMusic (menu)";
                    emit audioStartMusic();
                }
            });
        } else if (m_state == Playing || m_state == Replaying) {
            if (m_musicEnabled) {
                qInfo().noquote() << "[AudioFlow][GameLogic] emit audioStartMusic (playing/replaying)";
                emit audioStartMusic();
            }
        } else if (m_state == Splash || m_state == GameOver) {
            qInfo().noquote() << "[AudioFlow][GameLogic] emit audioStopMusic (splash/gameover)";
            emit audioStopMusic();
        }
    });

    if (m_accelerometer) {
        m_accelerometer->setDataRate(30);
        connect(m_accelerometer.get(), &QAccelerometer::readingChanged, this, [this]() -> void {
            if (!m_accelerometer || !m_accelerometer->reading()) {
                return;
            }
            constexpr qreal MaxTilt = 6.0;
            const qreal nx = std::clamp(m_accelerometer->reading()->y() / MaxTilt, -1.0, 1.0);
            const qreal ny = std::clamp(m_accelerometer->reading()->x() / MaxTilt, -1.0, 1.0);
            m_reflectionOffset = QPointF(nx * 0.02, -ny * 0.02);
            m_hasAccelerometerReading = true;
            emit reflectionOffsetChanged();
        });
        m_accelerometer->start();
        QTimer::singleShot(200, this, [this]() -> void {
            if (!m_accelerometer) {
                return;
            }
            qInfo().noquote() << "[SensorFlow][GameLogic] accelerometer connected="
                              << m_accelerometer->isConnectedToBackend()
                              << "active=" << m_accelerometer->isActive();
        });
    }

    m_snakeModel.reset({{10, 10}, {10, 11}, {10, 12}});
}

GameLogic::~GameLogic() {
    if (m_accelerometer) {
        m_accelerometer->stop();
    }
    if (m_timer) {
        m_timer->stop();
    }
    m_fsmState.reset();
}

// --- IGameEngine Implementation ---

void GameLogic::setInternalState(int s) {
    auto next = static_cast<State>(s);
    if (m_state != next) {
        qInfo().noquote() << "[StateFlow][GameLogic] setInternalState:"
                          << stateName(m_state) << "->" << stateName(next);
        m_state = next;
        m_audioStateToken++;
        emit audioSetPaused(m_state == Paused || m_state == ChoiceSelection || m_state == Library ||
                            m_state == MedalRoom);
        emit stateChanged();
    }
}

void GameLogic::requestStateChange(int newState) {
    if (m_stateCallbackInProgress) {
        qInfo().noquote() << "[StateFlow][GameLogic] defer requestStateChange to"
                          << stateName(newState) << "(inside callback)";
        m_pendingStateChange = newState;
        return;
    }
    qInfo().noquote() << "[StateFlow][GameLogic] requestStateChange ->" << stateName(newState);

    auto s = static_cast<State>(newState);
    switch (s) {
        case Splash:
            changeState(std::make_unique<SplashState>(*this));
            break;
        case StartMenu: 
            changeState(std::make_unique<MenuState>(*this)); 
            break;
        case Playing:   
            changeState(std::make_unique<PlayingState>(*this)); 
            break;
        case Paused:    
            changeState(std::make_unique<PausedState>(*this)); 
            break;
        case GameOver:  
            changeState(std::make_unique<GameOverState>(*this)); 
            break;
        case Replaying: 
            changeState(std::make_unique<ReplayingState>(*this)); 
            break;
        case ChoiceSelection: 
            changeState(std::make_unique<ChoiceState>(*this)); 
            break;
        case Library: 
            changeState(std::make_unique<LibraryState>(*this)); 
            break;
        case MedalRoom: 
            changeState(std::make_unique<MedalRoomState>(*this)); 
            break;
        default: 
            break;
    }
}

auto GameLogic::hasSave() const -> bool {
    if (m_profileManager) {
        return m_profileManager->hasSession();
    }
    return false;
}

auto GameLogic::hasReplay() const noexcept -> bool {
    return !m_bestInputHistory.isEmpty();
}

auto GameLogic::checkCollision(const QPoint &head) -> bool {
    const snakegb::core::CollisionOutcome outcome = snakegb::core::collisionOutcomeForHead(
        head, BOARD_WIDTH, BOARD_HEIGHT, m_obstacles, m_snakeModel.body(), m_activeBuff == Ghost,
        m_activeBuff == Portal, m_activeBuff == Laser, m_shieldActive);

    if (outcome.consumeLaser && outcome.obstacleIndex >= 0 && outcome.obstacleIndex < m_obstacles.size()) {
        m_obstacles.removeAt(outcome.obstacleIndex);
        m_activeBuff = None;
        emit obstaclesChanged();
        triggerHaptic(8);
        emit buffChanged();
    }
    if (outcome.consumeShield) {
        m_shieldActive = false;
        triggerHaptic(5);
        emit buffChanged();
    }
    return outcome.collision;
}

void GameLogic::handleFoodConsumption(const QPoint &head) {
    const QPoint p = snakegb::core::wrapPoint(head, BOARD_WIDTH, BOARD_HEIGHT);

    if (p != m_food) {
        return;
    }

    const int points = snakegb::core::foodPointsForBuff(static_cast<snakegb::core::BuffId>(m_activeBuff));

    const int previousScore = m_score;
    m_score += points;
    if (m_profileManager) {
        m_profileManager->logFoodEaten();
    }

    float pan = (static_cast<float>(p.x()) / BOARD_WIDTH - 0.5f) * 1.4f;
    emit foodEaten(pan);

    m_timer->setInterval(normalTickIntervalMs());
    emit scoreChanged();
    spawnFood();

    if (shouldTriggerRoguelikeChoice(previousScore, m_score)) {
        m_lastRoguelikeChoiceScore = m_score;
        if (m_state == Replaying) {
            generateChoices();
        } else {
            requestStateChange(ChoiceSelection);
        }
    } else if (m_rng.bounded(100) < 15 && m_powerUpPos == QPoint(-1, -1)) {
        spawnPowerUp();
    }

    triggerHaptic(std::min(5, 2 + (m_score / 10)));
}

void GameLogic::handlePowerUpConsumption(const QPoint &head) {
    const QPoint p = snakegb::core::wrapPoint(head, BOARD_WIDTH, BOARD_HEIGHT);

    if (p != m_powerUpPos) {
        return;
    }

    m_activeBuff = m_powerUpType;
    applyAcquiredBuffEffects(static_cast<int>(m_activeBuff), BuffDurationTicks, true, true);

    m_powerUpPos = QPoint(-1, -1);

    emit powerUpEaten();
    if (m_activeBuff == Slow) {
        m_timer->setInterval(250);
    }

    triggerHaptic(5);
    emit buffChanged();
    emit powerUpChanged();
}

void GameLogic::applyMovement(const QPoint &newHead, bool grew) {
    const QPoint p = snakegb::core::wrapPoint(newHead, BOARD_WIDTH, BOARD_HEIGHT);
    
    m_snakeModel.moveHead(p, grew);
    m_currentRecording.append(p);

    if (m_ghostFrameIndex < static_cast<int>(m_bestRecording.size())) {
        m_ghostFrameIndex++;
        emit ghostChanged();
    }
    applyMagnetAttraction();
    checkAchievements();
}

void GameLogic::restart() {
    m_direction = {0, -1};
    m_inputQueue.clear();
    m_score = 0;
    m_activeBuff = None;
    m_buffTicksRemaining = 0;
    m_buffTicksTotal = 0;
    m_shieldActive = false;
    m_powerUpPos = QPoint(-1, -1);
    m_choicePending = false;
    m_choiceIndex = 0;
    
    m_randomSeed = static_cast<uint>(QDateTime::currentMSecsSinceEpoch());
    m_rng.seed(m_randomSeed);
    m_gameTickCounter = 0;
    m_ghostFrameIndex = 0;
    m_lastRoguelikeChoiceScore = -1000;
    m_currentInputHistory.clear();
    m_currentRecording.clear();
    m_currentChoiceHistory.clear();
    
    loadLevelData(m_levelIndex);
    m_snakeModel.reset(buildSafeInitialSnakeBody());
    clearSavedState();
    
    m_timer->setInterval(InitialInterval);
    m_timer->start();
    spawnFood();
    
    emit buffChanged();
    emit powerUpChanged();
    emit scoreChanged();
    emit foodChanged();
    requestStateChange(Playing);
}

void GameLogic::startReplay() {
    if (m_bestInputHistory.isEmpty()) {
        return;
    }
    
    setInternalState(Replaying);
    m_currentRecording.clear();
    m_direction = {0, -1};
    m_inputQueue.clear();
    m_score = 0;
    m_activeBuff = None;
    m_buffTicksRemaining = 0;
    m_buffTicksTotal = 0;
    m_shieldActive = false;
    m_powerUpPos = QPoint(-1, -1);
    
    loadLevelData(m_bestLevelIndex);
    m_snakeModel.reset(buildSafeInitialSnakeBody());
    m_rng.seed(m_bestRandomSeed);
    m_gameTickCounter = 0;
    m_ghostFrameIndex = 0;
    m_lastRoguelikeChoiceScore = -1000;
    m_timer->setInterval(InitialInterval);
    m_timer->start();
    spawnFood();
    
    emit scoreChanged();
    emit foodChanged();
    emit ghostChanged();
    changeState(std::make_unique<ReplayingState>(*this));
}

void GameLogic::loadLastSession() {
    if (!m_profileManager || !m_profileManager->hasSession()) {
        return;
    }

    auto data = m_profileManager->loadSession();
    m_score = data[u"score"_s].toInt();
    m_food = data[u"food"_s].toPoint();
    m_direction = data[u"dir"_s].toPoint();
    m_obstacles.clear();

    for (const auto &v : data[u"obstacles"_s].toList()) {
        m_obstacles.append(v.toPoint());
    }

    std::deque<QPoint> body;
    for (const auto &v : data[u"body"_s].toList()) {
        body.emplace_back(v.toPoint());
    }

    m_snakeModel.reset(body);
    m_inputQueue.clear();
    m_currentInputHistory.clear();
    m_currentRecording.clear();
    m_currentChoiceHistory.clear();
    m_lastRoguelikeChoiceScore = -1000;
    m_activeBuff = None;
    m_buffTicksRemaining = 0;
    m_buffTicksTotal = 0;
    m_shieldActive = false;

    for (const auto &p : body) {
        m_currentRecording.append(p);
    }

    m_timer->setInterval(normalTickIntervalMs());
    m_timer->start();

    emit scoreChanged();
    emit foodChanged();
    emit obstaclesChanged();
    emit ghostChanged();
    requestStateChange(Paused);
}

void GameLogic::togglePause() {
    if (m_state == Playing) {
        requestStateChange(Paused);
    } else if (m_state == Paused) {
        requestStateChange(Playing);
    }
}

void GameLogic::nextLevel() {
    const int levelCount = snakegb::adapter::readLevelCountFromResource(u"qrc:/src/levels/levels.json"_s, 6);
    m_levelIndex = (m_levelIndex + 1) % levelCount;
    loadLevelData(m_levelIndex);
    if (m_state == StartMenu && hasSave()) {
        clearSavedState();
    }
    emit levelChanged();
    if (m_profileManager) {
        m_profileManager->setLevelIndex(m_levelIndex);
    }
}

void GameLogic::startEngineTimer(int intervalMs) {
    if (intervalMs > 0) {
        m_timer->setInterval(intervalMs);
    }
    m_timer->start();
}

void GameLogic::stopEngineTimer() {
    m_timer->stop();
}

void GameLogic::triggerHaptic(int magnitude) { 
    emit requestFeedback(magnitude);
#ifdef Q_OS_ANDROID
    QJniObject context = QNativeInterface::QAndroidApplication::context();
    if (context.isValid()) {
        QJniObject vibrator = context.callObjectMethod(
            "getSystemService", 
            "(Ljava/lang/String;)Ljava/lang/Object;", 
            QJniObject::fromString("vibrator").object<jstring>()
        );
        if (vibrator.isValid()) {
            jlong duration = static_cast<jlong>(magnitude * 12);
            vibrator.callMethod<void>("vibrate", "(J)V", duration);
        }
    }
#endif
}

void GameLogic::playEventSound(int type, float pan) {
    qInfo().noquote() << "[AudioFlow][GameLogic] playEventSound type=" << type << " pan=" << pan;
    if (type == 0) {
        emit foodEaten(pan);
    } else if (type == 1) {
        emit playerCrashed();
    } else if (type == 2) {
        emit uiInteractTriggered();
    } else if (type == 3) {
        emit audioPlayBeep(1046, 140, 0.0f);
    }
}

void GameLogic::updatePersistence() {
    updateHighScore();
    if (m_profileManager) {
        m_profileManager->incrementCrashes();
    }
    clearSavedState();
}

void GameLogic::lazyInit() {
    if (m_profileManager) {
        m_levelIndex = m_profileManager->levelIndex();
        emit audioSetVolume(m_profileManager->volume());
    }

    snakegb::adapter::GhostSnapshot snapshot;
    if (snakegb::adapter::loadGhostSnapshot(snapshot)) {
        m_bestRecording = snapshot.recording;
        m_bestRandomSeed = snapshot.randomSeed;
        m_bestInputHistory = snapshot.inputHistory;
        m_bestLevelIndex = snapshot.levelIndex;
        m_bestChoiceHistory = snapshot.choiceHistory;
    }

    loadLevelData(m_levelIndex);
    spawnFood();
    emit paletteChanged();
    emit shellColorChanged();
}

void GameLogic::lazyInitState() {
    if (!m_fsmState) {
        changeState(std::make_unique<SplashState>(*this));
    }
}

void GameLogic::generateChoices() {
    m_choices.clear();

    const QList<snakegb::core::ChoiceSpec> allChoices = snakegb::core::pickRoguelikeChoices(m_rng.generate(), 3);
    for (const auto &choice : allChoices) {
        QVariantMap m;
        m.insert(u"type"_s, choice.type);
        m.insert(u"name"_s, choice.name);
        m.insert(u"desc"_s, choice.description);
        m_choices.append(m);
    }
    emit choicesChanged();
}

void GameLogic::selectChoice(int index) {
    if (index < 0 || index >= m_choices.size()) {
        return;
    }
    
    if (m_state != Replaying) {
        m_currentChoiceHistory.append({.frame=m_gameTickCounter, .index=index});
    }
    
    int type = m_choices[index].toMap().value(u"type"_s).toInt();
    m_lastRoguelikeChoiceScore = m_score;
    m_activeBuff = static_cast<PowerUp>(type);
    applyAcquiredBuffEffects(type, BuffDurationTicks * 2, false, true);

    emit buffChanged();
    if (m_state == Replaying) {
        m_timer->setInterval(normalTickIntervalMs());
        return;
    }

    m_timer->setInterval(500);

    QTimer::singleShot(500, this, [this]() -> void {
        if (m_state == Playing) {
            m_timer->setInterval(normalTickIntervalMs());
        }
    });

    requestStateChange(Playing);
}

// --- QML API ---

void GameLogic::dispatchUiAction(const QString &action) {
    using snakegb::adapter::UiActionKind;
    const snakegb::adapter::UiAction uiAction = snakegb::adapter::parseUiAction(action);

    switch (uiAction.kind) {
        case UiActionKind::NavUp:
            move(0, -1);
            break;
        case UiActionKind::NavDown:
            move(0, 1);
            break;
        case UiActionKind::NavLeft:
            move(-1, 0);
            break;
        case UiActionKind::NavRight:
            move(1, 0);
            break;
        case UiActionKind::Primary:
        case UiActionKind::Start:
            handleStart();
            break;
        case UiActionKind::Secondary:
            handleBAction();
            break;
        case UiActionKind::SelectShort:
            handleSelect();
            break;
        case UiActionKind::Back:
            switch (snakegb::adapter::resolveBackActionForState(static_cast<int>(m_state))) {
                case snakegb::adapter::BackAction::QuitToMenu:
                    quitToMenu();
                    break;
                case snakegb::adapter::BackAction::QuitApplication:
                    quit();
                    break;
                case snakegb::adapter::BackAction::None:
                    break;
            }
            break;
        case UiActionKind::ToggleShellColor:
            nextShellColor();
            break;
        case UiActionKind::ToggleMusic:
            toggleMusic();
            break;
        case UiActionKind::QuitToMenu:
            quitToMenu();
            break;
        case UiActionKind::Quit:
            quit();
            break;
        case UiActionKind::NextPalette:
            nextPalette();
            break;
        case UiActionKind::DeleteSave:
            deleteSave();
            break;
        case UiActionKind::StateStartMenu:
            requestStateChange(StartMenu);
            break;
        case UiActionKind::StateSplash:
            requestStateChange(Splash);
            break;
        case UiActionKind::FeedbackLight:
            triggerHaptic(1);
            break;
        case UiActionKind::FeedbackUi:
            triggerHaptic(5);
            break;
        case UiActionKind::FeedbackHeavy:
            triggerHaptic(8);
            break;
        case UiActionKind::SetLibraryIndex:
            setLibraryIndex(uiAction.value);
            break;
        case UiActionKind::SetMedalIndex:
            setMedalIndex(uiAction.value);
            break;
        case UiActionKind::Unknown:
            break;
    }
}

void GameLogic::move(int dx, int dy) {
    dispatchStateCallback([dx, dy](GameState &state) -> void { state.handleInput(dx, dy); });

    if (m_state == Playing && m_inputQueue.size() < 2) {
        QPoint last = m_inputQueue.empty() ? m_direction : m_inputQueue.back();
        if (((dx != 0) && last.x() == -dx) || ((dy != 0) && last.y() == -dy)) {
            return;
        }
        m_inputQueue.emplace_back(dx, dy);
        emit uiInteractTriggered();
    }
}

void GameLogic::nextPalette() {
    if (m_profileManager) {
        int nextIdx = (m_profileManager->paletteIndex() + 1) % 5;
        m_profileManager->setPaletteIndex(nextIdx);
        emit paletteChanged();
        emit uiInteractTriggered();
    }
}

void GameLogic::nextShellColor() {
    if (m_profileManager) {
        int nextIdx = (m_profileManager->shellIndex() + 1) % 7;
        m_profileManager->setShellIndex(nextIdx);
        emit shellColorChanged();
        emit uiInteractTriggered();
    }
}

void GameLogic::handleBAction() {
    // Unified semantics:
    // - Active gameplay states: secondary visual action (palette cycle)
    // - Navigation/overlay states: back to menu
    // - Menu root: palette cycle (quit uses Back/Esc)
    if (m_state == Playing || m_state == ChoiceSelection) {
        nextPalette();
        return;
    }

    if (m_state == StartMenu) {
        nextPalette();
        return;
    }

    if (m_state == Paused || m_state == GameOver || m_state == Replaying ||
        m_state == Library || m_state == MedalRoom) {
        quitToMenu();
    }
}

void GameLogic::quitToMenu() {
    if (m_state == Playing || m_state == Paused || m_state == ChoiceSelection) {
        saveCurrentState();
    }
    requestStateChange(StartMenu);
}

void GameLogic::toggleMusic() {
    m_musicEnabled = !m_musicEnabled;
    qInfo().noquote() << "[AudioFlow][GameLogic] toggleMusic ->" << m_musicEnabled;
    emit audioSetMusicEnabled(m_musicEnabled);
    if (m_musicEnabled && m_state != Splash) {
        emit audioStartMusic();
    } else if (!m_musicEnabled) {
        emit audioStopMusic();
    }
    emit musicEnabledChanged();
}

void GameLogic::quit() {
    if (m_state == Playing || m_state == Paused || m_state == ChoiceSelection) {
        saveCurrentState();
    }
    QCoreApplication::quit();
}

void GameLogic::handleSelect() {
    if (m_state == StartMenu) {
        nextLevel();
        return;
    }
    dispatchStateCallback([](GameState &state) -> void { state.handleSelect(); });
}

void GameLogic::handleStart() {
    dispatchStateCallback([](GameState &state) -> void { state.handleStart(); });
}

void GameLogic::deleteSave() {
    clearSavedState();
    // Clearing save should also reset level selection to default.
    m_levelIndex = 0;
    if (m_profileManager) {
        m_profileManager->setLevelIndex(m_levelIndex);
    }
    loadLevelData(m_levelIndex);
    emit levelChanged();
}

// --- Property Getters ---

auto GameLogic::highScore() const -> int {
    return m_profileManager ? m_profileManager->highScore() : 0;
}

auto GameLogic::palette() const -> QVariantList {
    static const QList<QVariantList> p = {
        {u"#cadc9f"_s, u"#8bac0f"_s, u"#306230"_s, u"#0f380f"_s},
        {u"#e0e8d0"_s, u"#a0a890"_s, u"#4d533c"_s, u"#1f1f1f"_s},
        {u"#ffd700"_s, u"#e0a000"_s, u"#a05000"_s, u"#201000"_s},
        {u"#00ffff"_s, u"#008080"_s, u"#004040"_s, u"#002020"_s},
        {u"#ff0000"_s, u"#a00000"_s, u"#500000"_s, u"#200000"_s}
    };
    int idx = m_profileManager ? m_profileManager->paletteIndex() % 5 : 0;
    return p[idx];
}

auto GameLogic::paletteName() const -> QString {
    static const QStringList names = {
        u"Original DMG"_s,
        u"Pocket B&W"_s,
        u"Golden Lux"_s,
        u"Ice Blue"_s,
        u"Virtual Red"_s
    };
    int idx = m_profileManager ? m_profileManager->paletteIndex() % 5 : 0;
    return names[idx];
}

auto GameLogic::obstacles() const -> QVariantList {
    QVariantList list;
    for (const auto &p : m_obstacles) {
        QVariantMap item;
        item.insert(u"x"_s, p.x());
        item.insert(u"y"_s, p.y());
        list.append(item);
    }
    return list;
}

auto GameLogic::shellColor() const -> QColor {
    static const QList<QColor> colors = {
        u"#c0c0c0"_s, u"#f0f0f0"_s, u"#9370db"_s, 
        u"#ff0000"_s, u"#008080"_s, u"#ffd700"_s, u"#2f4f4f"_s
    };
    int idx = m_profileManager ? m_profileManager->shellIndex() % 7 : 0;
    return colors[idx];
}

auto GameLogic::shellName() const -> QString {
    static const QStringList names = {
        u"Matte Silver"_s,
        u"Cloud White"_s,
        u"Lavender"_s,
        u"Crimson"_s,
        u"Teal"_s,
        u"Sunburst"_s,
        u"Graphite"_s
    };
    const int idx = m_profileManager ? m_profileManager->shellIndex() % names.size() : 0;
    return names[idx];
}

auto GameLogic::ghost() const -> QVariantList {
    if (m_state == Replaying) {
        return {};
    }
    QVariantList list;
    int len = m_snakeModel.rowCount();
    int start = std::max(0, m_ghostFrameIndex - len + 1);
    for (int i = m_ghostFrameIndex; i >= start && i < m_bestRecording.size(); --i) {
        list.append(m_bestRecording[i]);
    }
    return list;
}

auto GameLogic::musicEnabled() const noexcept -> bool {
    return m_musicEnabled;
}

auto GameLogic::achievements() const -> QVariantList {
    QVariantList list;
    if (m_profileManager) {
        for (const auto &m : m_profileManager->unlockedMedals()) {
            list.append(m);
        }
    }
    return list;
}

auto GameLogic::medalLibrary() const -> QVariantList {
    QVariantList list;
    auto createMedal = [](const QString &id, const QString &hint) -> QVariantMap {
        QVariantMap m;
        m.insert(u"id"_s, id);
        m.insert(u"hint"_s, hint);
        return m;
    };
    list << createMedal(u"Gold Medal (50 Pts)"_s, u"Reach 50 points"_s)
         << createMedal(u"Silver Medal (20 Pts)"_s, u"Reach 20 points"_s)
         << createMedal(u"Centurion (100 Crashes)"_s, u"Crash 100 times"_s)
         << createMedal(u"Gourmet (500 Food)"_s, u"Eat 500 food"_s)
         << createMedal(u"Untouchable"_s, u"20 Ghost triggers"_s)
         << createMedal(u"Speed Demon"_s, u"Max speed reached"_s)
         << createMedal(u"Pacifist (60s No Food)"_s, u"60s no food"_s);
    return list;
}

auto GameLogic::coverage() const noexcept -> float { 
    return static_cast<float>(m_snakeModel.rowCount()) / (BOARD_WIDTH * BOARD_HEIGHT); 
}

auto GameLogic::volume() const -> float { 
    return m_profileManager ? m_profileManager->volume() : 1.0f; 
}

void GameLogic::setVolume(float v) {
    if (m_profileManager) {
        m_profileManager->setVolume(v);
    }
    emit audioSetVolume(v);
    emit volumeChanged();
}

auto GameLogic::fruitLibrary() const -> QVariantList {
    QVariantList list;
    QList<int> discovered = m_profileManager ? 
                            m_profileManager->discoveredFruits() : QList<int>();
    auto add = [&](int t, QString n, QString d) -> void {
        bool isDiscovered = discovered.contains(t);
        QVariantMap m;
        m.insert(u"type"_s, t);
        m.insert(u"name"_s, isDiscovered ? n : u"??????"_s);
        m.insert(u"desc"_s, isDiscovered ? d : u"Eat this fruit in-game to unlock its data."_s);
        m.insert(u"discovered"_s, isDiscovered);
        list << m;
    };
    add(Ghost, u"Ghost"_s, u"Pass through yourself."_s);
    add(Slow, u"Slow"_s, u"Slows the game down."_s);
    add(Magnet, u"Magnet"_s, u"Standard nutritious food."_s);
    add(Shield, u"Shield"_s, u"Survive one collision."_s);
    add(Portal, u"Portal"_s, u"Pass through obstacle walls."_s);
    add(Double, u"Golden"_s, u"2x points per food."_s);
    add(Rich, u"Diamond"_s, u"3x points per food."_s);
    add(Laser, u"Laser"_s, u"Breaks one obstacle."_s);
    add(Mini, u"Mini"_s, u"Shrinks body by 50%."_s);
    return list;
}

// --- Private Helpers ---

void GameLogic::applyMiniShrink() {
    const auto body = m_snakeModel.body();
    if (body.size() <= 3) {
        return;
    }
    std::deque<QPoint> nextBody;
    const size_t targetLength = snakegb::core::miniShrinkTargetLength(body.size(), 3);
    for (size_t i = 0; i < targetLength; ++i) {
        nextBody.push_back(body[i]);
    }
    m_snakeModel.reset(nextBody);
}

void GameLogic::applyPendingStateChangeIfNeeded() {
    if (!m_pendingStateChange.has_value()) {
        return;
    }
    const int pendingState = *m_pendingStateChange;
    m_pendingStateChange.reset();
    requestStateChange(pendingState);
}

void GameLogic::dispatchStateCallback(const std::function<void(GameState &)> &callback) {
    if (!m_fsmState) {
        return;
    }
    // Defer state replacement while executing a state callback to avoid
    // invalidating the current state object mid-function.
    m_stateCallbackInProgress = true;
    callback(*m_fsmState);
    m_stateCallbackInProgress = false;
    applyPendingStateChangeIfNeeded();
}

auto GameLogic::normalTickIntervalMs() const -> int {
    if (m_activeBuff == Slow) {
        return 250;
    }
    return snakegb::core::tickIntervalForScore(m_score);
}

void GameLogic::applyAcquiredBuffEffects(int discoveredType, int baseDurationTicks, bool halfDurationForRich,
                                         bool emitMiniPrompt) {
    if (m_profileManager) {
        m_profileManager->discoverFruit(discoveredType);
    }

    if (m_activeBuff == Shield) {
        m_shieldActive = true;
    }

    if (m_activeBuff == Mini) {
        applyMiniShrink();
        if (emitMiniPrompt) {
            emit eventPrompt(u"MINI BLITZ! SIZE CUT"_s);
        }
        m_activeBuff = None;
    }

    m_buffTicksRemaining = halfDurationForRich
                               ? snakegb::core::buffDurationTicks(static_cast<snakegb::core::BuffId>(m_activeBuff),
                                                                  baseDurationTicks)
                               : baseDurationTicks;
    m_buffTicksTotal = m_buffTicksRemaining;
}

void GameLogic::applyPostTickTasks() {
    if (!m_currentScript.isEmpty()) {
        runLevelScript();
    }
    m_gameTickCounter++;
}

void GameLogic::updateReflectionFallback() {
    if (m_hasAccelerometerReading) {
        return;
    }
    const float t = static_cast<float>(QDateTime::currentMSecsSinceEpoch()) / 1000.0f;
    m_reflectionOffset = QPointF(std::sin(t * 0.8f) * 0.01f, std::cos(t * 0.7f) * 0.01f);
    emit reflectionOffsetChanged();
}

auto GameLogic::shouldTriggerRoguelikeChoice(int previousScore, int newScore) -> bool {
    const int chancePercent = snakegb::core::roguelikeChoiceChancePercent({
        .previousScore = previousScore,
        .newScore = newScore,
        .lastChoiceScore = m_lastRoguelikeChoiceScore,
    });
    if (chancePercent >= 100) {
        return true;
    }
    if (chancePercent <= 0) {
        return false;
    }
    return m_rng.bounded(100) < chancePercent;
}

void GameLogic::applyMagnetAttraction() {
    if (m_activeBuff != Magnet || m_food == QPoint(-1, -1) || m_snakeModel.body().empty()) {
        return;
    }

    const QPoint head = m_snakeModel.body().front();
    if (m_food == head) {
        handleFoodConsumption(head);
        return;
    }

    const QList<QPoint> candidates =
        snakegb::core::magnetCandidateSpots(m_food, head, BOARD_WIDTH, BOARD_HEIGHT);

    for (const QPoint &candidate : candidates) {
        if (candidate == m_food) {
            continue;
        }
        if (candidate == head || (!isOccupied(candidate) && candidate != m_powerUpPos)) {
            m_food = candidate;
            emit foodChanged();
            if (m_food == head) {
                handleFoodConsumption(head);
            }
            return;
        }
    }
}

void GameLogic::deactivateBuff() {
    m_activeBuff = None;
    m_buffTicksRemaining = 0;
    m_buffTicksTotal = 0;
    m_shieldActive = false;
    m_timer->setInterval(normalTickIntervalMs());
    emit buffChanged();
}

void GameLogic::changeState(std::unique_ptr<GameState> newState) {
    if (m_fsmState) {
        m_fsmState->exit();
    }
    m_fsmState = std::move(newState);
    if (m_fsmState) {
        m_fsmState->enter();
    }
}

void GameLogic::spawnFood() {
    QPoint pickedPoint;
    const bool found = snakegb::core::pickRandomFreeSpot(
        BOARD_WIDTH,
        BOARD_HEIGHT,
        [this](const QPoint &point) -> bool { return isOccupied(point) || point == m_powerUpPos; },
        [this](int size) -> int { return m_rng.bounded(size); },
        pickedPoint);
    if (found) {
        m_food = pickedPoint;
        emit foodChanged();
    }
}

void GameLogic::spawnPowerUp() {
    QPoint pickedPoint;
    const bool found = snakegb::core::pickRandomFreeSpot(
        BOARD_WIDTH,
        BOARD_HEIGHT,
        [this](const QPoint &point) -> bool { return isOccupied(point) || point == m_food; },
        [this](int size) -> int { return m_rng.bounded(size); },
        pickedPoint);
    if (found) {
        m_powerUpPos = pickedPoint;
        m_powerUpType = rollWeightedPowerUp(m_rng);
        emit powerUpChanged();
    }
}

void GameLogic::updateHighScore() {
    if (m_profileManager && m_score > m_profileManager->highScore()) {
        m_profileManager->updateHighScore(m_score);
        m_bestInputHistory = m_currentInputHistory;
        m_bestRecording = m_currentRecording;
        m_bestChoiceHistory = m_currentChoiceHistory;
        m_bestRandomSeed = m_randomSeed;
        m_bestLevelIndex = m_levelIndex;

        const bool savedGhost = snakegb::adapter::saveGhostSnapshot({
            .recording = m_bestRecording,
            .randomSeed = m_bestRandomSeed,
            .inputHistory = m_bestInputHistory,
            .levelIndex = m_bestLevelIndex,
            .choiceHistory = m_bestChoiceHistory,
        });
        if (!savedGhost) {
            qWarning().noquote() << "[ReplayFlow][GameLogic] failed to persist ghost snapshot";
        }
        emit highScoreChanged();
    }
}

void GameLogic::saveCurrentState() {
    if (m_profileManager) {
        m_profileManager->saveSession(m_score, m_snakeModel.body(), m_obstacles, m_food, m_direction);
        emit hasSaveChanged();
    }
}

void GameLogic::clearSavedState() {
    if (m_profileManager) {
        m_profileManager->clearSession();
        emit hasSaveChanged();
    }
}

void GameLogic::applyFallbackLevelData(const int levelIndex) {
    const snakegb::core::FallbackLevelData fallback = snakegb::core::fallbackLevelData(levelIndex);
    m_obstacles.clear();
    m_currentLevelName = fallback.name;
    m_currentScript = fallback.script;
    if (!m_currentScript.isEmpty()) {
        const QJSValue res = m_jsEngine.evaluate(m_currentScript);
        if (!res.isError()) {
            runLevelScript();
        }
    } else {
        m_obstacles = fallback.walls;
    }
    emit obstaclesChanged();
}

void GameLogic::loadLevelData(int i) {
    const int safeIndex = snakegb::core::normalizedFallbackLevelIndex(i);
    m_currentLevelName = snakegb::core::fallbackLevelData(safeIndex).name;

    const auto resolvedLevel = snakegb::adapter::loadResolvedLevelFromResource(u"qrc:/src/levels/levels.json"_s, i);
    if (!resolvedLevel.has_value()) {
        applyFallbackLevelData(safeIndex);
        return;
    }

    const bool applied = snakegb::adapter::applyResolvedLevelData(
        *resolvedLevel, m_currentLevelName, m_currentScript, m_obstacles,
        [this](const QString &script) -> bool {
            const QJSValue res = m_jsEngine.evaluate(script);
            if (res.isError()) {
                return false;
            }
            runLevelScript();
            return true;
        });
    if (!applied) {
        applyFallbackLevelData(safeIndex);
        return;
    }
    emit obstaclesChanged();
}

auto GameLogic::buildSafeInitialSnakeBody() const -> std::deque<QPoint> {
    return snakegb::core::buildSafeInitialSnakeBody(m_obstacles, BOARD_WIDTH, BOARD_HEIGHT);
}

void GameLogic::checkAchievements() {
    if (!m_profileManager) {
        return;
    }

    const QStringList unlockedTitles = snakegb::core::unlockedAchievementTitles(
        m_score, m_timer->interval(), m_timer->isActive());

    auto unlockTitle = [this](const QString &title) -> void {
        if (m_profileManager->unlockMedal(title)) {
            emit achievementEarned(title);
            emit achievementsChanged();
        }
    };

    for (const QString &title : unlockedTitles) {
        unlockTitle(title);
    }
}

void GameLogic::runLevelScript() {
    if (snakegb::adapter::tryApplyOnTickScript(m_jsEngine, m_gameTickCounter, m_obstacles)) {
        emit obstaclesChanged();
        return;
    }
    if (snakegb::adapter::applyDynamicLevelFallback(m_currentLevelName, m_gameTickCounter, m_obstacles)) {
        emit obstaclesChanged();
    }
}

auto GameLogic::isOccupied(const QPoint &p) const -> bool {
    for (const auto &bp : m_snakeModel.body()) {
        if (bp == p) {
            return true;
        }
    }
    for (const auto &op : m_obstacles) {
        if (op == p) {
            return true;
        }
    }
    return false;
}

auto GameLogic::isOutOfBounds(const QPoint &p) noexcept -> bool {
    return !m_boardRect.contains(p);
}

void GameLogic::update() {
    if (m_fsmState) {
        if (m_activeBuff != None && m_buffTicksRemaining > 0) {
            if (--m_buffTicksRemaining <= 0) {
                deactivateBuff();
            }
        }
        dispatchStateCallback([](GameState &state) -> void { state.update(); });
        applyPostTickTasks();
    }
    updateReflectionFallback();
}
