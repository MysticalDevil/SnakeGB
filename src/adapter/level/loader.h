#pragma once

#include <optional>

#include <QStringView>

#include "core/level/runtime.h"

namespace snakegb::adapter {

[[nodiscard]] auto loadResolvedLevelFromResource(QStringView resourcePath, int levelIndex)
  -> std::optional<snakegb::core::ResolvedLevelData>;
[[nodiscard]] auto readLevelCountFromResource(QStringView resourcePath, int fallbackCount) -> int;

} // namespace snakegb::adapter
