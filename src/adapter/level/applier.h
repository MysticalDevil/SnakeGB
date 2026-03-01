#pragma once

#include <functional>

#include <QList>
#include <QPoint>
#include <QString>

#include "core/level/runtime.h"

namespace nenoserpent::adapter {

// Applies resolved level data into runtime fields.
// Returns true when resolved data is accepted, false when caller should fallback.
[[nodiscard]] auto
applyResolvedLevelData(const nenoserpent::core::ResolvedLevelData& resolvedLevel,
                       QString& currentLevelName,
                       QString& currentScript,
                       QList<QPoint>& obstacles,
                       const std::function<bool(const QString&)>& evaluateAndRunScript) -> bool;

} // namespace nenoserpent::adapter
