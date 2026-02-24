#pragma once

#include "core/level_runtime.h"

#include <QStringView>
#include <optional>

namespace snakegb::adapter {

[[nodiscard]] auto loadResolvedLevelFromResource(QStringView resourcePath,
                                                 int levelIndex) -> std::optional<snakegb::core::ResolvedLevelData>;
[[nodiscard]] auto readLevelCountFromResource(QStringView resourcePath, int fallbackCount) -> int;

} // namespace snakegb::adapter
