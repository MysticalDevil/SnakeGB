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

    m_timer->start(150);
    spawnFood();

    // Start sound
    m_soundManager->playBeep(1000, 200);

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
    // Move sound
    m_soundManager->playBeep(200, 50);
}

void GameLogic::update() {
    if (m_state != Playing) {
        return;
    }

    const auto &body = m_snakeModel.body();
    const QPoint nextHead = body.front() + m_direction;

    const bool selfCollision = std::ranges::contains(body, nextHead);

    if (isOutOfBounds(nextHead) || selfCollision) {
        m_state = GameOver;
        m_timer->stop();
        updateHighScore();
        // Crash sound
        m_soundManager->playCrash(500);
        emit stateChanged();
        emit requestFeedback();
        return;
    }

    const bool grew = (nextHead == m_food);
    if (grew) {
        m_score++;
        const int newInterval = std::max(50, 150 - (m_score / 5) * 10);
        m_timer->setInterval(newInterval);
        
        // Eat sound
        m_soundManager->playBeep(880, 100);

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
        m_food = QPoint(QRandomGenerator::global()->bounded(BOARD_WIDTH),
                        QRandomGenerator::global()->bounded(BOARD_HEIGHT));
        onSnake = std::ranges::contains(body, m_food);
    }
    emit foodChanged();
}

auto GameLogic::isOutOfBounds(const QPoint &p) noexcept -> bool {
    return !m_boardRect.contains(p);
}
