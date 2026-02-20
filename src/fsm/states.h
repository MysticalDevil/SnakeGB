#pragma once
#include "game_state.h"
#include <QTimer>

class SplashState : public GameState {
public:
    using GameState::GameState;
    void enter() override;
    void exit() override;
    void update() override;
    void handleInput(int dx, int dy) override;
    void handleStart() override;
};

class MenuState : public GameState {
public:
    using GameState::GameState;
    void enter() override;
    void exit() override;
    void update() override;
    void handleInput(int dx, int dy) override;
    void handleStart() override;
    void handleSelect() override;
};

class PlayingState : public GameState {
public:
    using GameState::GameState;
    void enter() override;
    void exit() override;
    void update() override;
    void handleInput(int dx, int dy) override;
    void handleStart() override;
};

class ReplayingState : public GameState {
public:
    using GameState::GameState;
    void enter() override;
    void exit() override;
    void update() override;
    void handleInput(int dx, int dy) override;
    void handleStart() override;
};

class PausedState : public GameState {
public:
    using GameState::GameState;
    void enter() override;
    void exit() override;
    void update() override;
    void handleInput(int dx, int dy) override;
    void handleStart() override;
};

class GameOverState : public GameState {
public:
    using GameState::GameState;
    void enter() override;
    void exit() override;
    void update() override;
    void handleInput(int dx, int dy) override;
    void handleStart() override;
};

class ChoiceState : public GameState {
public:
    using GameState::GameState;
    void enter() override;
    void exit() override;
    void update() override;
    void handleInput(int dx, int dy) override;
    void handleStart() override;
};
