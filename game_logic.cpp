#include "game_logic.h"
#include <QVariantList>

GameLogic::GameLogic(QObject *parent) : QObject(parent), m_timer(new QTimer(this)) {
    connect(m_timer, &QTimer::timeout, this, &GameLogic::update);
    m_timer->setInterval(150);
    // Initial setup for visual background behind menu
    m_snakeBody = { {10, 10}, {10, 11}, {10, 12} };
    m_direction = {0, -1};
    spawnFood();
}

QVariantList GameLogic::snake() const {
    QVariantList list;
    for (const auto &p : m_snakeBody) {
        list.append(p);
    }
    return list;
}

void GameLogic::startGame() {
    m_state = Playing;
    restart();
    emit stateChanged();
}

void GameLogic::restart() {
    m_snakeBody = { {10, 10}, {10, 11}, {10, 12} };
    m_direction = {0, -1};
    m_score = 0;
    m_state = Playing;
    spawnFood();
    m_timer->start();
    emit snakeChanged();
    emit foodChanged();
    emit scoreChanged();
    emit stateChanged();
}

void GameLogic::move(int dx, int dy) {
    if (m_state != Playing) return;
    if ((dx != 0 && m_direction.x() == -dx) || (dy != 0 && m_direction.y() == -dy)) {
        return;
    }
    m_direction = {dx, dy};
}

void GameLogic::update() {
    if (m_state != Playing) return;

    QPoint head = m_snakeBody.first() + m_direction;

    if (isOutOfBounds(head) || m_snakeBody.contains(head)) {
        m_state = GameOver;
        m_timer->stop();
        emit stateChanged();
        return;
    }

    m_snakeBody.prepend(head);

    if (head == m_food) {
        m_score++;
        emit scoreChanged();
        spawnFood();
    } else {
        m_snakeBody.removeLast();
    }

    emit snakeChanged();
}

void GameLogic::spawnFood() {
    bool onSnake = true;
    while (onSnake) {
        m_food = {QRandomGenerator::global()->bounded(m_boardWidth),
                  QRandomGenerator::global()->bounded(m_boardHeight)};
        onSnake = m_snakeBody.contains(m_food);
    }
    emit foodChanged();
}

bool GameLogic::isOutOfBounds(const QPoint &p) const {
    return p.x() < 0 || p.x() >= m_boardWidth || p.y() < 0 || p.y() >= m_boardHeight;
}
