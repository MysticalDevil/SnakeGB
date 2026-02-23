#ifndef STATES_H
#define STATES_H

#include "game_state.h"
#include <QPoint>

class SplashState : public GameState {
public:
    explicit SplashState(IGameEngine &logic) : GameState(logic) {}
    void enter() override;
    void update() override;
private:
    int m_frames = 0;
};

class MenuState : public GameState {
public:
    explicit MenuState(IGameEngine &logic) : GameState(logic) {}
    void enter() override;
    void handleStart() override;
    void handleSelect() override;
    void handleInput(int dx, int dy) override;
};

class PlayingState : public GameState {
public:
    explicit PlayingState(IGameEngine &logic) : GameState(logic) {}
    void enter() override;
    void update() override;
    void handleStart() override;
    void handleInput(int dx, int dy) override;
};

class PausedState : public GameState {
public:
    explicit PausedState(IGameEngine &logic) : GameState(logic) {}
    void enter() override;
    void handleStart() override;
    void handleSelect() override;
};

class GameOverState : public GameState {
public:
    explicit GameOverState(IGameEngine &logic) : GameState(logic) {}
    void enter() override;
    void handleStart() override;
    void handleSelect() override;
};

class ReplayingState : public GameState {
public:
    explicit ReplayingState(IGameEngine &logic) : GameState(logic) {}
    void enter() override;
    void update() override;
    void handleStart() override;
    void handleSelect() override;
private:
    int m_historyIndex = 0;
    int m_choiceHistoryIndex = 0;
};

class ChoiceState : public GameState {
public:
    explicit ChoiceState(IGameEngine &logic) : GameState(logic) {}
    void enter() override;
    void handleStart() override;
    void handleSelect() override;
    void handleInput(int dx, int dy) override;
};

class LibraryState : public GameState {
public:
    explicit LibraryState(IGameEngine &logic) : GameState(logic) {}
    void enter() override;
    void handleInput(int dx, int dy) override;
    void handleSelect() override;
};

class MedalRoomState : public GameState {
public:
    explicit MedalRoomState(IGameEngine &logic) : GameState(logic) {}
    void enter() override;
    void handleInput(int dx, int dy) override;
    void handleSelect() override;
};

#endif // STATES_H
