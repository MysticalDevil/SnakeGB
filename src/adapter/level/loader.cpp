#include "adapter/level/loader.h"

#include "services/level/repository.h"

namespace nenoserpent::adapter {

auto loadResolvedLevelFromResource(const QStringView resourcePath, const int levelIndex)
  -> std::optional<nenoserpent::core::ResolvedLevelData> {
  return nenoserpent::services::LevelRepository(resourcePath.toString()).loadResolvedLevel(levelIndex);
}

auto readLevelCountFromResource(const QStringView resourcePath, const int fallbackCount) -> int {
  return nenoserpent::services::LevelRepository(resourcePath.toString(), fallbackCount).levelCount();
}

} // namespace nenoserpent::adapter
