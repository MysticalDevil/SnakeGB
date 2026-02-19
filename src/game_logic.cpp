#include "game_logic.h"
#include "sound_manager.h"
#include <QRandomGenerator>
#include <algorithm>
#include <ranges>

GameLogic::GameLogic(QObject *parent) 
    : QObject(parent), 
      m_timer(std::make_unique<QTimer>()),
      m_soundManager(std::make_unique<SoundManager>())
{
    connect(m_timer.get(), &QTimer::timeout, this, &GameLogic::update);
    m_highScore = m_settings.value("highScore", 0).toInt();
    m_paletteIndex = m_settings.value("paletteIndex", 0).toInt();
    m_shellIndex = m_settings.value("shellIndex", 0).toInt();

    m_snakeModel.reset({{10, 10}, {10, 11}, {10, 12}});
    spawnFood();
}

GameLogic::~GameLogic() {
    if (m_state == Playing || m_state == Paused) {
        saveCurrentState();
    }
}

void GameLogic::startGame() { restart(); }

void GameLogic::restart() {
    m_snakeModel.reset({{10, 10}, {10, 11}, {10, 12}});
    m_direction = {0, -1};
    m_score = 0;
    m_state = Playing;
    m_obstacles.clear();
    clearSavedState();

    m_timer->start(150);
    spawnFood();
    m_soundManager->playBeep(1000, 200);

    emit scoreChanged();
    emit stateChanged();
    emit obstaclesChanged();
}

void GameLogic::togglePause() {
    if (m_state == Playing) {
        m_state = Paused;
        m_timer->stop();
        saveCurrentState();
    } else if (m_state == Paused) {
        m_state = Playing;
        m_timer->start();
    }
    emit stateChanged();
    emit requestFeedback();
}

void GameLogic::loadLastSession() {
    if (!m_settings.contains("saved_body")) return;

    m_score = m_settings.value("saved_score").toInt();
    
    QList<QPoint> body;
    auto bodyVar = m_settings.value("saved_body").toList();
    for (const auto &v : bodyVar) body.append(v.toPoint());
    
    m_obstacles.clear();
    auto obsVar = m_settings.value("saved_obstacles").toList();
    for (const auto &v : obsVar) m_obstacles.append(v.toPoint());

    m_food = m_settings.value("saved_food").toPoint();
    m_direction = m_settings.value("saved_dir").toPoint();

    m_snakeModel.reset(std::deque<QPoint>(body.begin(), body.end()));
    m_state = Paused;
    
    emit scoreChanged();
    emit stateChanged();
    emit obstaclesChanged();
    emit foodChanged();
    emit hasSaveChanged();
}

void GameLogic::saveCurrentState() {
    QVariantList bodyVar;
    for (const auto &p : m_snakeModel.body()) bodyVar.append(p);
    m_settings.setValue("saved_body", bodyVar);

    QVariantList obsVar;
    for (const auto &p : m_obstacles) obsVar.append(p);
    m_settings.setValue("saved_obstacles", obsVar);

    m_settings.setValue("saved_score", m_score);
    m_settings.setValue("saved_food", m_food);
    m_settings.setValue("saved_dir", m_direction);
    
    emit hasSaveChanged();
}

void GameLogic::clearSavedState() {
    m_settings.remove("saved_body");
    m_settings.remove("saved_obstacles");
    emit hasSaveChanged();
}

bool GameLogic::hasSave() const noexcept {
    return m_settings.contains("saved_body");
}

void GameLogic::move(const int dx, const int dy) {
    if (m_state != Playing) return;
    if ((dx != 0 && m_direction.x() == -dx) || (dy != 0 && m_direction.y() == -dy)) return;
    m_direction = {dx, dy};
    m_soundManager->playBeep(200, 50);
}

void GameLogic::update() {
    if (m_state != Playing) return;
    const auto &body = m_snakeModel.body();
    const QPoint nextHead = body.front() + m_direction;

    if (isOutOfBounds(nextHead) || std::ranges::contains(body, nextHead) || std::ranges::contains(m_obstacles, nextHead)) {
        m_state = GameOver;
        m_timer->stop();
        updateHighScore();
        clearSavedState();
        m_soundManager->playCrash(500);
        emit stateChanged();
        emit requestFeedback();
        return;
    }

    const bool grew = (nextHead == m_food);
    if (grew) {
        m_score++;
        m_timer->setInterval(std::max(50, 150 - (m_score / 5) * 10));
        m_soundManager->playBeep(880, 100);

        if (m_score % 10 == 0) {
            bool valid = false;
            while (!valid) {
                const QPoint obs(QRandomGenerator::global()->bounded(BOARD_WIDTH),
                                 QRandomGenerator::global()->bounded(BOARD_HEIGHT));
                if (!std::ranges::contains(body, obs) && obs != m_food && !std::ranges::contains(m_obstacles, obs)) {
                    m_obstacles.append(obs);
                    valid = true;
                }
            }
            emit obstaclesChanged();
        }
        emit scoreChanged();
        spawnFood();
        emit requestFeedback();
    }
    m_snakeModel.moveHead(nextHead, grew);
}

void GameLogic::nextPalette() {
    m_paletteIndex = (m_paletteIndex + 1) % 4;
    m_settings.setValue("paletteIndex", m_paletteIndex);
    emit paletteChanged();
    m_soundManager->playBeep(600, 50);
}

void GameLogic::nextShellColor() {
    m_shellIndex = (m_shellIndex + 1) % 5;
    m_settings.setValue("shellIndex", m_shellIndex);
    emit shellColorChanged();
    m_soundManager->playBeep(500, 50);
}

QVariantList GameLogic::palette() const noexcept {
    static const QList<QVariantList> palettes = {
        {"#9bbc0f", "#8bac0f", "#306230", "#0f380f"},
        {"#c4cfa1", "#8b956d", "#4d533c", "#1f1f1f"},
        {"#70a0d0", "#4070a0", "#204060", "#001020"},
        {"#ffffff", "#aaaaaa", "#555555", "#000000"}
    };
    return palettes[m_paletteIndex];
}

QVariantList GameLogic::obstacles() const noexcept {
    QVariantList list;
    for (const auto &p : m_obstacles) list.append(p);
    return list;
}

QColor GameLogic::shellColor() const noexcept {
    static const QList<QColor> colors = {
        "#c0c0c0", "#f0f0f0", "#9370db", "#ffd700", "#32cd32"
    };
    return colors[m_shellIndex];
}

void GameLogic::updateHighScore() {
    if (m_score > m_highScore) {
        m_highScore = m_score;
        m_settings.setValue("highScore", m_highScore);
        emit highScoreChanged();
    }
}

void GameLogic::spawnFood() {
    const auto &body = m_snakeModel.body();
    bool foodIsInvalid = true;
    while (foodIsInvalid) {
        m_food = QPoint(QRandomGenerator::global()->bounded(BOARD_WIDTH),
                        QRandomGenerator::global()->bounded(BOARD_HEIGHT));
        foodIsInvalid = std::ranges::contains(body, m_food) || std::ranges::contains(m_obstacles, m_food);
    }
    emit foodChanged();
}

auto GameLogic::isOutOfBounds(const QPoint &p) noexcept -> bool {
    return !m_boardRect.contains(p);
}
