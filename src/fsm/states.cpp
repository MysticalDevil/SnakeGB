#include "states.h"
#include "../game_logic.h"
#include "../sound_manager.h"
#include <QRandomGenerator>
#include <algorithm>
#include <ranges>

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
        m_context.nextLevel(); // 切换关卡
    }
}

// --- PlayingState ---
void PlayingState::enter() {
    m_context.setInternalState(GameLogic::Playing);
    m_context.m_timer->start();
}

void PlayingState::update() {
    auto& logic = m_context;
    const auto &body = logic.m_snakeModel.body();
    const QPoint nextHead = body.front() + logic.m_direction;

    if (GameLogic::isOutOfBounds(nextHead) || std::ranges::contains(body, nextHead) ||
        std::ranges::contains(logic.m_obstacles, nextHead)) {
        
        logic.m_timer->stop();
        logic.updateHighScore();
        logic.clearSavedState();
        logic.m_soundManager->playCrash(500);
        emit logic.requestFeedback();
        
        logic.changeState(std::make_unique<GameOverState>(logic));
        return;
    }

    const bool grew = (nextHead == logic.m_food);
    if (grew) {
        logic.m_score++;
        logic.m_timer->setInterval(std::max(50, 150 - (logic.m_score / 5) * 10));
        logic.m_soundManager->playBeep(880, 100);

        emit logic.scoreChanged();
        logic.spawnFood();
        emit logic.requestFeedback();
    }
    logic.m_snakeModel.moveHead(nextHead, grew);
}

void PlayingState::handleInput(int dx, int dy) {
    auto& logic = m_context;
    if ((dx != 0 && logic.m_direction.x() == -dx) || (dy != 0 && logic.m_direction.y() == -dy)) {
        return;
    }
    logic.m_direction = {dx, dy};
    logic.m_soundManager->playBeep(200, 50);
}

void PlayingState::handleStart() {
    m_context.togglePause();
}

// --- PausedState ---
void PausedState::enter() {
    m_context.setInternalState(GameLogic::Paused);
    m_context.m_timer->stop();
    m_context.saveCurrentState();
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
