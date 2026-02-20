#include "states.h"
#include "../game_logic.h"

// --- Splash State ---
void SplashState::enter() {
    m_context.setInternalState(GameLogic::Splash);
    m_frames = 0;
}

void SplashState::update() {
    m_frames++;
    if (m_frames > 80) {
        m_context.requestStateChange(GameLogic::StartMenu);
    }
}

// --- Menu State ---
void MenuState::enter() {
    m_context.setInternalState(GameLogic::StartMenu);
}

void MenuState::handleStart() {
    if (m_context.hasSave()) {
        m_context.loadLastSession();
    } else {
        m_context.restart();
    }
}

void MenuState::handleSelect() {
    m_context.nextLevel();
}

void MenuState::handleInput(int dx, int dy) {
    if (dy < 0) {
        m_context.requestStateChange(GameLogic::MedalRoom);
    } else if (dy > 0) {
        if (m_context.hasReplay()) {
            m_context.startReplay();
        }
    } else if (dx > 0) {
        m_context.nextPalette();
    } else if (dx < 0) {
        m_context.nextShellColor();
    }
}

// --- Playing State ---
void PlayingState::enter() {
    m_context.setInternalState(GameLogic::Playing);
}

void PlayingState::update() {
}

void PlayingState::handleInput(int /*dx*/, int /*dy*/) {
}

void PlayingState::handleStart() {
    m_context.requestStateChange(GameLogic::Paused);
}

// --- Paused State ---
void PausedState::enter() {
    m_context.setInternalState(GameLogic::Paused);
}

void PausedState::handleStart() {
    m_context.requestStateChange(GameLogic::Playing);
}

// --- GameOver State ---
void GameOverState::enter() {
    m_context.setInternalState(GameLogic::GameOver);
    m_context.updatePersistence();
}

void GameOverState::handleStart() {
    m_context.restart();
}

// --- Choice State ---
void ChoiceState::enter() {
    m_context.setInternalState(GameLogic::ChoiceSelection);
    m_context.generateChoices();
}

void ChoiceState::handleInput(int /*dx*/, int dy) {
    if (dy > 0) {
        int next = (m_context.choiceIndex() + 1) % 3;
        m_context.setChoiceIndex(next);
    } else if (dy < 0) {
        int prev = (m_context.choiceIndex() + 2) % 3;
        m_context.setChoiceIndex(prev);
    }
}

void ChoiceState::handleStart() {
    m_context.selectChoice(m_context.choiceIndex());
}

// --- Replaying State ---
void ReplayingState::enter() {
    m_context.setInternalState(GameLogic::Replaying);
}

void ReplayingState::handleStart() {
    m_context.requestStateChange(GameLogic::StartMenu);
}

// --- Library & Medal Room ---
void LibraryState::enter() {
    m_context.setInternalState(GameLogic::Library);
}

void LibraryState::handleSelect() {
    m_context.requestStateChange(GameLogic::StartMenu);
}

void MedalRoomState::enter() {
    m_context.setInternalState(GameLogic::MedalRoom);
}

void MedalRoomState::handleSelect() {
    m_context.requestStateChange(GameLogic::StartMenu);
}
