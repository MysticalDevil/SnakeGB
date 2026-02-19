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

    m_snakeModel.reset({{10, 10}, {10, 11}, {10, 12}});
    spawnFood();
}

GameLogic::~GameLogic() = default;

void GameLogic::startGame() { restart(); }

void GameLogic::restart() {
    m_snakeModel.reset({{10, 10}, {10, 11}, {10, 12}});
    m_direction = {0, -1};
    m_score = 0;
    m_state = Playing;
    m_obstacles.clear();
    setupLevel();

    m_timer->start(150);
    spawnFood();
    m_soundManager->playBeep(1000, 200);

    emit scoreChanged();
    emit stateChanged();
    emit obstaclesChanged();
}

void GameLogic::setupLevel() {
    // Basic level: no obstacles initially. 
    // We could add preset levels here.
}

void GameLogic::togglePause() {
    if (m_state == Playing) {
        m_state = Paused;
        m_timer->stop();
    } else if (m_state == Paused) {
        m_state = Playing;
        m_timer->start();
    }
    emit stateChanged();
    emit requestFeedback();
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

    // Collision check: Wall, Self, and Obstacles
    bool hitObstacle = std::ranges::contains(m_obstacles, nextHead);
    if (isOutOfBounds(nextHead) || std::ranges::contains(body, nextHead) || hitObstacle) {
        m_state = GameOver;
        m_timer->stop();
        updateHighScore();
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

        // Every 10 points, add an obstacle
        if (m_score % 10 == 0) {
            bool valid = false;
            while (!valid) {
                QPoint obs(QRandomGenerator::global()->bounded(BOARD_WIDTH),
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

void GameLogic::updateHighScore() {
    if (m_score > m_highScore) {
        m_highScore = m_score;
        m_settings.setValue("highScore", m_highScore);
        emit highScoreChanged();
    }
}

void GameLogic::spawnFood() {
    const auto &body = m_snakeModel.body();
    bool onSnake = true;
    while (onSnake) {
        m_food = QPoint(QRandomGenerator::global()->bounded(BOARD_WIDTH),
                        QRandomGenerator::global()->bounded(BOARD_HEIGHT));
        onSnake = std::ranges::contains(body, m_food) || std::ranges::contains(m_obstacles, m_food);
    }
    emit foodChanged();
}

auto GameLogic::isOutOfBounds(const QPoint &p) noexcept -> bool {
    return !m_boardRect.contains(p);
}
