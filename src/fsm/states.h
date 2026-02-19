#pragma once

#include "game_state.h"
#include <memory>

class GameLogic;

class SplashState : public GameState {
public:
    explicit SplashState(GameLogic& logic) : GameState(logic) {}
    void enter() override;
    void update() override;
};

class MenuState : public GameState {
public:
    explicit MenuState(GameLogic& logic) : GameState(logic) {}
    void enter() override;
    void handleStart() override;
    void handleSelect() override;
};

class PlayingState : public GameState {
public:
    explicit PlayingState(GameLogic& logic) : GameState(logic) {}
    void enter() override;
    void update() override;
    void handleInput(int dx, int dy) override;
    void handleStart() override;
};

class ReplayingState : public GameState {
public:
    explicit ReplayingState(GameLogic& logic) : GameState(logic) {}
    void enter() override;
    void update() override;
    void handleStart() override;
};

class PausedState : public GameState {
public:
    explicit PausedState(GameLogic& logic) : GameState(logic) {}
    void enter() override;
    void handleStart() override;
};

class GameOverState : public GameState {
public:
    explicit GameOverState(GameLogic& logic) : GameState(logic) {}
    void enter() override;
    void handleStart() override;
};
