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
    auto &queue = m_context.inputQueue();
    if (!queue.empty()) {
        m_context.direction() = queue.front();
        queue.pop_front();
        m_context.currentInputHistory().append(
            {.frame=m_context.gameTickCounter(), .dx=m_context.direction().x(), .dy=m_context.direction().y()});
    }

    const QPoint nextHead = m_context.snakeModel()->body().front() + m_context.direction();
    if (m_context.checkCollision(nextHead)) {
        m_context.triggerHaptic(8);
        m_context.playEventSound(1);
        m_context.requestStateChange(IGameEngine::GameOver);
        return;
    }

    const bool grew = (nextHead == m_context.foodPos());
    m_context.handleFoodConsumption(nextHead);

    // Eating food can switch state (e.g. LevelUp choice). Once state changed,
    // this PlayingState instance may already be invalidated by FSM replacement.
    if (m_context.currentState() != IGameEngine::Playing) {
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
    auto &bestChoices = m_context.bestChoiceHistory();
    while (m_choiceHistoryIndex < bestChoices.size()) {
        const auto &choice = bestChoices[m_choiceHistoryIndex];
        if (choice.frame == m_context.gameTickCounter()) {
            m_context.selectChoice(choice.index);
            m_choiceHistoryIndex++;
            break;
        } else if (choice.frame > m_context.gameTickCounter()) {
            break;
        } else {
            m_choiceHistoryIndex++;
        }
    }

    auto &bestHistory = m_context.bestInputHistory();
    while (m_historyIndex < bestHistory.size()) {
        const auto &frame = bestHistory[m_historyIndex];
        if (frame.frame == m_context.gameTickCounter()) {
            m_context.direction() = QPoint(frame.dx, frame.dy);
            m_historyIndex++;
        } else if (frame.frame > m_context.gameTickCounter()) {
            break;
        } else {
            m_historyIndex++;
        }
    }

    const QPoint nextHead = m_context.snakeModel()->body().front() + m_context.direction();
    if (m_context.checkCollision(nextHead)) {
        m_context.requestStateChange(IGameEngine::StartMenu);
        return;
    }

    const bool grew = (nextHead == m_context.foodPos());
    m_context.handleFoodConsumption(nextHead);
    m_context.handlePowerUpConsumption(nextHead);
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
