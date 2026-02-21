#include "states.h"
#include "../game_logic.h"

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
    QPoint nextInput;
    if (m_context.consumeQueuedInput(nextInput)) {
        m_context.setDirection(nextInput);
        m_context.recordInputAtCurrentTick(nextInput);
    }

    const QPoint nextHead = m_context.headPosition() + m_context.currentDirection();
    if (m_context.checkCollision(nextHead)) {
        m_context.triggerHaptic(8);
        m_context.playEventSound(1);
        m_context.requestStateChange(IGameEngine::GameOver);
        return;
    }

    const bool grew = (nextHead == m_context.foodPos());
    m_context.handleFoodConsumption(nextHead);

    // Stop this frame as soon as a state switch is requested (immediate or deferred).
    if (m_context.currentState() != IGameEngine::Playing || m_context.hasPendingStateChange()) {
        return;
    }

    m_context.handlePowerUpConsumption(nextHead);
    m_context.applyMovement(nextHead, grew);
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

// --- GameOver State ---
void GameOverState::enter() {
    m_context.setInternalState(IGameEngine::GameOver);
    m_context.updatePersistence();
}

void GameOverState::handleStart() {
    m_context.restart();
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

// --- Replaying State ---
void ReplayingState::enter() {
    m_context.setInternalState(IGameEngine::Replaying);
    m_historyIndex = 0;
    m_choiceHistoryIndex = 0;
}

void ReplayingState::update() {
    // First, replay recorded roguelike choices at their exact frame.
    while (m_choiceHistoryIndex < m_context.bestChoiceHistorySize()) {
        int frame = 0;
        int choiceIndex = 0;
        if (!m_context.bestChoiceAt(m_choiceHistoryIndex, frame, choiceIndex)) {
            break;
        }
        if (frame == m_context.currentTick()) {
            m_context.selectChoice(choiceIndex);
            m_choiceHistoryIndex++;
            break;
        } else if (frame > m_context.currentTick()) {
            break;
        } else {
            m_choiceHistoryIndex++;
        }
    }

    // Then, replay movement input for the same tick timeline.
    while (m_historyIndex < m_context.bestInputHistorySize()) {
        int frame = 0;
        int dx = 0;
        int dy = 0;
        if (!m_context.bestInputFrameAt(m_historyIndex, frame, dx, dy)) {
            break;
        }
        if (frame == m_context.currentTick()) {
            m_context.setDirection(QPoint(dx, dy));
            m_historyIndex++;
        } else if (frame > m_context.currentTick()) {
            break;
        } else {
            m_historyIndex++;
        }
    }

    // Run normal step simulation using replay-driven direction.
    const QPoint nextHead = m_context.headPosition() + m_context.currentDirection();
    if (m_context.checkCollision(nextHead)) {
        m_context.requestStateChange(IGameEngine::StartMenu);
        return;
    }

    const bool grew = (nextHead == m_context.foodPos());
    m_context.handleFoodConsumption(nextHead);
    if (m_context.currentState() != IGameEngine::Replaying || m_context.hasPendingStateChange()) {
        return;
    }
    m_context.handlePowerUpConsumption(nextHead);
    if (m_context.currentState() != IGameEngine::Replaying || m_context.hasPendingStateChange()) {
        return;
    }
    m_context.applyMovement(nextHead, grew);
}

void ReplayingState::handleStart() {
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
