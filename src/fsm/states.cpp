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
    if (dx == 0 && dy == 1) { // DOWN
        auto& e = engine(*this);
        if (e.hasReplay()) {
            e.startReplay();
        } else {
            e.playEventSound(3); // Error beep
            e.triggerHaptic(2);  // Minor vibration pulse
        }
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
    static int historyIdx = 0;
    if (e.gameTickCounter() == 0) historyIdx = 0;

    auto& bestHistory = e.bestInputHistory();
    while (historyIdx < bestHistory.size()) {
        const auto &f = bestHistory[historyIdx];
        if (f.frame == e.gameTickCounter()) {
            e.direction() = QPoint(f.dx, f.dy);
            historyIdx++;
        } else if (f.frame > e.gameTickCounter()) {
            break; 
        } else {
            historyIdx++;
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
