#include "states.h"
#include "../game_logic.h"
#include "../sound_manager.h"
#include <QRandomGenerator>
#include <algorithm>
#include <ranges>

namespace {
    constexpr int SplashFramesMax = 10;
    constexpr int BootBeepFreq = 1046;
    constexpr int BootBeepDuration = 100;
    constexpr int BuffDurationMs = 8000;
}

// --- SplashState ---
auto SplashState::enter() -> void {
    m_context.setInternalState(GameLogic::Splash);
    GameLogic& logic = m_context;
    QTimer::singleShot(100, [&logic]() { logic.lazyInit(); });
    m_context.m_timer->start(150); 
    if (m_context.m_soundManager) {
        m_context.m_soundManager->playBeep(BootBeepFreq, BootBeepDuration); 
    }
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
    if (m_context.m_soundManager) {
        m_context.m_soundManager->startMusic();
    }
}

auto MenuState::handleStart() -> void {
    if (m_context.m_soundManager) {
        m_context.m_soundManager->stopMusic();
    }
    if (m_context.hasSave()) {
        m_context.loadLastSession();
    } else {
        m_context.startGame();
    }
}

auto MenuState::handleSelect() -> void {
    m_context.nextLevel();
}

// --- PlayingState ---
auto PlayingState::enter() -> void {
    m_context.setInternalState(GameLogic::Playing);
    m_context.m_timer->start();
}

auto PlayingState::update() -> void {
    auto& logic = m_context;
    if (!logic.m_inputQueue.empty()) {
        logic.m_direction = logic.m_inputQueue.front();
        logic.m_inputQueue.pop_front();
    }

    const auto &body = logic.m_snakeModel.body();
    if (body.empty()) return;
    const QPoint nextHead = body.front() + logic.m_direction;

    if (logic.m_activeBuff == GameLogic::Magnet) {
        if (std::abs(logic.m_food.x() - nextHead.x()) <= 1 && std::abs(logic.m_food.y() - nextHead.y()) <= 1) {
            logic.m_food = nextHead;
        }
    }

    bool collision = GameLogic::isOutOfBounds(nextHead) || std::ranges::contains(logic.m_obstacles, nextHead);
    if (logic.m_activeBuff != GameLogic::Ghost) {
        collision = collision || std::ranges::contains(body, nextHead);
    }

    if (collision) {
        logic.m_timer->stop();
        logic.m_buffTimer->stop();
        logic.updateHighScore();
        logic.incrementCrashes();
        logic.clearSavedState();
        if (logic.m_soundManager) logic.m_soundManager->playCrash(500);
        emit logic.requestFeedback(8);
        logic.changeState(std::make_unique<GameOverState>(logic));
        return;
    }

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
        if (logic.m_soundManager) {
            logic.m_soundManager->setScore(logic.m_score);
            // Panning based on horizontal position (-0.7 to 0.7)
            float pan = (static_cast<float>(nextHead.x()) / GameLogic::BOARD_WIDTH - 0.5f) * 1.4f;
            logic.m_soundManager->playBeep(880, 100, pan);
        }
        logic.m_timer->setInterval(std::max(60, 200 - (logic.m_score / 5) * 8));
        emit logic.scoreChanged();
        logic.spawnFood();
        // Rare spawn chance (15%)
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
        if (logic.m_soundManager) logic.m_soundManager->playBeep(1200, 150);
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
    
    for (const auto &f : logic.m_bestInputHistory) {
        if (f.frame == logic.m_gameTickCounter) {
            logic.m_direction = QPoint(f.dx, f.dy);
        }
    }

    const auto &body = logic.m_snakeModel.body();
    if (body.empty()) return;
    const QPoint nextHead = body.front() + logic.m_direction;

    if (logic.m_activeBuff == GameLogic::Magnet) {
        if (std::abs(logic.m_food.x() - nextHead.x()) <= 1 && std::abs(logic.m_food.y() - nextHead.y()) <= 1) {
            logic.m_food = nextHead;
        }
    }

    bool collision = GameLogic::isOutOfBounds(nextHead) || std::ranges::contains(logic.m_obstacles, nextHead);
    if (logic.m_activeBuff != GameLogic::Ghost) {
        collision = collision || std::ranges::contains(body, nextHead);
    }

    if (collision) {
        logic.m_timer->stop();
        logic.m_soundManager->playCrash(500);
        logic.changeState(std::make_unique<MenuState>(logic));
        return;
    }

    const bool ateFood = (nextHead == logic.m_food);
    const bool atePowerUp = (nextHead == logic.m_powerUpPos);

    if (ateFood) {
        logic.m_score++;
        logic.m_timer->setInterval(std::max(50, 150 - (logic.m_score / 5) * 10));
        emit logic.scoreChanged();
        logic.spawnFood();
        // Matching replay spawn logic
        if (logic.m_rng.bounded(100) < 50 && logic.m_powerUpPos == QPoint(-1, -1)) {
            logic.spawnPowerUp();
        }
    }

    if (atePowerUp) {
        logic.m_activeBuff = static_cast<GameLogic::PowerUp>(logic.m_powerUpType);
        logic.m_powerUpPos = QPoint(-1, -1);
        logic.m_buffTimer->start(BuffDurationMs);
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
