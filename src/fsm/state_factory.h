#pragma once

#include <memory>

class GameState;
class IGameEngine;

namespace snakegb::fsm {

[[nodiscard]] auto createStateFor(IGameEngine& engine, int state) -> std::unique_ptr<GameState>;

} // namespace snakegb::fsm
