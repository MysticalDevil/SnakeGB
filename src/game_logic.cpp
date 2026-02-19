#include "game_logic.h"
#include <algorithm>
#include <ranges>

GameLogic::GameLogic(QObject *parent) : QObject(parent), m_timer(std::make_unique<QTimer>()) {
    connect(m_timer.get(), &QTimer::timeout, this, &GameLogic::update);
    m_highScore = m_settings.value("highScore", 0).toInt();

    m_snakeModel.reset({{10, 10}, {10, 11}, {10, 12}});
    spawnFood();
}

void GameLogic::startGame() { restart(); }

void GameLogic::restart() {
    m_snakeModel.reset({{10, 10}, {10, 11}, {10, 12}});
    m_direction = {0, -1};
    m_score = 0;
    m_state = Playing;

    m_timer->start(150);
    spawnFood();

    emit scoreChanged();
    emit stateChanged();
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
    if (m_state != Playing) {
        return;
    }

    if ((dx != 0 && m_direction.x() == -dx) || (dy != 0 && m_direction.y() == -dy)) {
        return;
    }

    m_direction = {dx, dy};
}

void GameLogic::update() {
    if (m_state != Playing) {
        return;
    }

    const auto &body = m_snakeModel.body();
    const QPoint nextHead = body.front() + m_direction;

    const bool selfCollision =
        std::ranges::any_of(body, [&](const auto &p) -> bool { return p == nextHead; });

    if (isOutOfBounds(nextHead) || selfCollision) {
        m_state = GameOver;
        m_timer->stop();
        updateHighScore();
        emit stateChanged();
        emit requestFeedback();
        return;
    }

    const bool grew = (nextHead == m_food);
    if (grew) {
        m_score++;
        const int newInterval = std::max(50, 150 - (m_score / 5) * 10);
        m_timer->setInterval(newInterval);

        emit scoreChanged();
        spawnFood();
        emit requestFeedback();
    }

    m_snakeModel.moveHead(nextHead, grew);
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
        m_food = {QRandomGenerator::global()->bounded(BOARD_WIDTH),
                  QRandomGenerator::global()->bounded(BOARD_HEIGHT)};
        onSnake = std::ranges::any_of(body, [&](const auto &p) -> bool { return p == m_food; });
    }
    emit foodChanged();
}

auto GameLogic::isOutOfBounds(const QPoint &p) noexcept -> bool {
    return !m_boardRect.contains(p);
}
