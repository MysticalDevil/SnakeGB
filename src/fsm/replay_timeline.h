#pragma once

#include "game_engine_interface.h"

namespace snakegb::fsm {

auto applyReplayChoicesForCurrentTick(IGameEngine &engine, int &choiceHistoryIndex) -> void;
auto applyReplayInputsForCurrentTick(IGameEngine &engine, int &inputHistoryIndex) -> void;

} // namespace snakegb::fsm
