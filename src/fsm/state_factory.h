#pragma once

#include <memory>

class GameState;
class IGameEngine;

namespace nenoserpent::fsm {

[[nodiscard]] auto createStateFor(IGameEngine& engine, int state) -> std::unique_ptr<GameState>;

} // namespace nenoserpent::fsm
