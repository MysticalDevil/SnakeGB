#include "game_logic.h"
#include "fsm/states.h"
#include "sound_manager.h"
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
#include <algorithm>

using namespace Qt::StringLiterals;

namespace {
constexpr int InitialInterval = 150;
constexpr int MaxSpawnAttempts = 200;
constexpr int BuffDurationMs = 8000;
constexpr int PacifistThresholdMs = 60000;

QString getGhostFilePath() {
    const QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(path);
    return path + u"/ghost.dat"_s;
}
} // namespace

GameLogic::GameLogic(QObject *parent)
    : QObject(parent),
      m_rng(QRandomGenerator::securelySeeded()),
      m_settings(),
      m_timer(std::make_unique<QTimer>()),
      m_soundManager(std::make_unique<SoundManager>()),
      m_buffTimer(std::make_unique<QTimer>()) {
    connect(m_timer.get(), &QTimer::timeout, this, &GameLogic::update);
    m_buffTimer->setSingleShot(true);
    connect(m_buffTimer.get(), &QTimer::timeout, this, &GameLogic::deactivateBuff);

    m_paletteIndex = m_settings.value(u"paletteIndex"_s, 0).toInt();
    m_shellIndex = m_settings.value(u"shellIndex"_s, 0).toInt();
    m_totalCrashes = m_settings.value(u"totalCrashes"_s, 0).toInt();
    m_totalFoodEaten = m_settings.value(u"totalFoodEaten"_s, 0).toInt();
    m_totalGhostTriggers = m_settings.value(u"totalGhostTriggers"_s, 0).toInt();
    m_unlockedMedals = m_settings.value(u"unlockedMedals"_s).toStringList();

    m_snakeModel.reset({{10, 10}, {10, 11}, {10, 12}});
    m_fsmState = std::make_unique<SplashState>(*this);
    m_fsmState->enter();
}

void GameLogic::lazyInit() {
    m_highScore = m_settings.value(u"highScore"_s, 0).toInt();
    m_levelIndex = m_settings.value(u"levelIndex"_s, 0).toInt();
    QFile file(getGhostFilePath());
    if (file.open(QIODevice::ReadOnly)) {
        QDataStream in(&file);
        in >> m_bestRecording >> m_bestRandomSeed >> m_bestInputHistory;
    }
    loadLevelData(m_levelIndex);
    spawnFood();
    emit paletteChanged();
    emit shellColorChanged();
}

GameLogic::~GameLogic() {
    m_timer->stop(); m_buffTimer->stop();
    if (m_state == Playing || m_state == Paused) saveCurrentState();
}

void GameLogic::changeState(std::unique_ptr<GameState> newState) {
    if (m_fsmState) m_fsmState->exit();
    m_fsmState = std::move(newState);
    if (m_fsmState) m_fsmState->enter();
}

void GameLogic::setInternalState(State s) {
    if (m_state != s) { m_state = s; emit stateChanged(); }
}

void GameLogic::startGame() { restart(); }

void GameLogic::startReplay() {
    if (m_bestInputHistory.isEmpty()) return;
    m_snakeModel.reset({{10, 10}, {10, 11}, {10, 12}});
    m_direction = {0, -1}; m_inputQueue.clear(); m_score = 0;
    m_rng.seed(m_bestRandomSeed); m_gameTickCounter = 0;
    loadLevelData(m_levelIndex);
    m_timer->setInterval(InitialInterval);
    spawnFood();
    changeState(std::make_unique<ReplayingState>(*this));
}

void GameLogic::restart() {
    m_snakeModel.reset({{10, 10}, {10, 11}, {10, 12}});
    m_direction = {0, -1}; m_inputQueue.clear(); m_score = 0;
    if (m_soundManager) m_soundManager->setScore(0);
    m_activeBuff = None; m_powerUpPos = QPoint(-1, -1); m_buffTimer->stop();
    m_randomSeed = static_cast<uint>(QDateTime::currentMSecsSinceEpoch());
    m_rng.seed(m_randomSeed);
    m_gameTickCounter = 0; m_currentInputHistory.clear();
    m_sessionStartTime = QDateTime::currentMSecsSinceEpoch();
    emit buffChanged(); emit powerUpChanged();
    loadLevelData(m_levelIndex); clearSavedState();
    m_timer->setInterval(InitialInterval); spawnFood();
    if (m_soundManager) m_soundManager->playBeep(1046, 100);
    emit scoreChanged(); emit foodChanged(); emit ghostChanged();
    changeState(std::make_unique<PlayingState>(*this));
}

void GameLogic::togglePause() {
    if (m_state == Playing) changeState(std::make_unique<PausedState>(*this));
    else if (m_state == Paused) changeState(std::make_unique<PlayingState>(*this));
}

void GameLogic::loadLastSession() {
    if (!m_settings.contains(u"saved_body"_s)) return;
    m_score = m_settings.value(u"saved_score"_s).toInt();
    std::deque<QPoint> body;
    for (const auto &v : m_settings.value(u"saved_body"_s).toList()) body.emplace_back(v.toPoint());
    m_obstacles.clear();
    for (const auto &v : m_settings.value(u"saved_obstacles"_s).toList()) m_obstacles.emplace_back(v.toPoint());
    m_food = m_settings.value(u"saved_food"_s).toPoint();
    m_direction = m_settings.value(u"saved_dir"_s).toPoint();
    m_snakeModel.reset(body);
    m_sessionStartTime = QDateTime::currentMSecsSinceEpoch();
    emit scoreChanged(); emit obstaclesChanged(); emit foodChanged(); emit hasSaveChanged();
    changeState(std::make_unique<PausedState>(*this));
}

void GameLogic::saveCurrentState() {
    QVariantList bodyVar; for (const auto &p : m_snakeModel.body()) bodyVar.append(p);
    m_settings.setValue(u"saved_body"_s, bodyVar);
    QVariantList obsVar; for (const auto &p : m_obstacles) obsVar.append(p);
    m_settings.setValue(u"saved_obstacles"_s, obsVar);
    m_settings.setValue(u"saved_score"_s, m_score);
    m_settings.setValue(u"saved_food"_s, m_food);
    m_settings.setValue(u"saved_dir"_s, m_direction);
    m_settings.setValue(u"totalCrashes"_s, m_totalCrashes);
    m_settings.setValue(u"totalFoodEaten"_s, m_totalFoodEaten);
    m_settings.setValue(u"totalGhostTriggers"_s, m_totalGhostTriggers);
    m_settings.setValue(u"unlockedMedals"_s, m_unlockedMedals);
    m_settings.sync(); emit hasSaveChanged();
}

void GameLogic::clearSavedState() {
    m_settings.remove(u"saved_body"_s); m_settings.remove(u"saved_obstacles"_s);
    m_settings.sync(); emit hasSaveChanged();
}

bool GameLogic::hasSave() const noexcept { return m_settings.contains(u"saved_body"_s); }
bool GameLogic::hasReplay() const noexcept { return !m_bestInputHistory.isEmpty(); }

void GameLogic::move(int dx, int dy) {
    if (m_inputQueue.size() < 2) {
        const QPoint lastDir = m_inputQueue.empty() ? m_direction : m_inputQueue.back();
        if ((dx != 0 && lastDir.x() == -dx) || (dy != 0 && lastDir.y() == -dy)) return;
        m_inputQueue.push_back({dx, dy});
        m_currentInputHistory.append({m_gameTickCounter, dx, dy});
        if (m_soundManager) m_soundManager->playBeep(200, 50);
    }
}

void GameLogic::update() { if (m_fsmState) { m_fsmState->update(); if (!m_currentScript.isEmpty()) runLevelScript(); m_gameTickCounter++; } }

void GameLogic::runLevelScript() {
    QJSValue onTick = m_jsEngine.globalObject().property(u"onTick"_s);
    if (onTick.isCallable()) {
        QJSValueList args; args << m_gameTickCounter;
        QJSValue result = onTick.call(args);
        if (result.isArray()) {
            m_obstacles.clear();
            int len = result.property(u"length"_s).toInt();
            for (int i = 0; i < len; ++i) {
                QJSValue item = result.property(i);
                m_obstacles.append(QPoint(item.property(u"x"_s).toInt(), item.property(u"y"_s).toInt()));
            }
            emit obstaclesChanged();
        }
    }
}

void GameLogic::nextPalette() { m_paletteIndex = (m_paletteIndex + 1) % 6; m_settings.setValue(u"paletteIndex"_s, m_paletteIndex); emit paletteChanged(); if (m_soundManager) m_soundManager->playBeep(600, 50); }
void GameLogic::nextShellColor() { m_shellIndex = (m_shellIndex + 1) % 5; m_settings.setValue(u"shellIndex"_s, m_shellIndex); emit shellColorChanged(); if (m_soundManager) m_soundManager->playBeep(500, 50); }
void GameLogic::nextLevel() { m_levelIndex = (m_levelIndex + 1) % 3; m_settings.setValue(u"levelIndex"_s, m_levelIndex); loadLevelData(m_levelIndex); emit levelChanged(); }
void GameLogic::quitToMenu() { m_timer->stop(); m_buffTimer->stop(); saveCurrentState(); changeState(std::make_unique<MenuState>(*this)); }
void GameLogic::toggleMusic() { if (!m_soundManager) return; const bool nextEnabled = !m_soundManager->musicEnabled(); m_soundManager->setMusicEnabled(nextEnabled); if (nextEnabled && m_state != Splash) m_soundManager->startMusic(); emit musicEnabledChanged(); }

void GameLogic::quit() { 
    saveCurrentState(); 
#ifdef Q_OS_WASM
    emit paletteChanged(); 
#else
    QCoreApplication::quit(); 
#endif
}

void GameLogic::handleSelect() { if (m_fsmState) m_fsmState->handleSelect(); }
void GameLogic::handleStart() { if (m_fsmState) m_fsmState->handleStart(); }
void GameLogic::deleteSave() { clearSavedState(); if (m_soundManager) m_soundManager->playCrash(200); emit paletteChanged(); }
bool GameLogic::musicEnabled() const noexcept { return m_soundManager ? m_soundManager->musicEnabled() : false; }

void GameLogic::loadLevelData(int index) {
    QFile file(u":/levels.json"_s); if (!file.open(QIODevice::ReadOnly)) return;
    const QJsonObject docObj = QJsonDocument::fromJson(file.readAll()).object();
    const QJsonArray levels = docObj.value(u"levels"_s).toArray();
    if (index >= levels.size()) index = 0;
    const QJsonObject lvl = levels[index].toObject();
    m_currentLevelName = lvl.value(u"name"_s).toString();
    m_obstacles.clear();
    m_currentScript = lvl.value(u"script"_s).toString();
    if (!m_currentScript.isEmpty()) m_jsEngine.evaluate(m_currentScript);
    else {
        for (const auto &w : lvl.value(u"walls"_s).toArray()) {
            const QPoint p(w.toObject().value(u"x"_s).toInt(), w.toObject().value(u"y"_s).toInt());
            if (std::abs(p.x() - 10) <= 2 && std::abs(p.y() - 10) <= 2) continue;
            m_obstacles.append(p);
        }
    }
    emit obstaclesChanged();
}

void GameLogic::spawnFood() {
    const auto &body = m_snakeModel.body(); int attempts = 0;
    while (attempts < MaxSpawnAttempts) {
        m_food = QPoint(m_rng.bounded(BOARD_WIDTH), m_rng.bounded(BOARD_HEIGHT));
        bool collision = false;
        for (const auto &p : body) { if (p == m_food) { collision = true; break; } }
        if (!collision) { for (const auto &p : m_obstacles) { if (p == m_food) { collision = true; break; } } }
        const bool inSafeZone = std::abs(m_food.x() - 10) <= 2 && std::abs(m_food.y() - 10) <= 2;
        if (!collision && !inSafeZone && m_food != m_powerUpPos) { emit foodChanged(); return; }
        attempts++;
    }
}

void GameLogic::spawnPowerUp() {
    const auto &body = m_snakeModel.body(); int attempts = 0;
    while (attempts < MaxSpawnAttempts) {
        m_powerUpPos = QPoint(m_rng.bounded(BOARD_WIDTH), m_rng.bounded(BOARD_HEIGHT));
        bool collision = false;
        for (const auto &p : body) { if (p == m_powerUpPos) { collision = true; break; } }
        if (!collision) { for (const auto &p : m_obstacles) { if (p == m_powerUpPos) { collision = true; break; } } }
        const bool inSafeZone = std::abs(m_powerUpPos.x() - 10) <= 2 && std::abs(m_powerUpPos.y() - 10) <= 2;
        if (!collision && !inSafeZone && m_powerUpPos != m_food) {
            m_powerUpType = static_cast<PowerUp>(m_rng.bounded(1, 4));
            emit powerUpChanged(); return;
        }
        attempts++;
    }
}

void GameLogic::deactivateBuff() { m_activeBuff = None; m_timer->setInterval(std::max(50, 150 - (m_score / 5) * 10)); emit buffChanged(); }
auto GameLogic::achievements() const noexcept -> QVariantList { QVariantList list; for (const auto &m : m_unlockedMedals) list.append(m); return list; }

auto GameLogic::medalLibrary() const noexcept -> QVariantList {
    QVariantList list;
    auto createMedal = [](const QString &id, const QString &hint) {
        QVariantMap m; m.insert(u"id"_s, id); m.insert(u"hint"_s, hint); return m;
    };
    list << createMedal(u"Gold Medal (50 Pts)"_s, u"Reach 50 points"_s);
    list << createMedal(u"Silver Medal (20 Pts)"_s, u"Reach 20 points"_s);
    list << createMedal(u"Centurion (100 Crashes)"_s, u"Crash 100 times"_s);
    list << createMedal(u"Gourmet (500 Food)"_s, u"Eat 500 food"_s);
    list << createMedal(u"Untouchable"_s, u"20 Ghost triggers"_s);
    list << createMedal(u"Speed Demon"_s, u"Max speed reached"_s);
    list << createMedal(u"Pacifist (60s No Food)"_s, u"60s no food"_s);
    return list;
}

void GameLogic::checkAchievements() {
    auto unlock = [this](const QString &title) { if (!m_unlockedMedals.contains(title)) { m_unlockedMedals.append(title); emit achievementEarned(title); emit achievementsChanged(); if (m_soundManager) m_soundManager->playBeep(1500, 300); } };
    if (m_score >= 50) unlock(u"Gold Medal (50 Pts)"_s); if (m_score >= 20) unlock(u"Silver Medal (20 Pts)"_s); if (m_totalCrashes >= 100) unlock(u"Centurion (100 Crashes)"_s); if (m_totalFoodEaten >= 500) unlock(u"Gourmet (500 Food)"_s); if (m_totalGhostTriggers >= 20) unlock(u"Untouchable"_s); if (m_timer->interval() <= 50) unlock(u"Speed Demon"_s);
    if (m_score == 0 && m_state == Playing) { const qint64 now = QDateTime::currentMSecsSinceEpoch(); if ((now - m_sessionStartTime) > PacifistThresholdMs) unlock(u"Pacifist (60s No Food)"_s); }
}
void GameLogic::incrementCrashes() { m_totalCrashes++; checkAchievements(); }
void GameLogic::logFoodEaten() { m_totalFoodEaten++; checkAchievements(); }
void GameLogic::logPowerUpTriggered(PowerUp type) { if (type == Ghost) m_totalGhostTriggers++; checkAchievements(); }
auto GameLogic::ghost() const noexcept -> QVariantList { QVariantList list; const int ghostLength = static_cast<int>(m_snakeModel.body().size()); const int start = std::max(0, m_ghostFrameIndex - ghostLength + 1); for (int i = m_ghostFrameIndex; i >= start && i < m_bestRecording.size(); --i) list.append(m_bestRecording[i]); return list; }
auto GameLogic::palette() const noexcept -> QVariantList { static const QList<QVariantList> palettes = {{u"#cadc9f"_s, u"#8bac0f"_s, u"#306230"_s, u"#0f380f"_s}, {u"#e0e8d0"_s, u"#a0a890"_s, u"#4d533c"_s, u"#1f1f1f"_s}, {u"#70a0d0"_s, u"#4070a0"_s, u"#204060"_s, u"#001020"_s}, {u"#ffffff"_s, u"#aaaaaa"_s, u"#555555"_s, u"#000000"_s}, {u"#200000"_s, u"#550000"_s, u"#aa0000"_s, u"#ff0000"_s}, {u"#ffd700"_s, u"#e0a000"_s, u"#a05000"_s, u"#201000"_s}}; return palettes[m_paletteIndex]; }
auto GameLogic::paletteName() const noexcept -> QString { static const QStringList names = {u"Original"_s, u"Pocket"_s, u"Blue Light"_s, u"Mono"_s, u"Virtual Red"_s, u"Golden"_s}; return names[m_paletteIndex]; }
auto GameLogic::obstacles() const noexcept -> QVariantList { QVariantList list; for (const auto &p : m_obstacles) list.append(p); return list; }
auto GameLogic::shellColor() const noexcept -> QColor { static const QList<QColor> colors = {u"#c0c0c0"_s, u"#f0f0f0"_s, u"#9370db"_s, u"#ffd700"_s, u"#32cd32"_s}; return colors[m_shellIndex]; }
void GameLogic::updateHighScore() { if (m_score > m_highScore) { m_highScore = m_score; m_settings.setValue(u"highScore"_s, m_highScore); m_bestRecording = m_currentRecording; m_bestRandomSeed = m_randomSeed; m_bestInputHistory = m_currentInputHistory; QFile file(getGhostFilePath()); if (file.open(QIODevice::WriteOnly)) { QDataStream out(&file); out << m_bestRecording << m_bestRandomSeed << m_bestInputHistory; } m_settings.sync(); emit highScoreChanged(); } }
auto GameLogic::isOutOfBounds(const QPoint &p) noexcept -> bool { return !m_boardRect.contains(p); }
auto GameLogic::volume() const noexcept -> float { return m_soundManager ? m_soundManager->volume() : 1.0f; }
auto GameLogic::setVolume(float v) -> void { if (m_soundManager) { m_soundManager->setVolume(v); emit volumeChanged(); } }
