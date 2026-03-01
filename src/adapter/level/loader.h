#pragma once

#include <optional>

#include <QStringView>

#include "core/level/runtime.h"

namespace nenoserpent::adapter {

[[nodiscard]] auto loadResolvedLevelFromResource(QStringView resourcePath, int levelIndex)
  -> std::optional<nenoserpent::core::ResolvedLevelData>;
[[nodiscard]] auto readLevelCountFromResource(QStringView resourcePath, int fallbackCount) -> int;

} // namespace nenoserpent::adapter
