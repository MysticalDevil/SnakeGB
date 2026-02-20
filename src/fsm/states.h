#ifndef STATES_H
#define STATES_H

#include "game_state.h"
#include <QPoint>

class GameLogic;

class SplashState : public GameState {
public:
    explicit SplashState(GameLogic &logic) : GameState(logic) {}
    void enter() override;
    void update() override;
private:
    int m_frames = 0;
};

class MenuState : public GameState {
public:
    explicit MenuState(GameLogic &logic) : GameState(logic) {}
    void enter() override;
    void handleStart() override;
    void handleSelect() override;
    void handleInput(int dx, int dy) override;
};

class PlayingState : public GameState {
public:
    explicit PlayingState(GameLogic &logic) : GameState(logic) {}
    void enter() override;
    void update() override;
    void handleStart() override;
    void handleInput(int dx, int dy) override;
};

class PausedState : public GameState {
public:
    explicit PausedState(GameLogic &logic) : GameState(logic) {}
    void enter() override;
    void handleStart() override;
};

class GameOverState : public GameState {
public:
    explicit GameOverState(GameLogic &logic) : GameState(logic) {}
    void enter() override;
    void handleStart() override;
};

class ReplayingState : public GameState {
public:
    explicit ReplayingState(GameLogic &logic) : GameState(logic) {}
    void enter() override;
    void update() override;
    void handleStart() override;
private:
    int m_historyIndex = 0;
    int m_choiceHistoryIndex = 0;
};

class ChoiceState : public GameState {
public:
    explicit ChoiceState(GameLogic &logic) : GameState(logic) {}
    void enter() override;
    void handleStart() override;
    void handleInput(int dx, int dy) override;
};

class LibraryState : public GameState {
public:
    explicit LibraryState(GameLogic &logic) : GameState(logic) {}
    void enter() override;
    void handleInput(int dx, int dy) override;
    void handleSelect() override;
};

class MedalRoomState : public GameState {
public:
    explicit MedalRoomState(GameLogic &logic) : GameState(logic) {}
    void enter() override;
    void handleInput(int dx, int dy) override;
    void handleSelect() override;
};

#endif // STATES_H
