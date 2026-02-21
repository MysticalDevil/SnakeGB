#include "game_logic.h"
#include <QCoreApplication>
#include <QDateTime>
#include <QDebug>
#include <QJSValue>
#include <QRandomGenerator>
#include "adapter/ghost_store.h"
#include "adapter/input_semantics.h"
#include "adapter/level_applier.h"
#include "adapter/level_loader.h"
#include "adapter/level_script_runtime.h"
#include "adapter/session_state.h"
#include "adapter/ui_action.h"
#include "core/achievement_rules.h"
#include "core/buff_runtime.h"
#include "core/choice_runtime.h"
#include "core/game_rules.h"
#include "core/level_runtime.h"
#include "fsm/game_state.h"
#include "fsm/state_factory.h"
#include "profile_manager.h"
#ifdef SNAKEGB_HAS_SENSORS
#include <QAccelerometer>
#endif
#ifdef Q_OS_ANDROID
#include <QJniObject>
#include <QtCore/qnativeinterface.h>
#endif
#include <algorithm>
#include <cmath>

using namespace Qt::StringLiterals;

namespace
{
constexpr int InitialInterval = 200;
constexpr int BuffDurationTicks = 40;

auto stateName(int state) -> const char *
{
    switch (state) {
    case GameLogic::Splash:
        return "Splash";
    case GameLogic::StartMenu:
        return "StartMenu";
    case GameLogic::Playing:
        return "Playing";
    case GameLogic::Paused:
        return "Paused";
    case GameLogic::GameOver:
        return "GameOver";
    case GameLogic::Replaying:
        return "Replaying";
    case GameLogic::ChoiceSelection:
        return "ChoiceSelection";
    case GameLogic::Library:
        return "Library";
    case GameLogic::MedalRoom:
        return "MedalRoom";
    default:
        return "Unknown";
    }
}
} // namespace

GameLogic::GameLogic(QObject *parent)
    : QObject(parent), m_rng(QRandomGenerator::securelySeeded()),
      m_timer(std::make_unique<QTimer>()),
#ifdef SNAKEGB_HAS_SENSORS
      m_accelerometer(std::make_unique<QAccelerometer>()),
#endif
      m_profileManager(std::make_unique<ProfileManager>()), m_fsmState(nullptr)
{
    connect(m_timer.get(), &QTimer::timeout, this, &GameLogic::update);
    setupAudioSignals();
    setupSensorRuntime();

    m_snakeModel.reset({{10, 10}, {10, 11}, {10, 12}});
}

GameLogic::~GameLogic()
{
#ifdef SNAKEGB_HAS_SENSORS
    if (m_accelerometer) {
        m_accelerometer->stop();
    }
#endif
    if (m_timer) {
        m_timer->stop();
    }
    m_fsmState.reset();
}

void GameLogic::setupAudioSignals()
{
    connect(this, &GameLogic::foodEaten, this, [this](float pan) -> void {
        emit audioSetScore(m_score);
        emit audioPlayBeep(880, 100, pan);
        triggerHaptic(3);
    });

    connect(this, &GameLogic::powerUpEaten, this, [this]() -> void {
        emit audioPlayBeep(1200, 150, 0.0F);
        triggerHaptic(6);
    });

    connect(this, &GameLogic::playerCrashed, this, [this]() -> void {
        emit audioPlayCrash(500);
        triggerHaptic(12);
    });

    connect(this, &GameLogic::uiInteractTriggered, this, [this]() -> void {
        emit audioPlayBeep(200, 50, 0.0F);
        triggerHaptic(2);
    });

    connect(
        this, &GameLogic::stateChanged, this, [this]() -> void {
            qInfo().noquote() << "[AudioFlow][GameLogic] stateChanged ->" << stateName(m_state)
                              << "(musicEnabled=" << m_musicEnabled << ")";
            if (m_state == StartMenu) {
                const int token = m_audioStateToken;
                QTimer::singleShot(650, this, [this, token]() -> void {
                    if (token != m_audioStateToken) {
                        qInfo().noquote()
                            << "[AudioFlow][GameLogic] menu BGM deferred start canceled by token";
                        return;
                    }
                    if (m_state == StartMenu && m_musicEnabled) {
                        qInfo().noquote() << "[AudioFlow][GameLogic] emit audioStartMusic (menu)";
                        emit audioStartMusic();
                    }
                });
                return;
            }

            if (m_state == Playing || m_state == Replaying) {
                if (m_musicEnabled) {
                    qInfo().noquote()
                        << "[AudioFlow][GameLogic] emit audioStartMusic (playing/replaying)";
                    emit audioStartMusic();
                }
                return;
            }

            if (m_state == Splash || m_state == GameOver) {
                qInfo().noquote() << "[AudioFlow][GameLogic] emit audioStopMusic (splash/gameover)";
                emit audioStopMusic();
            }
        });
}

void GameLogic::setupSensorRuntime()
{
#ifdef SNAKEGB_HAS_SENSORS
    if (!m_accelerometer) {
        return;
    }

    m_accelerometer->setDataRate(30);
    connect(m_accelerometer.get(), &QAccelerometer::readingChanged, this, [this]() -> void {
        if (!m_accelerometer || !m_accelerometer->reading()) {
            return;
        }
        constexpr qreal maxTilt = 6.0;
        const qreal nx = std::clamp(m_accelerometer->reading()->y() / maxTilt, -1.0, 1.0);
        const qreal ny = std::clamp(m_accelerometer->reading()->x() / maxTilt, -1.0, 1.0);
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
#else
    m_hasAccelerometerReading = false;
#endif
}

// --- IGameEngine Implementation ---

void GameLogic::setInternalState(int s)
{
    auto next = static_cast<State>(s);
    if (m_state != next) {
        qInfo().noquote() << "[StateFlow][GameLogic] setInternalState:" << stateName(m_state)
                          << "->" << stateName(next);
        m_state = next;
        m_audioStateToken++;
        emit audioSetPaused(m_state == Paused || m_state == ChoiceSelection || m_state == Library ||
                            m_state == MedalRoom);
        emit stateChanged();
    }
}

void GameLogic::requestStateChange(int newState)
{
    if (m_stateCallbackInProgress) {
        qInfo().noquote() << "[StateFlow][GameLogic] defer requestStateChange to"
                          << stateName(newState) << "(inside callback)";
        m_pendingStateChange = newState;
        return;
    }
    qInfo().noquote() << "[StateFlow][GameLogic] requestStateChange ->" << stateName(newState);

    if (auto nextState = snakegb::fsm::createStateFor(*this, newState); nextState) {
        changeState(std::move(nextState));
    }
}

auto GameLogic::hasSave() const -> bool
{
    if (m_profileManager) {
        return m_profileManager->hasSession();
    }
    return false;
}

auto GameLogic::hasReplay() const noexcept -> bool
{
    return !m_bestInputHistory.isEmpty();
}

auto GameLogic::checkCollision(const QPoint &head) -> bool
{
    const snakegb::core::CollisionOutcome outcome = snakegb::core::collisionOutcomeForHead(
        head, BOARD_WIDTH, BOARD_HEIGHT, m_obstacles, m_snakeModel.body(), m_activeBuff == Ghost,
        m_activeBuff == Portal, m_activeBuff == Laser, m_shieldActive);

    if (outcome.consumeLaser && outcome.obstacleIndex >= 0 &&
        outcome.obstacleIndex < m_obstacles.size()) {
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

void GameLogic::handleFoodConsumption(const QPoint &head)
{
    const QPoint p = snakegb::core::wrapPoint(head, BOARD_WIDTH, BOARD_HEIGHT);

    if (p != m_food) {
        return;
    }

    const int points =
        snakegb::core::foodPointsForBuff(static_cast<snakegb::core::BuffId>(m_activeBuff));

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

void GameLogic::handlePowerUpConsumption(const QPoint &head)
{
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

void GameLogic::applyMovement(const QPoint &newHead, bool grew)
{
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

void GameLogic::restart()
{
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

void GameLogic::startReplay()
{
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
    if (auto nextState = snakegb::fsm::createStateFor(*this, Replaying); nextState) {
        changeState(std::move(nextState));
    }
}

void GameLogic::loadLastSession()
{
    if (!m_profileManager || !m_profileManager->hasSession()) {
        return;
    }

    const auto snapshot = snakegb::adapter::decodeSessionSnapshot(m_profileManager->loadSession());
    if (!snapshot.has_value()) {
        return;
    }

    m_score = snapshot->score;
    m_food = snapshot->food;
    m_direction = snapshot->direction;
    m_obstacles = snapshot->obstacles;
    m_snakeModel.reset(snapshot->body);
    m_inputQueue.clear();
    m_currentInputHistory.clear();
    m_currentRecording.clear();
    m_currentChoiceHistory.clear();
    m_lastRoguelikeChoiceScore = -1000;
    m_activeBuff = None;
    m_buffTicksRemaining = 0;
    m_buffTicksTotal = 0;
    m_shieldActive = false;

    for (const auto &p : snapshot->body) {
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

void GameLogic::togglePause()
{
    if (m_state == Playing) {
        requestStateChange(Paused);
    } else if (m_state == Paused) {
        requestStateChange(Playing);
    }
}

void GameLogic::nextLevel()
{
    const int levelCount =
        snakegb::adapter::readLevelCountFromResource(u"qrc:/src/levels/levels.json"_s, 6);
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

void GameLogic::startEngineTimer(int intervalMs)
{
    if (intervalMs > 0) {
        m_timer->setInterval(intervalMs);
    }
    m_timer->start();
}

void GameLogic::stopEngineTimer()
{
    m_timer->stop();
}

void GameLogic::triggerHaptic(int magnitude)
{
    emit requestFeedback(magnitude);
#ifdef Q_OS_ANDROID
    QJniObject context = QNativeInterface::QAndroidApplication::context();
    if (context.isValid()) {
        QJniObject vibrator =
            context.callObjectMethod("getSystemService", "(Ljava/lang/String;)Ljava/lang/Object;",
                                     QJniObject::fromString("vibrator").object<jstring>());
        if (vibrator.isValid()) {
            jlong duration = static_cast<jlong>(magnitude * 12);
            vibrator.callMethod<void>("vibrate", "(J)V", duration);
        }
    }
#endif
}

void GameLogic::playEventSound(int type, float pan)
{
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

void GameLogic::updatePersistence()
{
    updateHighScore();
    if (m_profileManager) {
        m_profileManager->incrementCrashes();
    }
    clearSavedState();
}

void GameLogic::lazyInit()
{
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

void GameLogic::lazyInitState()
{
    if (!m_fsmState) {
        if (auto nextState = snakegb::fsm::createStateFor(*this, Splash); nextState) {
            changeState(std::move(nextState));
        }
    }
}

void GameLogic::generateChoices()
{
    m_choices.clear();

    const QList<snakegb::core::ChoiceSpec> allChoices =
        snakegb::core::pickRoguelikeChoices(m_rng.generate(), 3);
    for (const auto &choice : allChoices) {
        QVariantMap m;
        m.insert(u"type"_s, choice.type);
        m.insert(u"name"_s, choice.name);
        m.insert(u"desc"_s, choice.description);
        m_choices.append(m);
    }
    emit choicesChanged();
}

void GameLogic::selectChoice(int index)
{
    if (index < 0 || index >= m_choices.size()) {
        return;
    }

    if (m_state != Replaying) {
        m_currentChoiceHistory.append({.frame = m_gameTickCounter, .index = index});
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

void GameLogic::dispatchUiAction(const QString &action)
{
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

void GameLogic::move(int dx, int dy)
{
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

void GameLogic::nextPalette()
{
    if (m_profileManager) {
        int nextIdx = (m_profileManager->paletteIndex() + 1) % 5;
        m_profileManager->setPaletteIndex(nextIdx);
        emit paletteChanged();
        emit uiInteractTriggered();
    }
}

void GameLogic::nextShellColor()
{
    if (m_profileManager) {
        int nextIdx = (m_profileManager->shellIndex() + 1) % 7;
        m_profileManager->setShellIndex(nextIdx);
        emit shellColorChanged();
        emit uiInteractTriggered();
    }
}

void GameLogic::handleBAction()
{
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

    if (m_state == Paused || m_state == GameOver || m_state == Replaying || m_state == Library ||
        m_state == MedalRoom) {
        quitToMenu();
    }
}

void GameLogic::quitToMenu()
{
    if (m_state == Playing || m_state == Paused || m_state == ChoiceSelection) {
        saveCurrentState();
    }
    requestStateChange(StartMenu);
}

void GameLogic::toggleMusic()
{
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

void GameLogic::quit()
{
    if (m_state == Playing || m_state == Paused || m_state == ChoiceSelection) {
        saveCurrentState();
    }
    QCoreApplication::quit();
}

void GameLogic::handleSelect()
{
    if (m_state == StartMenu) {
        nextLevel();
        return;
    }
    dispatchStateCallback([](GameState &state) -> void { state.handleSelect(); });
}

void GameLogic::handleStart()
{
    dispatchStateCallback([](GameState &state) -> void { state.handleStart(); });
}

void GameLogic::deleteSave()
{
    clearSavedState();
    // Clearing save should also reset level selection to default.
    m_levelIndex = 0;
    if (m_profileManager) {
        m_profileManager->setLevelIndex(m_levelIndex);
    }
    loadLevelData(m_levelIndex);
    emit levelChanged();
}

// --- Private Helpers ---

void GameLogic::applyMiniShrink()
{
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

void GameLogic::applyPendingStateChangeIfNeeded()
{
    if (!m_pendingStateChange.has_value()) {
        return;
    }
    const int pendingState = *m_pendingStateChange;
    m_pendingStateChange.reset();
    requestStateChange(pendingState);
}

void GameLogic::dispatchStateCallback(const std::function<void(GameState &)> &callback)
{
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

auto GameLogic::normalTickIntervalMs() const -> int
{
    if (m_activeBuff == Slow) {
        return 250;
    }
    return snakegb::core::tickIntervalForScore(m_score);
}

void GameLogic::applyAcquiredBuffEffects(int discoveredType, int baseDurationTicks,
                                         bool halfDurationForRich, bool emitMiniPrompt)
{
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

    m_buffTicksRemaining =
        halfDurationForRich
            ? snakegb::core::buffDurationTicks(static_cast<snakegb::core::BuffId>(m_activeBuff),
                                               baseDurationTicks)
            : baseDurationTicks;
    m_buffTicksTotal = m_buffTicksRemaining;
}

void GameLogic::applyPostTickTasks()
{
    if (!m_currentScript.isEmpty()) {
        runLevelScript();
    }
    m_gameTickCounter++;
}

void GameLogic::updateReflectionFallback()
{
    if (m_hasAccelerometerReading) {
        return;
    }
    const float t = static_cast<float>(QDateTime::currentMSecsSinceEpoch()) / 1000.0f;
    m_reflectionOffset = QPointF(std::sin(t * 0.8f) * 0.01f, std::cos(t * 0.7f) * 0.01f);
    emit reflectionOffsetChanged();
}

auto GameLogic::shouldTriggerRoguelikeChoice(int previousScore, int newScore) -> bool
{
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

void GameLogic::applyMagnetAttraction()
{
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

void GameLogic::deactivateBuff()
{
    m_activeBuff = None;
    m_buffTicksRemaining = 0;
    m_buffTicksTotal = 0;
    m_shieldActive = false;
    m_timer->setInterval(normalTickIntervalMs());
    emit buffChanged();
}

void GameLogic::changeState(std::unique_ptr<GameState> newState)
{
    if (m_fsmState) {
        m_fsmState->exit();
    }
    m_fsmState = std::move(newState);
    if (m_fsmState) {
        m_fsmState->enter();
    }
}

void GameLogic::spawnFood()
{
    QPoint pickedPoint;
    const bool found = snakegb::core::pickRandomFreeSpot(
        BOARD_WIDTH, BOARD_HEIGHT,
        [this](const QPoint &point) -> bool { return isOccupied(point) || point == m_powerUpPos; },
        [this](int size) -> int { return m_rng.bounded(size); }, pickedPoint);
    if (found) {
        m_food = pickedPoint;
        emit foodChanged();
    }
}

void GameLogic::spawnPowerUp()
{
    QPoint pickedPoint;
    const bool found = snakegb::core::pickRandomFreeSpot(
        BOARD_WIDTH, BOARD_HEIGHT,
        [this](const QPoint &point) -> bool { return isOccupied(point) || point == m_food; },
        [this](int size) -> int { return m_rng.bounded(size); }, pickedPoint);
    if (found) {
        m_powerUpPos = pickedPoint;
        m_powerUpType = static_cast<PowerUp>(static_cast<int>(snakegb::core::weightedRandomBuffId(
            [this](const int maxExclusive) -> int { return m_rng.bounded(maxExclusive); })));
        emit powerUpChanged();
    }
}

void GameLogic::updateHighScore()
{
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

void GameLogic::saveCurrentState()
{
    if (m_profileManager) {
        m_profileManager->saveSession(m_score, m_snakeModel.body(), m_obstacles, m_food,
                                      m_direction);
        emit hasSaveChanged();
    }
}

void GameLogic::clearSavedState()
{
    if (m_profileManager) {
        m_profileManager->clearSession();
        emit hasSaveChanged();
    }
}

void GameLogic::applyFallbackLevelData(const int levelIndex)
{
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

void GameLogic::loadLevelData(int i)
{
    const int safeIndex = snakegb::core::normalizedFallbackLevelIndex(i);
    m_currentLevelName = snakegb::core::fallbackLevelData(safeIndex).name;

    const auto resolvedLevel =
        snakegb::adapter::loadResolvedLevelFromResource(u"qrc:/src/levels/levels.json"_s, i);
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

auto GameLogic::buildSafeInitialSnakeBody() const -> std::deque<QPoint>
{
    return snakegb::core::buildSafeInitialSnakeBody(m_obstacles, BOARD_WIDTH, BOARD_HEIGHT);
}

void GameLogic::checkAchievements()
{
    if (!m_profileManager) {
        return;
    }

    const QStringList unlockedTitles =
        snakegb::core::unlockedAchievementTitles(m_score, m_timer->interval(), m_timer->isActive());

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

void GameLogic::runLevelScript()
{
    if (snakegb::adapter::tryApplyOnTickScript(m_jsEngine, m_gameTickCounter, m_obstacles)) {
        emit obstaclesChanged();
        return;
    }
    if (snakegb::adapter::applyDynamicLevelFallback(m_currentLevelName, m_gameTickCounter,
                                                    m_obstacles)) {
        emit obstaclesChanged();
    }
}

auto GameLogic::isOccupied(const QPoint &p) const -> bool
{
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

auto GameLogic::isOutOfBounds(const QPoint &p) noexcept -> bool
{
    return !m_boardRect.contains(p);
}

void GameLogic::update()
{
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
