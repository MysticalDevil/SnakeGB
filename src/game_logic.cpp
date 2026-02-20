#include "game_logic.h"
#include "fsm/states.h"
#include "sound_manager.h"
#include "profile_manager.h"
#include <QCoreApplication>
#include <QDataStream>
#include <QFile>
#include <QDir>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QRandomGenerator>
#include <QStandardPaths>
#include <QDateTime>
#include <QJSValue>
#include <QAccelerometer>
#ifdef Q_OS_ANDROID
#include <QJniObject>
#include <QtCore/qnativeinterface.h>
#endif
#include <algorithm>

using namespace Qt::StringLiterals;

namespace {
    constexpr int InitialInterval = 200;
    constexpr int BuffDurationTicks = 40; 
    constexpr quint32 GHOST_FILE_MAGIC = 0x534E4B04;

    QString getGhostFilePath() {
        const QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        QDir().mkpath(path);
        return path + u"/ghost.dat"_s;
    }
}

GameLogic::GameLogic(QObject *parent)
    : QObject(parent),
      m_rng(QRandomGenerator::securelySeeded()),
      m_timer(std::make_unique<QTimer>()),
      m_soundManager(std::make_unique<SoundManager>()),
      m_profileManager(std::make_unique<ProfileManager>()),
      m_fsmState(nullptr) {

    connect(m_timer.get(), &QTimer::timeout, this, &GameLogic::update);

    if (m_soundManager) {
        connect(this, &GameLogic::foodEaten, m_soundManager.get(), [this](float pan) {
            if (m_soundManager) {
                m_soundManager->setScore(m_score);
                m_soundManager->playBeep(880, 100, pan);
                triggerHaptic(3);
            }
        });
        connect(this, &GameLogic::powerUpEaten, m_soundManager.get(), [this]() {
            if (m_soundManager) {
                m_soundManager->playBeep(1200, 150);
                triggerHaptic(6);
            }
        });
        connect(this, &GameLogic::playerCrashed, m_soundManager.get(), [this]() {
            if (m_soundManager) {
                m_soundManager->playCrash(500);
                triggerHaptic(10);
            }
        });
        connect(this, &GameLogic::uiInteractTriggered, m_soundManager.get(), [this]() {
            if (m_soundManager) m_soundManager->playBeep(200, 50);
        });
        connect(this, &GameLogic::stateChanged, m_soundManager.get(), [this]() {
            if (!m_soundManager) return;
            if (m_state == StartMenu) m_soundManager->startMusic();
            else if (m_state == Playing) m_soundManager->stopMusic();
            else if (m_state == Splash) m_soundManager->playBeep(440, 100);
        });
    }

    m_snakeModel.reset({{10, 10}, {10, 11}, {10, 12}});
}

GameLogic::~GameLogic() {
    if (m_timer) m_timer->stop();
    m_fsmState.reset();
    if (m_state == Playing || m_state == Paused) saveCurrentState();
}

void GameLogic::setInternalState(int s) {
    State next = static_cast<State>(s);
    if (m_state != next) {
        m_state = next;
        if (m_soundManager) m_soundManager->setPaused(m_state == Paused || m_state == ChoiceSelection || m_state == Library || m_state == MedalRoom);
        emit stateChanged();
    }
}

void GameLogic::requestStateChange(int newState) {
    State s = static_cast<State>(newState);
    switch (s) {
    case StartMenu: changeState(std::make_unique<MenuState>(*this)); break;
    case Playing:   changeState(std::make_unique<PlayingState>(*this)); break;
    case Paused:    changeState(std::make_unique<PausedState>(*this)); break;
    case GameOver:  changeState(std::make_unique<GameOverState>(*this)); break;
    case Replaying: changeState(std::make_unique<ReplayingState>(*this)); break;
    case ChoiceSelection: changeState(std::make_unique<ChoiceState>(*this)); break;
    case Library: changeState(std::make_unique<LibraryState>(*this)); break;
    case MedalRoom: changeState(std::make_unique<MedalRoomState>(*this)); break;
    default: break;
    }
}

bool GameLogic::checkCollision(const QPoint &head) {
    QPoint p = head;
    if (m_activeBuff == Portal) {
        p.setX((p.x() + BOARD_WIDTH) % BOARD_WIDTH);
        p.setY((p.y() + BOARD_HEIGHT) % BOARD_HEIGHT);
    } else if (isOutOfBounds(p)) {
        if (m_shieldActive) { m_shieldActive = false; triggerHaptic(5); emit buffChanged(); return false; }
        return true;
    }
    for (int i = 0; i < m_obstacles.size(); ++i) {
        if (m_obstacles[i] == p) {
            if (m_activeBuff == Laser) { m_obstacles.removeAt(i); m_activeBuff = None; emit obstaclesChanged(); triggerHaptic(8); emit buffChanged(); return false; }
            if (m_shieldActive) { m_shieldActive = false; triggerHaptic(5); emit buffChanged(); return false; }
            return true;
        }
    }
    if (m_activeBuff != Ghost) { for (const auto &body : m_snakeModel.body()) if (body == p) { if (m_shieldActive) { m_shieldActive = false; triggerHaptic(5); emit buffChanged(); return false; } return true; } }
    return false;
}

void GameLogic::handleFoodConsumption(const QPoint &head) {
    QPoint p = head; if (m_activeBuff == Portal) { p.setX((p.x() + BOARD_WIDTH) % BOARD_WIDTH); p.setY((p.y() + BOARD_HEIGHT) % BOARD_HEIGHT); }
    if (p != m_food) return;
    int points = 1; if (m_activeBuff == Double) points = 2; else if (m_activeBuff == Rich) points = 3;
    m_score += points; if (m_profileManager) m_profileManager->logFoodEaten();
    float pan = (static_cast<float>(p.x()) / BOARD_WIDTH - 0.5f) * 1.4f; emit foodEaten(pan);
    m_timer->setInterval(std::max(60, 200 - (m_score / 5) * 8)); emit scoreChanged(); spawnFood();
    if (m_score > 0 && m_score % 10 == 0) requestStateChange(ChoiceSelection);
    else if (m_rng.bounded(100) < 15 && m_powerUpPos == QPoint(-1, -1)) spawnPowerUp();
    triggerHaptic(std::min(5, 2 + (m_score / 10)));
}

void GameLogic::handlePowerUpConsumption(const QPoint &head) {
    QPoint p = head; if (m_activeBuff == Portal) { p.setX((p.x() + BOARD_WIDTH) % BOARD_WIDTH); p.setY((p.y() + BOARD_HEIGHT) % BOARD_HEIGHT); }
    if (p != m_powerUpPos) return;
    m_activeBuff = m_powerUpType; if (m_profileManager) m_profileManager->discoverFruit(static_cast<int>(m_activeBuff));
    if (m_activeBuff == Shield) m_shieldActive = true;
    if (m_activeBuff == Mini) { auto body = m_snakeModel.body(); if (body.size() > 3) { std::deque<QPoint> nb; size_t half = std::max<size_t>(3, body.size()/2); for(size_t i=0; i<half; ++i) nb.push_back(body[i]); m_snakeModel.reset(nb); } m_activeBuff = None; }
    m_powerUpPos = QPoint(-1, -1); m_buffTicksRemaining = (m_activeBuff == Rich) ? BuffDurationTicks / 2 : BuffDurationTicks;
    emit powerUpEaten(); if (m_activeBuff == Slow) m_timer->setInterval(250);
    triggerHaptic(5); emit buffChanged(); emit powerUpChanged();
}

void GameLogic::applyMovement(const QPoint &newHead, bool grew) {
    QPoint p = newHead; if (m_activeBuff == Portal) { p.setX((p.x() + BOARD_WIDTH) % BOARD_WIDTH); p.setY((p.y() + BOARD_HEIGHT) % BOARD_HEIGHT); }
    m_snakeModel.moveHead(p, grew); m_currentRecording.append(p);
    if (m_ghostFrameIndex < static_cast<int>(m_bestRecording.size())) { m_ghostFrameIndex++; emit ghostChanged(); }
    checkAchievements();
}

void GameLogic::triggerHaptic(int magnitude) { 
    emit requestFeedback(magnitude);
#ifdef Q_OS_ANDROID
    QJniObject context = QNativeInterface::QAndroidApplication::context();
    if (context.isValid()) {
        QJniObject vibrator = context.callObjectMethod("getSystemService", "(Ljava/lang/String;)Ljava/lang/Object;", QJniObject::fromString("vibrator").object<jstring>());
        if (vibrator.isValid()) vibrator.callMethod<void>("vibrate", "(J)V", static_cast<jlong>(magnitude * 15));
    }
#endif
}

void GameLogic::playEventSound(int type, float pan) { if (type == 0) emit foodEaten(pan); else if (type == 1) emit playerCrashed(); else if (type == 2) emit uiInteractTriggered(); else if (type == 3 && m_soundManager) m_soundManager->playBeep(150, 100); }
void GameLogic::updatePersistence() { updateHighScore(); if (m_profileManager) m_profileManager->incrementCrashes(); clearSavedState(); }
void GameLogic::startEngineTimer(int intervalMs) { if (intervalMs > 0) m_timer->setInterval(intervalMs); m_timer->start(); }
void GameLogic::stopEngineTimer() { m_timer->stop(); }
void GameLogic::togglePause() { if (m_state == Playing) requestStateChange(Paused); else if (m_state == Paused) requestStateChange(Playing); }

void GameLogic::nextPalette() { if (m_profileManager) { m_profileManager->setPaletteIndex((m_profileManager->paletteIndex() + 1) % 5); emit paletteChanged(); emit uiInteractTriggered(); } }
void GameLogic::nextShellColor() { if (m_profileManager) { m_profileManager->setShellIndex((m_profileManager->shellIndex() + 1) % 7); emit shellColorChanged(); emit uiInteractTriggered(); } }
void GameLogic::nextLevel() { m_levelIndex = (m_levelIndex + 1) % 3; loadLevelData(m_levelIndex); emit levelChanged(); if (m_profileManager) m_profileManager->setLevelIndex(m_levelIndex); }
void GameLogic::toggleMusic() { if (m_soundManager) { bool e = !m_soundManager->musicEnabled(); m_soundManager->setMusicEnabled(e); if (e && m_state != Splash) m_soundManager->startMusic(); emit musicEnabledChanged(); } }

void GameLogic::checkAchievements() {
    if (!m_profileManager) return;
    auto unlock = [this](const QString &t) { if (m_profileManager->unlockMedal(t)) { emit achievementEarned(t); emit achievementsChanged(); } };
    if (m_score >= 50) unlock(u"Gold Medal (50 Pts)"_s); if (m_timer->isActive() && m_timer->interval() <= 60) unlock(u"Speed Demon"_s);
}

void GameLogic::deactivateBuff() { m_activeBuff = None; m_buffTicksRemaining = 0; m_shieldActive = false; m_timer->setInterval(std::max(60, 200 - (m_score / 5) * 8)); emit buffChanged(); }
void GameLogic::saveCurrentState() { if (m_profileManager) { m_profileManager->saveSession(m_score, m_snakeModel.body(), m_obstacles, m_food, m_direction); emit hasSaveChanged(); } }
void GameLogic::clearSavedState() { if (m_profileManager) { m_profileManager->clearSession(); emit hasSaveChanged(); } }

void GameLogic::spawnFood() { QList<QPoint> freeSpots; for (int x = 0; x < BOARD_WIDTH; ++x) for (int y = 0; y < BOARD_HEIGHT; ++y) { QPoint p(x, y); if (!isOccupied(p) && p != m_powerUpPos) freeSpots << p; } if (!freeSpots.isEmpty()) { m_food = freeSpots[m_rng.bounded(freeSpots.size())]; emit foodChanged(); } }
void GameLogic::spawnPowerUp() { QList<QPoint> freeSpots; for (int x = 0; x < BOARD_WIDTH; ++x) for (int y = 0; y < BOARD_HEIGHT; ++y) { QPoint p(x, y); if (!isOccupied(p) && p != m_food) freeSpots << p; } if (!freeSpots.isEmpty()) { m_powerUpPos = freeSpots[m_rng.bounded(freeSpots.size())]; m_powerUpType = static_cast<PowerUp>(m_rng.bounded(1, 10)); emit powerUpChanged(); } }
bool GameLogic::isOccupied(const QPoint &p) const { for (const auto &bp : m_snakeModel.body()) if (bp == p) return true; for (const auto &op : m_obstacles) if (op == p) return true; return false; }

void GameLogic::updateHighScore() {
    if (m_profileManager && m_score > m_profileManager->highScore()) {
        m_profileManager->updateHighScore(m_score); m_bestInputHistory = m_currentInputHistory; m_bestRecording = m_currentRecording; m_bestChoiceHistory = m_currentChoiceHistory; m_bestRandomSeed = m_randomSeed; m_bestLevelIndex = m_levelIndex;
        QFile file(getGhostFilePath()); if (file.open(QIODevice::WriteOnly)) { QDataStream out(&file); out << GHOST_FILE_MAGIC << m_bestRecording << m_bestRandomSeed << m_bestInputHistory << m_bestLevelIndex << m_bestChoiceHistory; }
        emit highScoreChanged();
    }
}

void GameLogic::lazyInit() {
    if (m_profileManager) { m_levelIndex = m_profileManager->levelIndex(); if (m_soundManager) m_soundManager->setVolume(m_profileManager->volume()); }
    QFile f(getGhostFilePath()); if (f.open(QIODevice::ReadOnly)) { QDataStream in(&f); quint32 magic; in >> magic; if (magic == GHOST_FILE_MAGIC) in >> m_bestRecording >> m_bestRandomSeed >> m_bestInputHistory >> m_bestLevelIndex >> m_bestChoiceHistory; else if (magic >= 0x534E4B02) { in >> m_bestRecording >> m_bestRandomSeed >> m_bestInputHistory >> m_bestLevelIndex; m_bestChoiceHistory.clear(); } else { m_bestRecording.clear(); m_bestInputHistory.clear(); } }
    loadLevelData(m_levelIndex); spawnFood(); emit paletteChanged(); emit shellColorChanged();
}

void GameLogic::loadLevelData(int i) {
    QFile f(u"qrc:/src/levels/levels.json"_s); if (!f.open(QIODevice::ReadOnly)) return;
    auto levels = QJsonDocument::fromJson(f.readAll()).object().value(u"levels"_s).toArray(); auto lvl = levels[i % levels.size()].toObject(); m_currentLevelName = lvl.value(u"name"_s).toString(); m_obstacles.clear(); m_currentScript = lvl.value(u"script"_s).toString();
    if (!m_currentScript.isEmpty()) { m_jsEngine.evaluate(m_currentScript); runLevelScript(); } else { for (const auto &w : lvl.value(u"walls"_s).toArray()) m_obstacles.append(QPoint(w.toObject().value(u"x"_s).toInt(), w.toObject().value(u"y"_s).toInt())); }
    emit obstaclesChanged();
}

void GameLogic::lazyInitState() { if (m_fsmState) return; changeState(std::make_unique<SplashState>(*this)); }
void GameLogic::move(int dx, int dy) { if (m_fsmState) m_fsmState->handleInput(dx, dy); if (m_state == Playing && m_inputQueue.size() < 2) { QPoint last = m_inputQueue.empty() ? m_direction : m_inputQueue.back(); if ((dx && last.x() == -dx) || (dy && last.y() == -dy)) return; m_inputQueue.push_back({dx, dy}); emit uiInteractTriggered(); } }
void GameLogic::quit() { saveCurrentState(); QCoreApplication::quit(); }
void GameLogic::handleSelect() { if (m_fsmState) m_fsmState->handleSelect(); }
void GameLogic::handleStart() { if (m_fsmState) m_fsmState->handleStart(); }
void GameLogic::deleteSave() { clearSavedState(); emit paletteChanged(); }
void GameLogic::changeState(std::unique_ptr<GameState> newState) { if (m_fsmState) m_fsmState->exit(); m_fsmState = std::move(newState); if (m_fsmState) m_fsmState->enter(); }
void GameLogic::runLevelScript() { QJSValue onTick = m_jsEngine.globalObject().property(u"onTick"_s); if (onTick.isCallable()) { QJSValueList args; args << m_gameTickCounter; QJSValue result = onTick.call(args); if (result.isArray()) { m_obstacles.clear(); int len = result.property(u"length"_s).toInt(); for (int i = 0; i < len; ++i) { QJSValue item = result.property(i); m_obstacles.append(QPoint(item.property(u"x"_s).toInt(), item.property(u"y"_s).toInt())); } emit obstaclesChanged(); } } }
void GameLogic::quitToMenu() { saveCurrentState(); requestStateChange(StartMenu); }
bool GameLogic::isOutOfBounds(const QPoint &p) noexcept { return !m_boardRect.contains(p); }

void GameLogic::update() {
    if (m_fsmState) { if (m_activeBuff != None && m_buffTicksRemaining > 0) { if (--m_buffTicksRemaining <= 0) deactivateBuff(); } m_fsmState->update(); if (!m_currentScript.isEmpty()) runLevelScript(); m_gameTickCounter++; }
    float t = static_cast<float>(QDateTime::currentMSecsSinceEpoch()) / 1000.0f; m_reflectionOffset = QPointF(std::sin(t * 0.8f) * 0.01f, std::cos(t * 0.7f) * 0.01f); emit reflectionOffsetChanged();
}

void GameLogic::loadLastSession() {
    if (!m_profileManager || !m_profileManager->hasSession()) return;
    auto d = m_profileManager->loadSession(); m_score = d[u"score"_s].toInt(); m_food = d[u"food"_s].toPoint(); m_direction = d[u"dir"_s].toPoint(); m_obstacles.clear(); for (const auto &v : d[u"obstacles"_s].toList()) m_obstacles.append(v.toPoint());
    std::deque<QPoint> b; for (const auto &v : d[u"body"_s].toList()) b.emplace_back(v.toPoint()); m_snakeModel.reset(b); m_inputQueue.clear(); m_currentInputHistory.clear(); m_currentRecording.clear(); m_currentChoiceHistory.clear(); for(const auto &p : b) m_currentRecording.append(p);
    m_timer->setInterval(std::max(60, 200 - (m_score/5)*8)); m_timer->start(); emit scoreChanged(); emit foodChanged(); emit obstaclesChanged(); emit ghostChanged(); requestStateChange(Paused);
}

int GameLogic::highScore() const { return m_profileManager ? m_profileManager->highScore() : 0; }
bool GameLogic::hasSave() const { return m_profileManager ? m_profileManager->hasSession() : false; }
bool GameLogic::hasReplay() const noexcept { return !m_bestInputHistory.isEmpty(); }
bool GameLogic::musicEnabled() const noexcept { return m_soundManager ? m_soundManager->musicEnabled() : false; }
QVariantList GameLogic::achievements() const { QVariantList list; if (m_profileManager) { for (const auto &m : m_profileManager->unlockedMedals()) list.append(m); } return list; }
QVariantList GameLogic::palette() const { static const QList<QVariantList> p = {{u"#cadc9f"_s, u"#8bac0f"_s, u"#306230"_s, u"#0f380f"_s}, {u"#e0e8d0"_s, u"#a0a890"_s, u"#4d533c"_s, u"#1f1f1f"_s}, {u"#ffd700"_s, u"#e0a000"_s, u"#a05000"_s, u"#201000"_s}, {u"#00ffff"_s, u"#008080"_s, u"#004040"_s, u"#002020"_s}, {u"#ff0000"_s, u"#a00000"_s, u"#500000"_s, u"#200000"_s}}; int idx = m_profileManager ? m_profileManager->paletteIndex() % 5 : 0; return p[idx]; }
QString GameLogic::paletteName() const { static const QStringList n = {u"Original DMG"_s, u"Pocket"_s, u"Golden"_s, u"Light Blue"_s, u"Virtual Red"_s}; int idx = m_profileManager ? m_profileManager->paletteIndex() % 5 : 0; return n[idx]; }
QVariantList GameLogic::obstacles() const { QVariantList list; for (const auto &p : m_obstacles) list.append(p); return list; }
QColor GameLogic::shellColor() const { static const QList<QColor> c = {u"#c0c0c0"_s, u"#f0f0f0"_s, u"#9370db"_s, u"#ff0000"_s, u"#008080"_s, u"#ffd700"_s, u"#2f4f4f"_s}; int idx = m_profileManager ? m_profileManager->shellIndex() % 7 : 0; return c[idx]; }
QVariantList GameLogic::ghost() const { if (m_state == Replaying) return {}; QVariantList list; int len = m_snakeModel.rowCount(); int start = std::max(0, m_ghostFrameIndex - len + 1); for (int i = m_ghostFrameIndex; i >= start && i < m_bestRecording.size(); --i) list.append(m_bestRecording[i]); return list; }
QVariantList GameLogic::medalLibrary() const { QVariantList list; auto createMedal = [](const QString &id, const QString &hint) { QVariantMap m; m.insert(u"id"_s, id); m.insert(u"hint"_s, hint); return m; }; list << createMedal(u"Gold Medal (50 Pts)"_s, u"Reach 50 points"_s) << createMedal(u"Silver Medal (20 Pts)"_s, u"Reach 20 points"_s) << createMedal(u"Centurion (100 Crashes)"_s, u"Crash 100 times"_s) << createMedal(u"Gourmet (500 Food)"_s, u"Eat 500 food"_s) << createMedal(u"Untouchable"_s, u"20 Ghost triggers"_s) << createMedal(u"Speed Demon"_s, u"Max speed reached"_s) << createMedal(u"Pacifist (60s No Food)"_s, u"60s no food"_s); return list; }
float GameLogic::coverage() const noexcept { return static_cast<float>(m_snakeModel.rowCount()) / (BOARD_WIDTH * BOARD_HEIGHT); }
float GameLogic::volume() const { return m_profileManager ? m_profileManager->volume() : 1.0f; }
void GameLogic::setVolume(float v) { if (m_profileManager) m_profileManager->setVolume(v); if (m_soundManager) m_soundManager->setVolume(v); emit volumeChanged(); }

void GameLogic::restart() {
    m_snakeModel.reset({{10, 10}, {10, 11}, {10, 12}}); m_direction = {0, -1}; m_inputQueue.clear(); m_score = 0; m_activeBuff = None; m_buffTicksRemaining = 0; m_shieldActive = false; m_powerUpPos = QPoint(-1, -1); m_choicePending = false; m_choiceIndex = 0;
    m_randomSeed = static_cast<uint>(QDateTime::currentMSecsSinceEpoch()); m_rng.seed(m_randomSeed); m_gameTickCounter = 0; m_ghostFrameIndex = 0; m_currentInputHistory.clear(); m_currentRecording.clear(); m_currentChoiceHistory.clear();
    loadLevelData(m_levelIndex); clearSavedState(); m_timer->setInterval(InitialInterval); m_timer->start(); spawnFood();
    emit buffChanged(); emit powerUpChanged(); emit scoreChanged(); emit foodChanged(); requestStateChange(Playing);
}

void GameLogic::startReplay() {
    if (m_bestInputHistory.isEmpty()) return;
    setInternalState(Replaying); m_snakeModel.reset({{10, 10}, {10, 11}, {10, 12}}); m_currentRecording.clear(); m_direction = {0, -1}; m_inputQueue.clear(); m_score = 0; m_activeBuff = None; m_buffTicksRemaining = 0; m_shieldActive = false; m_powerUpPos = QPoint(-1, -1);
    loadLevelData(m_bestLevelIndex); m_rng.seed(m_bestRandomSeed); m_gameTickCounter = 0; m_ghostFrameIndex = 0; m_timer->setInterval(InitialInterval); m_timer->start(); spawnFood();
    emit scoreChanged(); emit foodChanged(); emit ghostChanged(); changeState(std::make_unique<ReplayingState>(*this));
}

void GameLogic::generateChoices() {
    m_choices.clear(); struct ChoiceInfo { int type; QString name; QString desc; };
    QList<ChoiceInfo> allChoices = { {Ghost, u"Ghost"_s, u"Pass through self"_s}, {Slow, u"Slow"_s, u"Decrease speed"_s}, {Magnet, u"Magnet"_s, u"Attract food"_s}, {Shield, u"Shield"_s, u"One extra life"_s}, {Portal, u"Portal"_s, u"Screen wrap"_s}, {Double, u"Double"_s, u"Double points"_s}, {Rich, u"Diamond"_s, u"Triple points"_s}, {Laser, u"Laser"_s, u"Break obstacle"_s}, {Mini, u"Mini"_s, u"Shrink body"_s} };
    std::shuffle(allChoices.begin(), allChoices.end(), std::default_random_engine(m_rng.generate()));
    for (int i = 0; i < 3; ++i) { QVariantMap m; m.insert(u"type"_s, allChoices[i].type); m.insert(u"name"_s, allChoices[i].name); m.insert(u"desc"_s, allChoices[i].desc); m_choices.append(m); }
    emit choicesChanged();
}

void GameLogic::selectChoice(int index) {
    if (index < 0 || index >= m_choices.size()) return;
    if (m_state != Replaying) m_currentChoiceHistory.append({m_gameTickCounter, index});
    int type = m_choices[index].toMap().value(u"type"_s).toInt(); m_activeBuff = static_cast<PowerUp>(type); if (m_profileManager) m_profileManager->discoverFruit(type);
    if (m_activeBuff == Shield) m_shieldActive = true;
    if (m_activeBuff == Mini) { auto body = m_snakeModel.body(); std::deque<QPoint> nb; size_t half = std::max<size_t>(3, body.size()/2); for(size_t i=0; i<half; ++i) nb.push_back(body[i]); m_snakeModel.reset(nb); m_activeBuff = None; }
    m_buffTicksRemaining = BuffDurationTicks * 2; emit buffChanged(); m_timer->setInterval(500); 
    QTimer::singleShot(500, this, [this]() { if (m_state == Playing) { int normalInterval = std::max(60, 200 - (m_score / 5) * 8); if (m_activeBuff == Slow) normalInterval = 250; m_timer->setInterval(normalInterval); } });
    requestStateChange(Playing);
}

QVariantList GameLogic::fruitLibrary() const {
    QVariantList list; QList<int> discovered = m_profileManager ? m_profileManager->discoveredFruits() : QList<int>();
    auto add = [&](int t, QString n, QString d) { bool isDiscovered = discovered.contains(t); QVariantMap m; m.insert(u"type"_s, t); m.insert(u"name"_s, isDiscovered ? n : u"??????"_s); m.insert(u"desc"_s, isDiscovered ? d : u"Eat this fruit in-game to unlock its data."_s); m.insert(u"discovered"_s, isDiscovered); list << m; };
    add(Ghost, u"Ghost"_s, u"Pass through yourself."_s); add(Slow, u"Slow"_s, u"Slows the game down."_s); add(Magnet, u"Magnet"_s, u"Standard nutritious food."_s); add(Shield, u"Shield"_s, u"Survive one collision."_s); add(Portal, u"Portal"_s, u"Allows screen wrapping."_s); add(Double, u"Golden"_s, u"2x points per food."_s); add(Rich, u"Diamond"_s, u"3x points per food."_s); add(Laser, u"Laser"_s, u"Breaks one obstacle."_s); add(Mini, u"Mini"_s, u"Shrinks body by 50%."_s);
    return list;
}
