#include "states.h"
#include "../game_logic.h"
#include <QRandomGenerator>
#include <algorithm>
#include <ranges>

namespace {
    constexpr int SplashFramesMax = 10;
    constexpr int BuffDurationMs = 8000;
}

// --- SplashState ---
auto SplashState::enter() -> void {
    m_context.setInternalState(GameLogic::Splash);
    QTimer::singleShot(100, [this]() { m_context.lazyInit(); });
    m_context.m_timer->start(150); 
}

auto SplashState::update() -> void {
    static int splashFrames = 0;
    splashFrames++;
    if (splashFrames > SplashFramesMax) {
        splashFrames = 0;
        m_context.changeState(std::make_unique<MenuState>(m_context));
    }
}

// --- MenuState ---
auto MenuState::enter() -> void {
    m_context.setInternalState(GameLogic::StartMenu);
}

auto MenuState::handleStart() -> void {
    if (m_context.hasSave()) m_context.loadLastSession();
    else m_context.startGame();
}

auto MenuState::handleSelect() -> void {
    m_context.nextLevel();
}

// --- PlayingState ---
auto PlayingState::enter() -> void {
    m_context.setInternalState(GameLogic::Playing);
    m_context.m_timer->start();
    m_context.m_ghostFrameIndex = 0; // Reset ghost index on start
}

auto PlayingState::update() -> void {
    auto& logic = m_context;
    
    // Apply buffered input from queue
    if (!logic.m_inputQueue.empty()) {
        logic.m_direction = logic.m_inputQueue.front();
        logic.m_inputQueue.pop_front();
        // Record EXACTLY when input is consumed/applied
        logic.m_currentInputHistory.append({logic.m_gameTickCounter, logic.m_direction.x(), logic.m_direction.y()});
    }

    const auto &body = logic.m_snakeModel.body();
    if (body.empty()) return;
    const QPoint nextHead = body.front() + logic.m_direction;

    if (logic.m_activeBuff == GameLogic::Magnet) {
        if (std::abs(logic.m_food.x() - nextHead.x()) <= 1 && std::abs(logic.m_food.y() - nextHead.y()) <= 1) {
            logic.m_food = nextHead;
        }
    }

    bool collision = GameLogic::isOutOfBounds(nextHead);
    if (!collision) {
        for (const auto &p : logic.m_obstacles) { if (p == nextHead) { collision = true; break; } }
    }
    if (!collision && logic.m_activeBuff != GameLogic::Ghost) {
        for (const auto &p : body) { if (p == nextHead) { collision = true; break; } }
    }

    if (collision) {
        logic.m_timer->stop();
        logic.m_buffTimer->stop();
        logic.updateHighScore();
        logic.incrementCrashes();
        logic.clearSavedState();
        emit logic.playerCrashed();
        emit logic.requestFeedback(8);
        logic.changeState(std::make_unique<GameOverState>(logic));
        return;
    }

    // Record position for Ghost rendering
    logic.m_currentRecording.append(nextHead);
    if (logic.m_ghostFrameIndex < static_cast<int>(logic.m_bestRecording.size())) {
        logic.m_ghostFrameIndex++;
        emit logic.ghostChanged();
    }

    const bool ateFood = (nextHead == logic.m_food);
    const bool atePowerUp = (nextHead == logic.m_powerUpPos);

    if (ateFood) {
        logic.m_score++;
        logic.logFoodEaten();
        float pan = (static_cast<float>(nextHead.x()) / GameLogic::BOARD_WIDTH - 0.5f) * 1.4f;
        emit logic.foodEaten(pan);
        logic.m_timer->setInterval(std::max(60, 200 - (logic.m_score / 5) * 8));
        emit logic.scoreChanged();
        logic.spawnFood();
        if (logic.m_rng.bounded(100) < 15 && logic.m_powerUpPos == QPoint(-1, -1)) {
            logic.spawnPowerUp();
        }
        emit logic.requestFeedback(std::min(5, 2 + (logic.m_score / 10)));
    }

    if (atePowerUp) {
        auto pType = static_cast<GameLogic::PowerUp>(logic.m_powerUpType);
        logic.m_activeBuff = pType;
        logic.logPowerUpTriggered(pType);
        logic.m_powerUpPos = QPoint(-1, -1);
        logic.m_buffTimer->start(BuffDurationMs);
        emit logic.powerUpEaten();
        if (logic.m_activeBuff == GameLogic::Slow) logic.m_timer->setInterval(250);
        emit logic.buffChanged();
        emit logic.powerUpChanged();
    }

    logic.checkAchievements();
    logic.m_snakeModel.moveHead(nextHead, ateFood);
}

auto PlayingState::handleInput(int /*dx*/, int /*dy*/) -> void {}
auto PlayingState::handleStart() -> void { m_context.togglePause(); }

// --- ReplayingState ---
auto ReplayingState::enter() -> void {
    m_context.setInternalState(GameLogic::Replaying);
    m_context.m_timer->start();
}

auto ReplayingState::update() -> void {
    auto& logic = m_context;
    
    // Optimized playback: No full scan per frame
    static int historyIdx = 0;
    if (logic.m_gameTickCounter == 0) historyIdx = 0;

    while (historyIdx < logic.m_bestInputHistory.size()) {
        const auto &f = logic.m_bestInputHistory[historyIdx];
        if (f.frame == logic.m_gameTickCounter) {
            logic.m_direction = QPoint(f.dx, f.dy);
            historyIdx++;
        } else if (f.frame > logic.m_gameTickCounter) {
            break; // Not time yet
        } else {
            historyIdx++; // Skip missed frame
        }
    }

    const auto &body = logic.m_snakeModel.body();
    if (body.empty()) return;
    const QPoint nextHead = body.front() + logic.m_direction;

    // No collisions should occur in a valid replay
    // But we check for safety or if logic version changed
    bool collision = GameLogic::isOutOfBounds(nextHead);
    if (!collision) {
        for (const auto &p : logic.m_obstacles) { if (p == nextHead) { collision = true; break; } }
    }
    if (!collision && logic.m_activeBuff != GameLogic::Ghost) {
        for (const auto &p : body) { if (p == nextHead) { collision = true; break; } }
    }

    if (collision) {
        logic.m_timer->stop();
        emit logic.playerCrashed();
        logic.changeState(std::make_unique<MenuState>(logic));
        return;
    }

    const bool ateFood = (nextHead == logic.m_food);
    const bool atePowerUp = (nextHead == logic.m_powerUpPos);

    if (ateFood) {
        logic.m_score++;
        emit logic.foodEaten(0.0f);
        logic.m_timer->setInterval(std::max(60, 200 - (logic.m_score / 5) * 8));
        emit logic.scoreChanged();
        logic.spawnFood();
        if (logic.m_rng.bounded(100) < 15 && logic.m_powerUpPos == QPoint(-1, -1)) {
            logic.spawnPowerUp();
        }
    }

    if (atePowerUp) {
        logic.m_activeBuff = static_cast<GameLogic::PowerUp>(logic.m_powerUpType);
        logic.m_powerUpPos = QPoint(-1, -1);
        logic.m_buffTimer->start(BuffDurationMs);
        emit logic.powerUpEaten();
        if (logic.m_activeBuff == GameLogic::Slow) logic.m_timer->setInterval(250);
        emit logic.buffChanged();
        emit logic.powerUpChanged();
    }

    logic.m_snakeModel.moveHead(nextHead, ateFood);
}

auto ReplayingState::handleStart() -> void {
    m_context.changeState(std::make_unique<MenuState>(m_context));
}

// --- PausedState ---
auto PausedState::enter() -> void {
    m_context.setInternalState(GameLogic::Paused);
    m_context.m_timer->stop();
    m_context.m_buffTimer->stop();
    m_context.saveCurrentState();
    emit m_context.requestFeedback(2);
}

auto PausedState::handleStart() -> void {
    m_context.togglePause();
}

// --- GameOverState ---
void GameOverState::enter() {
    m_context.setInternalState(GameLogic::GameOver);
}

void GameOverState::handleStart() {
    m_context.restart();
}
