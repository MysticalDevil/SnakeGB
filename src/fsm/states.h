#pragma once

#include "game_state.h"

class MenuState : public GameState {
public:
    using GameState::GameState;
    void enter() override;
    void handleStart() override;
    void handleSelect() override;
};

class PlayingState : public GameState {
public:
    using GameState::GameState;
    void enter() override;
    void update() override;
    void handleInput(int dx, int dy) override;
    void handleStart() override;
};

class PausedState : public GameState {
public:
    using GameState::GameState;
    void enter() override;
    void handleStart() override;
};

class GameOverState : public GameState {
public:
    using GameState::GameState;
    void enter() override;
    void handleStart() override;
};
