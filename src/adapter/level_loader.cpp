#include "level_loader.h"

#include <QFile>

namespace snakegb::adapter {

auto loadResolvedLevelFromResource(const QStringView resourcePath,
                                   const int levelIndex) -> std::optional<snakegb::core::ResolvedLevelData> {
    QFile file(resourcePath.toString());
    if (!file.open(QIODevice::ReadOnly)) {
        return std::nullopt;
    }
    return snakegb::core::resolvedLevelDataFromJsonBytes(file.readAll(), levelIndex);
}

auto readLevelCountFromResource(const QStringView resourcePath, const int fallbackCount) -> int {
    QFile file(resourcePath.toString());
    if (!file.open(QIODevice::ReadOnly)) {
        return fallbackCount;
    }
    return snakegb::core::levelCountFromJsonBytes(file.readAll(), fallbackCount);
}

} // namespace snakegb::adapter
