#include "states.h"
#include "../game_logic.h"
#include <QRandomGenerator>
#include <algorithm>

// Helper to access engine through the interface
static auto& engine(GameState& s) { 
    return static_cast<IGameEngine&>(s.context()); 
}

// --- SplashState ---

void SplashState::enter() { 
    auto& e = engine(*this);
    e.setInternalState(GameLogic::Splash); 
    e.lazyInit();
    e.startEngineTimer(100); 
}

void SplashState::exit() {
    engine(*this).stopEngineTimer();
}

void SplashState::update() {
    static int frames = 0;
    if (++frames > 30) { 
        frames = 0;
        engine(*this).requestStateChange(GameLogic::StartMenu);
    }
}

void SplashState::handleInput(int, int) {}
void SplashState::handleStart() {}

// --- MenuState ---

void MenuState::enter() { 
    engine(*this).setInternalState(GameLogic::StartMenu); 
}

void MenuState::exit() {}
void MenuState::update() {}

void MenuState::handleInput(int dx, int dy) {
    auto& e = engine(*this);
    if (dx == 0 && dy == 1) { // DOWN
        if (e.hasReplay()) {
            e.startReplay();
        } else {
            e.playEventSound(3); // Error beep
            e.triggerHaptic(2);  // Minor vibration pulse
        }
    } else if (dx == -1 && dy == 0) { // LEFT (Hidden Encyclopedia)
        e.requestStateChange(GameLogic::Library);
    }
}

void MenuState::handleStart() {
    auto& e = engine(*this);
    if (e.hasSave()) e.loadLastSession();
    else e.restart();
}

void MenuState::handleSelect() { 
    engine(*this).nextLevel(); 
}

// --- PlayingState ---

void PlayingState::enter() { 
    engine(*this).setInternalState(GameLogic::Playing); 
}

void PlayingState::exit() {}

void PlayingState::update() {
    auto& e = engine(*this);
    
    auto& queue = e.inputQueue();
    if (!queue.empty()) {
        e.direction() = queue.front();
        queue.pop_front();
        e.currentInputHistory().append({e.gameTickCounter(), e.direction().x(), e.direction().y()});
    }

    const QPoint nextHead = e.snakeModel()->body().front() + e.direction();

    if (e.checkCollision(nextHead)) {
        e.triggerHaptic(8);
        e.playEventSound(1); 
        e.updatePersistence();
        e.requestStateChange(GameLogic::GameOver);
        return;
    }

    bool grew = (nextHead == e.foodPos());
    e.handleFoodConsumption(nextHead);
    e.handlePowerUpConsumption(nextHead);
    e.applyMovement(nextHead, grew);
}

void PlayingState::handleInput(int, int) {}
void PlayingState::handleStart() { 
    engine(*this).togglePause(); 
}

// --- ReplayingState ---

void ReplayingState::enter() { 
    engine(*this).setInternalState(GameLogic::Replaying); 
}

void ReplayingState::exit() {}

void ReplayingState::update() {
    auto& e = engine(*this);
    static int inputIdx = 0;
    static int choiceIdx = 0;
    if (e.gameTickCounter() == 0) { inputIdx = 0; choiceIdx = 0; }

    // 1. Process Choices (Roguelike Auto-selection)
    auto& bestChoices = e.bestChoiceHistory();
    while (choiceIdx < bestChoices.size()) {
        const auto &c = bestChoices[choiceIdx];
        if (c.frame == e.gameTickCounter()) {
            e.generateChoices();
            e.selectChoice(c.index);
            choiceIdx++;
            return; 
        } else if (c.frame > e.gameTickCounter()) {
            break;
        } else {
            choiceIdx++;
        }
    }

    // 2. Process Movement
    auto& bestHistory = e.bestInputHistory();
    while (inputIdx < bestHistory.size()) {
        const auto &f = bestHistory[inputIdx];
        if (f.frame == e.gameTickCounter()) {
            e.direction() = QPoint(f.dx, f.dy);
            inputIdx++;
        } else if (f.frame > e.gameTickCounter()) {
            break; 
        } else {
            inputIdx++;
        }
    }

    const QPoint nextHead = e.snakeModel()->body().front() + e.direction();
    if (e.checkCollision(nextHead)) {
        engine(*this).requestStateChange(GameLogic::StartMenu);
        return;
    }

    bool grew = (nextHead == e.foodPos());
    e.handleFoodConsumption(nextHead);
    e.handlePowerUpConsumption(nextHead);
    e.applyMovement(nextHead, grew);
}

void ReplayingState::handleInput(int, int) {}
void ReplayingState::handleStart() { 
    engine(*this).requestStateChange(GameLogic::StartMenu); 
}

// --- ChoiceState ---
void ChoiceState::enter() { 
    auto& e = engine(*this);
    e.setInternalState(GameLogic::ChoiceSelection); 
    e.setChoiceIndex(0);
    e.generateChoices();
}
void ChoiceState::exit() {}
void ChoiceState::update() {}
void ChoiceState::handleInput(int dx, int dy) {
    if (dy != 0) {
        auto& e = engine(*this);
        int current = e.choiceIndex();
        int next = (current + (dy > 0 ? 1 : 2)) % 3;
        e.setChoiceIndex(next);
        e.triggerHaptic(1);
    }
}
void ChoiceState::handleStart() {
    auto& e = engine(*this);
    e.selectChoice(e.choiceIndex());
}

// --- LibraryState ---
void LibraryState::enter() { 
    engine(*this).setInternalState(GameLogic::Library); 
}
void LibraryState::exit() {}
void LibraryState::update() {}
void LibraryState::handleInput(int, int) {}
void LibraryState::handleStart() { 
    engine(*this).requestStateChange(GameLogic::StartMenu); 
}

// --- ReadyState ---
void ReadyState::enter() {
    auto& e = engine(*this);
    e.setInternalState(GameLogic::Ready);
    e.setCountdownValue(3);
    e.startEngineTimer(1000); // 1 tick per second
}
void ReadyState::exit() {
    engine(*this).stopEngineTimer();
}
void ReadyState::update() {
    auto& e = engine(*this);
    int current = e.countdownValue();
    e.setCountdownValue(current - 1);
    
    if (e.countdownValue() <= 0) {
        e.requestStateChange(GameLogic::Playing);
        e.startEngineTimer(-1); // Restore normal speed
    } else {
        e.playEventSound(2); // Tick sound
    }
}
void ReadyState::handleInput(int dx, int dy) {
    // Allow buffering the next direction during countdown
    if (dx != 0 || dy != 0) {
        auto& e = engine(*this);
        e.direction() = QPoint(dx, dy);
    }
}
void ReadyState::handleStart() {}

// --- PausedState ---

void PausedState::enter() { 
    engine(*this).setInternalState(GameLogic::Paused); 
}

void PausedState::exit() {}
void PausedState::update() {}
void PausedState::handleInput(int, int) {}
void PausedState::handleStart() { 
    engine(*this).togglePause(); 
}

// --- GameOverState ---

void GameOverState::enter() { 
    engine(*this).setInternalState(GameLogic::GameOver); 
}

void GameOverState::exit() {}
void GameOverState::update() {}
void GameOverState::handleInput(int, int) {}
void GameOverState::handleStart() { 
    engine(*this).restart(); 
}
