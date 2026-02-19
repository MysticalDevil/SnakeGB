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
}

// --- SplashState ---
auto SplashState::enter() -> void {
    m_context.setInternalState(GameLogic::Splash);
    m_context.lazyInit(); // 异步加载大数据
    m_context.m_timer->start(150); 
    m_context.m_soundManager->playBeep(BootBeepFreq, BootBeepDuration); 
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
    m_context.m_soundManager->startMusic();
}

auto MenuState::handleStart() -> void {
    m_context.m_soundManager->stopMusic();
    m_context.startGame();
}

auto MenuState::handleSelect() -> void {
    if (m_context.hasSave()) {
        m_context.loadLastSession();
    } else {
        m_context.nextLevel();
    }
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
    const QPoint nextHead = body.front() + logic.m_direction;

    if (GameLogic::isOutOfBounds(nextHead) || std::ranges::contains(body, nextHead) ||
        std::ranges::contains(logic.m_obstacles, nextHead)) {
        
        logic.m_timer->stop();
        logic.updateHighScore();
        logic.clearSavedState();
        logic.m_soundManager->playCrash(500);
        emit logic.requestFeedback(8);
        logic.changeState(std::make_unique<GameOverState>(logic));
        return;
    }

    logic.m_currentRecording.append(nextHead);
    
    if (logic.m_ghostFrameIndex < static_cast<int>(logic.m_bestRecording.size())) {
        logic.m_ghostFrameIndex++;
        emit logic.ghostChanged();
    }

    const bool grew = (nextHead == logic.m_food);
    if (grew) {
        logic.m_score++;
        logic.m_timer->setInterval(std::max(50, 150 - (logic.m_score / 5) * 10));
        logic.m_soundManager->playBeep(880, 100);
        emit logic.scoreChanged();
        logic.spawnFood();
        emit logic.requestFeedback(std::min(5, 2 + (logic.m_score / 10)));
    }
    logic.m_snakeModel.moveHead(nextHead, grew);
}

auto PlayingState::handleInput(int /*dx*/, int /*dy*/) -> void {}

auto PlayingState::handleStart() -> void {
    m_context.togglePause();
}

// --- PausedState ---
auto PausedState::enter() -> void {
    m_context.setInternalState(GameLogic::Paused);
    m_context.m_timer->stop();
    m_context.saveCurrentState();
    emit m_context.requestFeedback(2);
}

auto PausedState::handleStart() -> void {
    m_context.togglePause();
}

// --- GameOverState ---
auto GameOverState::enter() -> void {
    m_context.setInternalState(GameLogic::GameOver);
}

auto GameOverState::handleStart() -> void {
    m_context.restart();
}
