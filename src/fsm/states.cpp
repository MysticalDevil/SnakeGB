#include "states.h"
#include "../core/replay_timeline.h"
#include "../core/session_step.h"

// --- Splash State ---
void SplashState::enter() {
    m_context.setInternalState(IGameEngine::Splash);
    m_frames = 0;
    m_context.lazyInit();
    m_context.startEngineTimer(16); // ~60fps logic
}

void SplashState::update() {
    m_frames++;
    if (m_frames > 110) {
        m_context.playEventSound(3);
        m_context.requestStateChange(IGameEngine::StartMenu);
    }
}

// --- Menu State ---
void MenuState::enter() {
    m_context.setInternalState(IGameEngine::StartMenu);
    m_context.stopEngineTimer();
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
        m_context.requestStateChange(IGameEngine::MedalRoom);
    } else if (dy > 0) {
        if (m_context.hasReplay()) {
            m_context.startReplay();
        } else {
            m_context.playEventSound(3);
            m_context.triggerHaptic(2);
        }
    } else if (dx < 0) {
        m_context.requestStateChange(IGameEngine::Library);
    } else if (dx > 0) {
        m_context.nextPalette();
    }
}

// --- Playing State ---
void PlayingState::enter() {
    m_context.setInternalState(IGameEngine::Playing);
}

void PlayingState::update() {
    snakegb::core::runSessionStep(m_context, {
                                            .activeState = IGameEngine::Playing,
                                            .collisionTargetState = IGameEngine::GameOver,
                                            .consumeInputQueue = true,
                                            .recordConsumedInput = true,
                                            .emitCrashFeedbackOnCollision = true,
                                        });
}

void PlayingState::handleInput(int /*dx*/, int /*dy*/) {
    // Movement handled via queue in GameLogic
}

void PlayingState::handleStart() {
    m_context.requestStateChange(IGameEngine::Paused);
}

// --- Paused State ---
void PausedState::enter() {
    m_context.setInternalState(IGameEngine::Paused);
}

void PausedState::handleStart() {
    m_context.requestStateChange(IGameEngine::Playing);
}

void PausedState::handleSelect() {
    m_context.requestStateChange(IGameEngine::StartMenu);
}

// --- GameOver State ---
void GameOverState::enter() {
    m_context.setInternalState(IGameEngine::GameOver);
    m_context.updatePersistence();
}

void GameOverState::handleStart() {
    m_context.restart();
}

void GameOverState::handleSelect() {
    m_context.requestStateChange(IGameEngine::StartMenu);
}

// --- Choice State ---
void ChoiceState::enter() {
    m_context.setInternalState(IGameEngine::ChoiceSelection);
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

void ChoiceState::handleSelect() {
    m_context.requestStateChange(IGameEngine::StartMenu);
}

// --- Replaying State ---
void ReplayingState::enter() {
    m_context.setInternalState(IGameEngine::Replaying);
    m_historyIndex = 0;
    m_choiceHistoryIndex = 0;
}

void ReplayingState::update() {
    snakegb::core::applyReplayChoicesForCurrentTick(m_context, m_choiceHistoryIndex);
    snakegb::core::applyReplayInputsForCurrentTick(m_context, m_historyIndex);

    // Run normal step simulation using replay-driven direction.
    snakegb::core::runSessionStep(m_context, {
                                            .activeState = IGameEngine::Replaying,
                                            .collisionTargetState = IGameEngine::StartMenu,
                                            .consumeInputQueue = false,
                                            .recordConsumedInput = false,
                                            .emitCrashFeedbackOnCollision = false,
                                        });
}

void ReplayingState::handleStart() {
    m_context.requestStateChange(IGameEngine::StartMenu);
}

void ReplayingState::handleSelect() {
    m_context.requestStateChange(IGameEngine::StartMenu);
}

// --- Library & Medal Room ---
void LibraryState::enter() {
    m_context.setInternalState(IGameEngine::Library);
}

void LibraryState::handleInput(int /*dx*/, int dy) {
    const int count = m_context.fruitLibrarySize();
    if (count <= 0 || dy == 0) {
        return;
    }
    const int step = (dy > 0) ? 1 : -1;
    const int next = (m_context.libraryIndex() + step + count) % count;
    m_context.setLibraryIndex(next);
}

void LibraryState::handleSelect() {
    m_context.requestStateChange(IGameEngine::StartMenu);
}

void MedalRoomState::enter() {
    m_context.setInternalState(IGameEngine::MedalRoom);
}

void MedalRoomState::handleInput(int /*dx*/, int dy) {
    const int count = m_context.medalLibrarySize();
    if (count <= 0 || dy == 0) {
        return;
    }
    const int step = (dy > 0) ? 1 : -1;
    const int next = (m_context.medalIndex() + step + count) % count;
    m_context.setMedalIndex(next);
}

void MedalRoomState::handleSelect() {
    m_context.requestStateChange(IGameEngine::StartMenu);
}
