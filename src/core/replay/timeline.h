#pragma once

#include <functional>

#include <QList>
#include <QPoint>

#include "core/replay/types.h"

namespace snakegb::core {

void applyReplayInputsForTick(const QList<ReplayFrame>& inputFrames,
                              int currentTick,
                              int& inputHistoryIndex,
                              const std::function<void(const QPoint&)>& applyDirection);

void applyReplayChoiceForTick(const QList<ChoiceRecord>& choiceFrames,
                              int currentTick,
                              int& choiceHistoryIndex,
                              const std::function<void(int)>& applyChoice);

} // namespace snakegb::core
