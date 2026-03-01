#pragma once

#include "core/replay/types.h"

#include <QList>
#include <QPoint>

#include <functional>

namespace snakegb::core {

void applyReplayInputsForTick(const QList<ReplayFrame> &inputFrames, int currentTick,
                              int &inputHistoryIndex,
                              const std::function<void(const QPoint &)> &applyDirection);

void applyReplayChoiceForTick(const QList<ChoiceRecord> &choiceFrames, int currentTick,
                              int &choiceHistoryIndex,
                              const std::function<void(int)> &applyChoice);

} // namespace snakegb::core
