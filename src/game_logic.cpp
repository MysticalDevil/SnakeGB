#include "game_logic.h"

#include <algorithm>
#include <ranges>

GameLogic::GameLogic(QObject *parent) : QObject(parent), m_timer(new QTimer(this)) {
    connect(m_timer, &QTimer::timeout, this, &GameLogic::update);

    QSettings settings("MyCompany", "SnakeGB");
    m_highScore = settings.value("highScore", 0).toInt();

    m_currentBody = {{10, 10}, {10, 11}, {10, 12}};
    m_snakeModel.reset(m_currentBody);
    m_direction = {0, -1};
    spawnFood();
}

void GameLogic::startGame() { restart(); }

void GameLogic::restart() {
    m_currentBody = {{10, 10}, {10, 11}, {10, 12}};
    m_snakeModel.reset(m_currentBody);
    m_direction = {0, -1};
    m_score = 0;
    m_currentInterval = 150;
    m_state = Playing;

    m_timer->setInterval(m_currentInterval);
    spawnFood();
    m_timer->start();

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

void GameLogic::move(int dx, int dy) {
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

    QPoint head = m_currentBody.front() + m_direction;

    // 优化：使用 C++23 ranges
    bool selfCollision = std::ranges::any_of(m_currentBody, [&](const auto &p) -> bool { return p == head; });

    if (isOutOfBounds(head) || selfCollision) {
        m_state = GameOver;
        m_timer->stop();
        updateHighScore();
        emit stateChanged();
        emit requestFeedback();
        return;
    }

    bool grew = (head == m_food);
    m_currentBody.push_front(head);
    if (grew) {
        m_score++;
        if (m_score % 5 == 0 && m_currentInterval > 50) {
            m_currentInterval -= 10;
            m_timer->setInterval(m_currentInterval);
        }
        emit scoreChanged();
        spawnFood();
        emit requestFeedback();
    } else {
        m_currentBody.pop_back();
    }

    m_snakeModel.moveHead(head, grew);
}

void GameLogic::updateHighScore() {
    if (m_score > m_highScore) {
        m_highScore = m_score;
        QSettings settings("MyCompany", "SnakeGB");
        settings.setValue("highScore", m_highScore);
        emit highScoreChanged();
    }
}

void GameLogic::spawnFood() {
    bool onSnake = true;
    while (onSnake) {
        m_food = {QRandomGenerator::global()->bounded(boardWidth()),
                  QRandomGenerator::global()->bounded(boardHeight())};
        // 优化：使用 C++23 ranges
        onSnake = std::ranges::any_of(m_currentBody, [&](const auto &p) -> bool { return p == m_food; });
    }
    emit foodChanged();
}

auto GameLogic::isOutOfBounds(const QPoint &p) const noexcept -> bool {
    return p.x() < 0 || p.x() >= boardWidth() || p.y() < 0 || p.y() >= boardHeight();
}
