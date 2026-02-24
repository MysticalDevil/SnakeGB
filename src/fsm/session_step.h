#pragma once

#include "game_engine_interface.h"

namespace snakegb::fsm {

struct SessionStepConfig {
    int activeState = IGameEngine::Playing;
    int collisionTargetState = IGameEngine::GameOver;
    bool consumeInputQueue = true;
    bool recordConsumedInput = true;
    bool emitCrashFeedbackOnCollision = true;
};

auto runSessionStep(IGameEngine &engine, const SessionStepConfig &config) -> bool;

} // namespace snakegb::fsm
