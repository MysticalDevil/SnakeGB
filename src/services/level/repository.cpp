#include "services/level/repository.h"

#include <QFile>

namespace snakegb::services {

LevelRepository::LevelRepository(QString resourcePath, const int fallbackCount)
    : m_resourcePath(std::move(resourcePath)),
      m_fallbackCount(fallbackCount) {
}

auto LevelRepository::loadResolvedLevel(const int levelIndex) const
  -> std::optional<snakegb::core::ResolvedLevelData> {
  QFile file(m_resourcePath);
  if (!file.open(QIODevice::ReadOnly)) {
    return std::nullopt;
  }
  return snakegb::core::resolvedLevelDataFromJsonBytes(file.readAll(), levelIndex);
}

auto LevelRepository::levelCount() const -> int {
  QFile file(m_resourcePath);
  if (!file.open(QIODevice::ReadOnly)) {
    return m_fallbackCount;
  }
  return snakegb::core::levelCountFromJsonBytes(file.readAll(), m_fallbackCount);
}

} // namespace snakegb::services
