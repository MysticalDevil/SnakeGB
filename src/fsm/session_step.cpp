#include "session_step.h"

namespace snakegb::fsm {

auto runSessionStep(IGameEngine &engine, const SessionStepConfig &config) -> bool {
    const auto result = engine.advanceSessionStep({
        .boardWidth = 20,
        .boardHeight = 18,
        .consumeInputQueue = config.consumeInputQueue,
        .pauseOnChoiceTrigger = (config.activeState != IGameEngine::Replaying),
    });

    if (result.consumedInput && config.recordConsumedInput) {
        engine.recordInputAtCurrentTick(result.consumedDirection);
    }

    if (result.collision) {
        if (config.emitCrashFeedbackOnCollision) {
            engine.triggerHaptic(8);
            engine.playEventSound(1);
        }
        engine.requestStateChange(config.collisionTargetState);
        return false;
    }

    return result.appliedMovement && engine.currentState() == config.activeState &&
           !engine.hasPendingStateChange();
}

} // namespace snakegb::fsm
