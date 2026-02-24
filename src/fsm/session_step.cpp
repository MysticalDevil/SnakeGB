#include "session_step.h"

namespace snakegb::fsm {

auto runSessionStep(IGameEngine &engine, const SessionStepConfig &config) -> bool {
    if (config.consumeInputQueue) {
        QPoint nextInput;
        if (engine.consumeQueuedInput(nextInput)) {
            engine.setDirection(nextInput);
            if (config.recordConsumedInput) {
                engine.recordInputAtCurrentTick(nextInput);
            }
        }
    }

    const QPoint nextHead = engine.headPosition() + engine.currentDirection();
    if (engine.checkCollision(nextHead)) {
        if (config.emitCrashFeedbackOnCollision) {
            engine.triggerHaptic(8);
            engine.playEventSound(1);
        }
        engine.requestStateChange(config.collisionTargetState);
        return false;
    }

    const bool grew = (nextHead == engine.foodPos());
    engine.handleFoodConsumption(nextHead);
    if (engine.currentState() != config.activeState || engine.hasPendingStateChange()) {
        return false;
    }

    engine.handlePowerUpConsumption(nextHead);
    if (engine.currentState() != config.activeState || engine.hasPendingStateChange()) {
        return false;
    }

    engine.applyMovement(nextHead, grew);
    return true;
}

} // namespace snakegb::fsm
