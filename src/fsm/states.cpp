#include "states.h"
#include "../game_logic.h"
#include "../sound_manager.h"
#include <QRandomGenerator>
#include <algorithm>
#include <ranges>

// --- SplashState ---
void SplashState::enter() {
    m_context.setInternalState(GameLogic::Splash);
    m_context.m_timer->start(150); 
    m_context.m_soundManager->playBeep(1046, 100); 
}

void SplashState::update() {
    static int splashFrames = 0;
    splashFrames++;
    if (splashFrames > 10) {
        splashFrames = 0;
        m_context.changeState(std::make_unique<MenuState>(m_context));
    }
}

// --- MenuState ---
void MenuState::enter() {
    m_context.setInternalState(GameLogic::StartMenu);
    m_context.m_soundManager->startMusic();
}

void MenuState::handleStart() {
    m_context.m_soundManager->stopMusic();
    m_context.startGame();
}

void MenuState::handleSelect() {
    if (m_context.hasSave()) {
        m_context.loadLastSession();
    } else {
        m_context.nextLevel();
    }
}

// --- PlayingState ---
void PlayingState::enter() {
    m_context.setInternalState(GameLogic::Playing);
    m_context.m_timer->start();
}

void PlayingState::update() {
    auto& logic = m_context;

    // --- 核心优化：从指令缓冲中取出方向 ---
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
    
    if (logic.m_ghostFrameIndex < logic.m_bestRecording.size()) {
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

void PlayingState::handleInput(int dx, int dy) {
    // move() 已经处理了队列逻辑
}

void PlayingState::handleStart() {
    m_context.togglePause();
}

// --- PausedState ---
void PausedState::enter() {
    m_context.setInternalState(GameLogic::Paused);
    m_context.m_timer->stop();
    m_context.saveCurrentState();
    emit m_context.requestFeedback(2);
}

void PausedState::handleStart() {
    m_context.togglePause();
}

// --- GameOverState ---
void GameOverState::enter() {
    m_context.setInternalState(GameLogic::GameOver);
}

void GameOverState::handleStart() {
    m_context.restart();
}
