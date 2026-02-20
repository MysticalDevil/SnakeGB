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
#endif
#include <algorithm>

using namespace Qt::StringLiterals;

namespace {
    constexpr int InitialInterval = 200;
    constexpr int MaxSpawnAttempts = 200;
    constexpr int BuffDurationMs = 8000;
    constexpr int PacifistThresholdMs = 60000;
    QString getGhostFilePath() {
        const QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        QDir().mkpath(path); return path + u"/ghost.dat"_s;
    }
}

GameLogic::GameLogic(QObject *parent)
    : QObject(parent), m_rng(QRandomGenerator::securelySeeded()), m_timer(std::make_unique<QTimer>()),
      m_soundManager(std::make_unique<SoundManager>()), m_profileManager(std::make_unique<ProfileManager>()),
      m_buffTimer(std::make_unique<QTimer>()), m_fsmState(nullptr) {
    connect(m_timer.get(), &QTimer::timeout, this, &GameLogic::update);
    m_buffTimer->setSingleShot(true);
    connect(m_buffTimer.get(), &QTimer::timeout, this, &GameLogic::deactivateBuff);
    if (m_soundManager) {
        connect(this, &GameLogic::foodEaten, m_soundManager.get(), [this](float pan) {
            if (m_soundManager) { m_soundManager->setScore(m_score); m_soundManager->playBeep(880, 100, pan); }
        });
        connect(this, &GameLogic::powerUpEaten, m_soundManager.get(), [this]() { if (m_soundManager) m_soundManager->playBeep(1200, 150); });
        connect(this, &GameLogic::playerCrashed, m_soundManager.get(), [this]() { if (m_soundManager) m_soundManager->playCrash(500); });
        connect(this, &GameLogic::uiInteractTriggered, m_soundManager.get(), [this]() { if (m_soundManager) m_soundManager->playBeep(200, 50); });
        connect(this, &GameLogic::stateChanged, m_soundManager.get(), [this]() {
            if (!m_soundManager) return;
            if (m_state == StartMenu) m_soundManager->startMusic();
            else if (m_state == Playing) m_soundManager->stopMusic();
        });
    }
    m_snakeModel.reset({{10, 10}, {10, 11}, {10, 12}});
    m_fsmState = std::make_unique<SplashState>(*this);
    QTimer::singleShot(0, this, [this]() { if (m_fsmState) m_fsmState->enter(); });
}

GameLogic::~GameLogic() { m_timer->stop(); m_buffTimer->stop(); m_fsmState.reset(); if (m_state == Playing || m_state == Paused) saveCurrentState(); }

// --- IGameEngine Implementation ---
void GameLogic::setInternalState(int s) { State next = static_cast<State>(s); if (m_state != next) { m_state = next; if (m_soundManager) m_soundManager->setPaused(m_state == Paused); emit stateChanged(); } }
void GameLogic::requestStateChange(int newState) { State s = static_cast<State>(newState); switch (s) { case StartMenu: changeState(std::make_unique<MenuState>(*this)); break; case Playing: changeState(std::make_unique<PlayingState>(*this)); break; case Paused: changeState(std::make_unique<PausedState>(*this)); break; case GameOver: changeState(std::make_unique<GameOverState>(*this)); break; case Replaying: changeState(std::make_unique<ReplayingState>(*this)); break; default: break; } }
bool GameLogic::checkCollision(const QPoint &head) { if (isOutOfBounds(head)) return true; for (const auto &p : m_obstacles) { if (p == head) return true; } if (m_activeBuff != Ghost) { for (const auto &p : m_snakeModel.body()) { if (p == head) return true; } } return false; }
void GameLogic::handleFoodConsumption(const QPoint &head) { if (head != m_food) return; m_score++; if (m_profileManager) m_profileManager->logFoodEaten(); float pan = (static_cast<float>(head.x()) / BOARD_WIDTH - 0.5f) * 1.4f; emit foodEaten(pan); m_timer->setInterval(std::max(60, 200 - (m_score / 5) * 8)); emit scoreChanged(); spawnFood(); if (m_rng.bounded(100) < 15 && m_powerUpPos == QPoint(-1, -1)) spawnPowerUp(); triggerHaptic(std::min(5, 2 + (m_score / 10))); }
void GameLogic::handlePowerUpConsumption(const QPoint &head) { if (head != m_powerUpPos) return; m_activeBuff = m_powerUpType; if (m_activeBuff == Ghost && m_profileManager) m_profileManager->logGhostTrigger(); m_powerUpPos = QPoint(-1, -1); m_buffTimer->start(BuffDurationMs); emit powerUpEaten(); if (m_activeBuff == Slow) m_timer->setInterval(250); emit buffChanged(); emit powerUpChanged(); }
void GameLogic::applyMovement(const QPoint &newHead, bool grew) { m_snakeModel.moveHead(newHead, grew); m_currentRecording.append(newHead); if (m_ghostFrameIndex < static_cast<int>(m_bestRecording.size())) { m_ghostFrameIndex++; emit ghostChanged(); } checkAchievements(); }
void GameLogic::triggerHaptic(int magnitude) { emit requestFeedback(magnitude); }
void GameLogic::playEventSound(int type, float pan) { if (type == 0) emit foodEaten(pan); else if (type == 1) emit playerCrashed(); else if (type == 2) emit uiInteractTriggered(); }
void GameLogic::updatePersistence() { updateHighScore(); if (m_profileManager) m_profileManager->incrementCrashes(); clearSavedState(); }

void GameLogic::restart() { m_snakeModel.reset({{10, 10}, {10, 11}, {10, 12}}); m_direction = {0, -1}; m_inputQueue.clear(); m_score = 0; m_activeBuff = None; m_powerUpPos = QPoint(-1, -1); m_buffTimer->stop(); m_randomSeed = static_cast<uint>(QDateTime::currentMSecsSinceEpoch()); m_rng.seed(m_randomSeed); m_gameTickCounter = 0; m_ghostFrameIndex = 0; m_currentInputHistory.clear(); m_currentRecording.clear(); m_sessionStartTime = QDateTime::currentMSecsSinceEpoch(); loadLevelData(m_levelIndex); clearSavedState(); m_timer->setInterval(InitialInterval); spawnFood(); emit buffChanged(); emit powerUpChanged(); emit scoreChanged(); emit foodChanged(); requestStateChange(Playing); }
void GameLogic::togglePause() { if (m_state == Playing) requestStateChange(Paused); else if (m_state == Paused) requestStateChange(Playing); }
void GameLogic::update() { if (m_fsmState) { m_fsmState->update(); if (!m_currentScript.isEmpty()) runLevelScript(); m_gameTickCounter++; } float t = static_cast<float>(QDateTime::currentMSecsSinceEpoch()) / 1000.0f; m_reflectionOffset = QPointF(std::sin(t * 0.8f) * 0.01f, std::cos(t * 0.7f) * 0.01f); emit reflectionOffsetChanged(); }

int GameLogic::highScore() const { return m_profileManager ? m_profileManager->highScore() : 0; }
bool GameLogic::hasSave() const { return m_profileManager ? m_profileManager->hasSession() : false; }
bool GameLogic::hasReplay() const noexcept { return !m_bestInputHistory.isEmpty(); }
bool GameLogic::musicEnabled() const noexcept { return m_soundManager ? m_soundManager->musicEnabled() : false; }
QVariantList GameLogic::achievements() const { QVariantList list; if (m_profileManager) { for (const auto &m : m_profileManager->unlockedMedals()) list.append(m); } return list; }
QVariantList GameLogic::palette() const { static const QList<QVariantList> p = {{u"#cadc9f"_s, u"#8bac0f"_s, u"#306230"_s, u"#0f380f"_s}, {u"#e0e8d0"_s, u"#a0a890"_s, u"#4d533c"_s, u"#1f1f1f"_s}, {u"#ffd700"_s, u"#e0a000"_s, u"#a05000"_s, u"#201000"_s}}; return p[m_profileManager ? m_profileManager->paletteIndex() % 3 : 0]; }
QString GameLogic::paletteName() const { static const QStringList n = {u"Original"_s, u"Pocket"_s, u"Golden"_s}; return n[m_profileManager ? m_profileManager->paletteIndex() % 3 : 0]; }
QVariantList GameLogic::obstacles() const { QVariantList list; for (const auto &p : m_obstacles) list.append(p); return list; }
QColor GameLogic::shellColor() const { static const QList<QColor> c = {u"#c0c0c0"_s, u"#f0f0f0"_s, u"#9370db"_s}; return c[m_profileManager ? m_profileManager->shellIndex() % 3 : 0]; }
QVariantList GameLogic::ghost() const { QVariantList list; int len = m_snakeModel.rowCount(); int start = std::max(0, m_ghostFrameIndex - len + 1); for (int i = m_ghostFrameIndex; i >= start && i < m_bestRecording.size(); --i) list.append(m_bestRecording[i]); return list; }
QVariantList GameLogic::medalLibrary() const { QVariantList list; auto createMedal = [](const QString &id, const QString &hint) { QVariantMap m; m.insert(u"id"_s, id); m.insert(u"hint"_s, hint); return m; }; list << createMedal(u"Gold Medal (50 Pts)"_s, u"Reach 50 points"_s) << createMedal(u"Silver Medal (20 Pts)"_s, u"Reach 20 points"_s) << createMedal(u"Centurion (100 Crashes)"_s, u"Crash 100 times"_s) << createMedal(u"Gourmet (500 Food)"_s, u"Eat 500 food"_s) << createMedal(u"Untouchable"_s, u"20 Ghost triggers"_s) << createMedal(u"Speed Demon"_s, u"Max speed reached"_s) << createMedal(u"Pacifist (60s No Food)"_s, u"60s no food"_s); return list; }
float GameLogic::coverage() const noexcept { return static_cast<float>(m_snakeModel.rowCount()) / (BOARD_WIDTH * BOARD_HEIGHT); }
float GameLogic::volume() const { return m_profileManager ? m_profileManager->volume() : 1.0f; }
void GameLogic::setVolume(float v) { if (m_profileManager) m_profileManager->setVolume(v); if (m_soundManager) m_soundManager->setVolume(v); emit volumeChanged(); }

void GameLogic::spawnFood() { int attempts = 0; while (attempts++ < MaxSpawnAttempts) { m_food = {m_rng.bounded(BOARD_WIDTH), m_rng.bounded(BOARD_HEIGHT)}; bool hit = false; for (const auto &p : m_snakeModel.body()) if (p == m_food) hit = true; for (const auto &p : m_obstacles) if (p == m_food) hit = true; if (!hit && m_food != m_powerUpPos) { emit foodChanged(); return; } } }
void GameLogic::spawnPowerUp() { int attempts = 0; while (attempts++ < MaxSpawnAttempts) { m_powerUpPos = {m_rng.bounded(BOARD_WIDTH), m_rng.bounded(BOARD_HEIGHT)}; bool hit = false; for (const auto &p : m_snakeModel.body()) if (p == m_powerUpPos) hit = true; for (const auto &p : m_obstacles) if (p == m_powerUpPos) hit = true; if (!hit && m_powerUpPos != m_food) { m_powerUpType = static_cast<PowerUp>(m_rng.bounded(1, 4)); emit powerUpChanged(); return; } } }
void GameLogic::updateHighScore() { if (m_profileManager && m_score > m_profileManager->highScore()) { m_profileManager->updateHighScore(m_score); m_bestInputHistory = m_currentInputHistory; m_bestRecording = m_currentRecording; m_bestRandomSeed = m_randomSeed; QFile file(getGhostFilePath()); if (file.open(QIODevice::WriteOnly)) { QDataStream out(&file); out << m_bestRecording << m_bestRandomSeed << m_bestInputHistory; } emit highScoreChanged(); } }
void GameLogic::saveCurrentState() { if (m_profileManager) m_profileManager->saveSession(m_score, m_snakeModel.body(), m_obstacles, m_food, m_direction); }
void GameLogic::clearSavedState() { if (m_profileManager) m_profileManager->clearSession(); }
void GameLogic::loadLastSession() { if (!m_profileManager || !m_profileManager->hasSession()) return; auto d = m_profileManager->loadSession(); m_score = d[u"score"_s].toInt(); m_food = d[u"food"_s].toPoint(); m_direction = d[u"dir"_s].toPoint(); m_obstacles.clear(); for (const auto &v : d[u"obstacles"_s].toList()) m_obstacles.append(v.toPoint()); std::deque<QPoint> b; for (const auto &v : d[u"body"_s].toList()) b.emplace_back(v.toPoint()); m_snakeModel.reset(b); m_timer->setInterval(std::max(60, 200 - (m_score/5)*8)); requestStateChange(Paused); }
void GameLogic::loadLevelData(int i) { QFile f(u":/levels.json"_s); if (!f.open(QIODevice::ReadOnly)) return; auto levels = QJsonDocument::fromJson(f.readAll()).object().value(u"levels"_s).toArray(); auto lvl = levels[i % levels.size()].toObject(); m_currentLevelName = lvl.value(u"name"_s).toString(); m_obstacles.clear(); m_currentScript = lvl.value(u"script"_s).toString(); if (!m_currentScript.isEmpty()) m_jsEngine.evaluate(m_currentScript); else { for (const auto &w : lvl.value(u"walls"_s).toArray()) { QPoint p(w.toObject().value(u"x"_s).toInt(), w.toObject().value(u"y"_s).toInt()); m_obstacles.append(p); } } emit obstaclesChanged(); }
void GameLogic::checkAchievements() { if (!m_profileManager) return; auto unlock = [this](const QString &t) { if (m_profileManager->unlockMedal(t)) { emit achievementEarned(t); emit achievementsChanged(); } }; if (m_score >= 50) unlock(u"Gold Medal (50 Pts)"_s); if (m_timer->interval() <= 60) unlock(u"Speed Demon"_s); }
bool GameLogic::isOutOfBounds(const QPoint &p) noexcept { return !m_boardRect.contains(p); }
void GameLogic::move(int dx, int dy) { if (m_inputQueue.size() < 2) { QPoint last = m_inputQueue.empty() ? m_direction : m_inputQueue.back(); if ((dx && last.x() == -dx) || (dy && last.y() == -dy)) return; m_inputQueue.push_back({dx, dy}); emit uiInteractTriggered(); } }
void GameLogic::nextPalette() { if (m_profileManager) { m_profileManager->setPaletteIndex((m_profileManager->paletteIndex() + 1) % 3); emit paletteChanged(); emit uiInteractTriggered(); } }
void GameLogic::nextShellColor() { if (m_profileManager) { m_profileManager->setShellIndex((m_profileManager->shellIndex() + 1) % 3); emit shellColorChanged(); emit uiInteractTriggered(); } }
void GameLogic::nextLevel() { m_levelIndex = (m_levelIndex + 1) % 3; loadLevelData(m_levelIndex); emit levelChanged(); }
void GameLogic::toggleMusic() { if (m_soundManager) { bool e = !m_soundManager->musicEnabled(); m_soundManager->setMusicEnabled(e); if (e && m_state != Splash) m_soundManager->startMusic(); emit musicEnabledChanged(); } }
void GameLogic::quit() { saveCurrentState(); QCoreApplication::quit(); }
void GameLogic::handleSelect() { if (m_fsmState) m_fsmState->handleSelect(); }
void GameLogic::handleStart() { if (m_fsmState) m_fsmState->handleStart(); }
void GameLogic::deleteSave() { clearSavedState(); emit paletteChanged(); }
void GameLogic::lazyInit() { if (m_profileManager) { m_levelIndex = m_profileManager->levelIndex(); if (m_soundManager) m_soundManager->setVolume(m_profileManager->volume()); } QFile f(getGhostFilePath()); if (f.open(QIODevice::ReadOnly)) { QDataStream in(&f); in >> m_bestRecording >> m_bestRandomSeed >> m_bestInputHistory; } loadLevelData(m_levelIndex); spawnFood(); emit paletteChanged(); emit shellColorChanged(); }
void GameLogic::deactivateBuff() { m_activeBuff = None; m_timer->setInterval(std::max(60, 200 - (m_score/5)*8)); emit buffChanged(); }
void GameLogic::changeState(std::unique_ptr<GameState> newState) { if (m_fsmState) m_fsmState->exit(); m_fsmState = std::move(newState); if (m_fsmState) m_fsmState->enter(); }
void GameLogic::quitToMenu() { saveCurrentState(); requestStateChange(StartMenu); }
void GameLogic::runLevelScript() { QJSValue onTick = m_jsEngine.globalObject().property(u"onTick"_s); if (onTick.isCallable()) { QJSValueList args; args << m_gameTickCounter; QJSValue result = onTick.call(args); if (result.isArray()) { m_obstacles.clear(); int len = result.property(u"length"_s).toInt(); for (int i = 0; i < len; ++i) { QJSValue item = result.property(i); m_obstacles.append(QPoint(item.property(u"x"_s).toInt(), item.property(u"y"_s).toInt())); } emit obstaclesChanged(); } } }
void GameLogic::startReplay() { if (m_bestInputHistory.isEmpty()) return; m_snakeModel.reset({{10, 10}, {10, 11}, {10, 12}}); m_direction = {0, -1}; m_inputQueue.clear(); m_score = 0; m_rng.seed(m_bestRandomSeed); m_gameTickCounter = 0; m_ghostFrameIndex = 0; loadLevelData(m_levelIndex); m_timer->setInterval(InitialInterval); spawnFood(); requestStateChange(Replaying); }
