#include "core/replay/timeline.h"

namespace snakegb::core {

void applyReplayInputsForTick(const QList<ReplayFrame>& inputFrames,
                              const int currentTick,
                              int& inputHistoryIndex,
                              const std::function<void(const QPoint&)>& applyDirection) {
  while (inputHistoryIndex < inputFrames.size()) {
    const auto& frame = inputFrames[inputHistoryIndex];
    if (frame.frame == currentTick) {
      applyDirection(QPoint(frame.dx, frame.dy));
      inputHistoryIndex++;
    } else if (frame.frame > currentTick) {
      break;
    } else {
      inputHistoryIndex++;
    }
  }
}

void applyReplayChoiceForTick(const QList<ChoiceRecord>& choiceFrames,
                              const int currentTick,
                              int& choiceHistoryIndex,
                              const std::function<void(int)>& applyChoice) {
  while (choiceHistoryIndex < choiceFrames.size()) {
    const auto& frame = choiceFrames[choiceHistoryIndex];
    if (frame.frame == currentTick) {
      applyChoice(frame.index);
      choiceHistoryIndex++;
      break;
    }
    if (frame.frame > currentTick) {
      break;
    }
    choiceHistoryIndex++;
  }
}

} // namespace snakegb::core
