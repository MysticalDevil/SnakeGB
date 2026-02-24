#include "replay_timeline.h"

#include <QPoint>

namespace snakegb::fsm {

auto applyReplayChoicesForCurrentTick(IGameEngine &engine, int &choiceHistoryIndex) -> void {
    while (choiceHistoryIndex < engine.bestChoiceHistorySize()) {
        int frame = 0;
        int choiceIndex = 0;
        if (!engine.bestChoiceAt(choiceHistoryIndex, frame, choiceIndex)) {
            break;
        }

        if (frame == engine.currentTick()) {
            engine.selectChoice(choiceIndex);
            choiceHistoryIndex++;
            break;
        }
        if (frame > engine.currentTick()) {
            break;
        }
        choiceHistoryIndex++;
    }
}

auto applyReplayInputsForCurrentTick(IGameEngine &engine, int &inputHistoryIndex) -> void {
    while (inputHistoryIndex < engine.bestInputHistorySize()) {
        int frame = 0;
        int dx = 0;
        int dy = 0;
        if (!engine.bestInputFrameAt(inputHistoryIndex, frame, dx, dy)) {
            break;
        }

        if (frame == engine.currentTick()) {
            engine.setDirection(QPoint(dx, dy));
            inputHistoryIndex++;
        } else if (frame > engine.currentTick()) {
            break;
        } else {
            inputHistoryIndex++;
        }
    }
}

} // namespace snakegb::fsm
