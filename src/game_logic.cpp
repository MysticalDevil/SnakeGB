#include "game_logic.h"
#include <algorithm>

GameLogic::GameLogic(QObject *parent) 
    : QObject(parent), m_timer(new QTimer(this)) 
{
    connect(m_timer, &QTimer::timeout, this, &GameLogic::update);
    m_timer->setInterval(150);
    
    // 初始化显示
    m_currentBody = { {10, 10}, {10, 11}, {10, 12} };
    m_snakeModel.reset(m_currentBody);
    m_direction = {0, -1};
    spawnFood();
}

void GameLogic::startGame() {
    restart();
}

void GameLogic::restart() {
    m_currentBody = { {10, 10}, {10, 11}, {10, 12} };
    m_snakeModel.reset(m_currentBody);
    m_direction = {0, -1};
    m_score = 0;
    m_state = Playing;
    spawnFood();
    m_timer->start();
    emit scoreChanged();
    emit stateChanged();
}

void GameLogic::move(int dx, int dy) {
    if (m_state != Playing) return;
    if ((dx != 0 && m_direction.x() == -dx) || (dy != 0 && m_direction.y() == -dy)) return;
    
    m_direction = {dx, dy};
    emit requestFeedback(); // 按键触发反馈信号
}

void GameLogic::update() {
    if (m_state != Playing) return;

    QPoint head = m_currentBody.front() + m_direction;

    // 碰撞检测
    auto it = std::find(m_currentBody.begin(), m_currentBody.end(), head);
    if (isOutOfBounds(head) || it != m_currentBody.end()) {
        m_state = GameOver;
        m_timer->stop();
        emit stateChanged();
        emit requestFeedback(); // 死亡反馈
        return;
    }

    bool grew = (head == m_food);
    m_currentBody.push_front(head);
    if (grew) {
        m_score++;
        emit scoreChanged();
        spawnFood();
        emit requestFeedback(); // 吃到食物反馈
    } else {
        m_currentBody.pop_back();
    }

    m_snakeModel.moveHead(head, grew);
}

void GameLogic::spawnFood() {
    bool onSnake = true;
    while (onSnake) {
        m_food = {QRandomGenerator::global()->bounded(boardWidth()),
                  QRandomGenerator::global()->bounded(boardHeight())};
        auto it = std::find(m_currentBody.begin(), m_currentBody.end(), m_food);
        onSnake = (it != m_currentBody.end());
    }
    emit foodChanged();
}

bool GameLogic::isOutOfBounds(const QPoint &p) const noexcept {
    return p.x() < 0 || p.x() >= boardWidth() || p.y() < 0 || p.y() >= boardHeight();
}
