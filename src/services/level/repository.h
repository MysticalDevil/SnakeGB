#pragma once

#include <optional>

#include <QString>

#include "core/level/runtime.h"

namespace nenoserpent::services {

class LevelRepository {
public:
  explicit LevelRepository(QString resourcePath = QStringLiteral("qrc:/src/levels/levels.json"),
                           int fallbackCount = 6);

  [[nodiscard]] auto loadResolvedLevel(int levelIndex) const
    -> std::optional<nenoserpent::core::ResolvedLevelData>;
  [[nodiscard]] auto levelCount() const -> int;

private:
  QString m_resourcePath;
  int m_fallbackCount = 6;
};

} // namespace nenoserpent::services
