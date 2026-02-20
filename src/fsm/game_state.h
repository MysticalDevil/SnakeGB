#pragma once

#include "../game_engine_interface.h"

/**
 * @brief Abstract base class for Game States.
 */
class GameState {
public:
    explicit GameState(IGameEngine& context) : m_context(context) {}
    virtual ~GameState() = default;

    virtual void enter() {}
    virtual void exit() {}
    virtual void update() {}
    virtual void handleInput(int /*dx*/, int /*dy*/) {}
    virtual void handleStart() {}
    virtual void handleSelect() {}

    [[nodiscard]] auto context() noexcept -> IGameEngine& { return m_context; }

protected:
    IGameEngine& m_context;
};
