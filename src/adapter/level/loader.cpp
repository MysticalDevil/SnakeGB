#include "adapter/level/loader.h"

#include "services/level/repository.h"

namespace snakegb::adapter
{

auto loadResolvedLevelFromResource(const QStringView resourcePath, const int levelIndex)
    -> std::optional<snakegb::core::ResolvedLevelData>
{
    return snakegb::services::LevelRepository(resourcePath.toString())
        .loadResolvedLevel(levelIndex);
}

auto readLevelCountFromResource(const QStringView resourcePath, const int fallbackCount) -> int
{
    return snakegb::services::LevelRepository(resourcePath.toString(), fallbackCount).levelCount();
}

} // namespace snakegb::adapter
