#include "game_logic.h"
#include "fsm/states.h"
#include "sound_manager.h"
#include <QCoreApplication>
#include <QDataStream>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QRandomGenerator>
#include <QStandardPaths>
#include <algorithm>
#include <ranges>

using namespace Qt::StringLiterals;

namespace {
constexpr int InitialInterval = 150;
const QString GhostFileName = u"ghost.dat"_s;
} // namespace

GameLogic::GameLogic(QObject *parent)
    : QObject(parent), m_timer(std::make_unique<QTimer>()),
      m_soundManager(std::make_unique<SoundManager>()), m_settings(u"MyCompany"_s, u"SnakeGB"_s) {
    connect(m_timer.get(), &QTimer::timeout, this, &GameLogic::update);
    m_paletteIndex = m_settings.value(u"paletteIndex"_s, 0).toInt();
    m_shellIndex = m_settings.value(u"shellIndex"_s, 0).toInt();
    m_snakeModel.reset({{10, 10}, {10, 11}, {10, 12}});

    m_fsmState = std::make_unique<SplashState>(*this);
    m_fsmState->enter();
}

void GameLogic::lazyInit() {
    m_highScore = m_settings.value(u"highScore"_s, 0).toInt();
    m_levelIndex = m_settings.value(u"levelIndex"_s, 0).toInt();
    QFile file(GhostFileName);
    if (file.open(QIODevice::ReadOnly)) {
        QDataStream in(&file);
        in >> m_bestRecording;
    }
    loadLevelData(m_levelIndex);
    spawnFood();
    emit paletteChanged();
    emit shellColorChanged();
}

GameLogic::~GameLogic() {
    m_timer->stop();
    if (m_state == Playing || m_state == Paused) {
        saveCurrentState();
    }
}

void GameLogic::changeState(std::unique_ptr<GameState> newState) {
    if (m_fsmState) {
        m_fsmState->exit();
    }
    // Perform swap to ensure pointer validity during transition if possible
    m_fsmState = std::move(newState);
    if (m_fsmState) {
        m_fsmState->enter();
    }
}

void GameLogic::setInternalState(State s) {
    if (m_state != s) {
        m_state = s;
        emit stateChanged();
    }
}

void GameLogic::startGame() { restart(); }

void GameLogic::restart() {
    m_snakeModel.reset({{10, 10}, {10, 11}, {10, 12}});
    m_direction = {0, -1};
    m_inputQueue.clear();
    m_score = 0;
    m_ghostFrameIndex = 0;
    m_currentRecording.clear();
    m_currentRecording.append(QPoint(10, 10));
    loadLevelData(m_levelIndex);
    clearSavedState();
    m_timer->setInterval(InitialInterval);
    spawnFood();
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
    m_currentRecording.clear();
    m_ghostFrameIndex = 0;
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
    m_settings.sync();
    emit hasSaveChanged();
}

void GameLogic::clearSavedState() {
    m_settings.remove(u"saved_body"_s); m_settings.remove(u"saved_obstacles"_s);
    m_settings.sync();
    emit hasSaveChanged();
}

bool GameLogic::hasSave() const noexcept { return m_settings.contains(u"saved_body"_s); }

void GameLogic::move(const int dx, const int dy) {
    // Logic removal: Only add to queue, don't check m_fsmState for direction validation here
    // to prevent race conditions during state transitions.
    if (m_inputQueue.size() < 2) {
        QPoint lastDir = m_inputQueue.empty() ? m_direction : m_inputQueue.back();
        if ((dx != 0 && lastDir.x() == -dx) || (dy != 0 && lastDir.y() == -dy)) return;
        m_inputQueue.push_back({dx, dy});
        if (m_soundManager) m_soundManager->playBeep(200, 50);
    }
}

void GameLogic::update() { 
    if (m_fsmState) {
        m_fsmState->update(); 
    }
}

void GameLogic::nextPalette() {
    m_paletteIndex = (m_paletteIndex + 1) % 6;
    m_settings.setValue(u"paletteIndex"_s, m_paletteIndex);
    emit paletteChanged();
    if (m_soundManager) m_soundManager->playBeep(600, 50);
}

void GameLogic::nextShellColor() {
    m_shellIndex = (m_shellIndex + 1) % 5;
    m_settings.setValue(u"shellIndex"_s, m_shellIndex);
    emit shellColorChanged();
    if (m_soundManager) m_soundManager->playBeep(500, 50);
}

void GameLogic::nextLevel() {
    m_levelIndex = (m_levelIndex + 1) % 2;
    m_settings.setValue(u"levelIndex"_s, m_levelIndex);
    loadLevelData(m_levelIndex);
    emit levelChanged();
}

void GameLogic::quitToMenu() { m_timer->stop(); saveCurrentState(); changeState(std::make_unique<MenuState>(*this)); }

void GameLogic::toggleMusic() {
    if (!m_soundManager) return;
    bool nextEnabled = !m_soundManager->musicEnabled();
    m_soundManager->setMusicEnabled(nextEnabled);
    if (nextEnabled && m_state == StartMenu) m_soundManager->startMusic();
    emit musicEnabledChanged();
}

void GameLogic::quit() { saveCurrentState(); QCoreApplication::quit(); }

bool GameLogic::musicEnabled() const noexcept { return m_soundManager ? m_soundManager->musicEnabled() : false; }

void GameLogic::loadLevelData(int index) {
    QFile file(u":/levels.json"_s);
    if (!file.open(QIODevice::ReadOnly)) return;
    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    QJsonArray levels = doc.object().value(u"levels"_s).toArray();
    if (index >= levels.size()) index = 0;
    QJsonObject lvl = levels[index].toObject();
    m_obstacles.clear();
    for (const auto &w : lvl.value(u"walls"_s).toArray()) {
        QPoint p(w.toObject().value(u"x"_s).toInt(), w.toObject().value(u"y"_s).toInt());
        if (std::abs(p.x() - 10) <= 2 && std::abs(p.y() - 10) <= 2) continue;
        m_obstacles.append(p);
    }
    emit obstaclesChanged();
}

QVariantList GameLogic::ghost() const noexcept {
    QVariantList list;
    int ghostLength = static_cast<int>(m_snakeModel.body().size());
    int start = std::max(0, m_ghostFrameIndex - ghostLength + 1);
    for (int i = m_ghostFrameIndex; i >= start && i < m_bestRecording.size(); --i) list.append(m_bestRecording[i]);
    return list;
}

QVariantList GameLogic::palette() const noexcept {
    static const QList<QVariantList> palettes = {
        {u"#cadc9f"_s, u"#8bac0f"_s, u"#306230"_s, u"#0f380f"_s},
        {u"#e0e8d0"_s, u"#a0a890"_s, u"#4d533c"_s, u"#1f1f1f"_s},
        {u"#70a0d0"_s, u"#4070a0"_s, u"#204060"_s, u"#001020"_s},
        {u"#ffffff"_s, u"#aaaaaa"_s, u"#555555"_s, u"#000000"_s},
        {u"#200000"_s, u"#550000"_s, u"#aa0000"_s, u"#ff0000"_s},
        {u"#ffd700"_s, u"#e0a000"_s, u"#a05000"_s, u"#201000"_s}};
    return palettes[m_paletteIndex];
}

QString GameLogic::paletteName() const noexcept {
    static const QStringList names = {u"Original"_s, u"Pocket"_s, u"Blue Light"_s, u"Mono"_s, u"Virtual Red"_s, u"Golden"_s};
    return names[m_paletteIndex];
}

QVariantList GameLogic::obstacles() const noexcept {
    QVariantList list; for (const auto &p : m_obstacles) list.append(p);
    return list;
}

QColor GameLogic::shellColor() const noexcept {
    static const QList<QColor> colors = {u"#c0c0c0"_s, u"#f0f0f0"_s, u"#9370db"_s, u"#ffd700"_s, u"#32cd32"_s};
    return colors[m_shellIndex];
}

void GameLogic::updateHighScore() {
    if (m_score > m_highScore) {
        m_highScore = m_score;
        m_settings.setValue(u"highScore"_s, m_highScore);
        m_bestRecording = m_currentRecording;
        QFile file(GhostFileName);
        if (file.open(QIODevice::WriteOnly)) {
            QDataStream out(&file);
            out << m_bestRecording;
        }
        m_settings.sync();
        emit highScoreChanged();
    }
}

void GameLogic::spawnFood() {
    const auto &body = m_snakeModel.body();
    bool foodIsInvalid = true;
    while (foodIsInvalid) {
        m_food = QPoint(QRandomGenerator::global()->bounded(BOARD_WIDTH), QRandomGenerator::global()->bounded(BOARD_HEIGHT));
        bool inSafeZone = std::abs(m_food.x() - 10) <= 2 && std::abs(m_food.y() - 10) <= 2;
        foodIsInvalid = std::ranges::contains(body, m_food) || std::ranges::contains(m_obstacles, m_food) || inSafeZone;
    }
    emit foodChanged();
}

auto GameLogic::isOutOfBounds(const QPoint &p) noexcept -> bool { return !m_boardRect.contains(p); }
