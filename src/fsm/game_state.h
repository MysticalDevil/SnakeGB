#pragma once

class GameLogic;

/**
 * @brief Abstract base class for Game States.
 */
class GameState {
public:
    explicit GameState(GameLogic& context) : m_context(context) {}
    virtual ~GameState() = default;

    virtual void enter() {}
    virtual void exit() {}
    virtual void update() {}
    virtual void handleInput(int dx, int dy) {}
    virtual void handleStart() {}
    virtual void handleSelect() {}

protected:
    GameLogic& m_context;
};
