#include "adapter/level/applier.h"

namespace nenoserpent::adapter {

auto applyResolvedLevelData(const nenoserpent::core::ResolvedLevelData& resolvedLevel,
                            QString& currentLevelName,
                            QString& currentScript,
                            QList<QPoint>& obstacles,
                            const std::function<bool(const QString&)>& evaluateAndRunScript)
  -> bool {
  currentLevelName = resolvedLevel.name;
  obstacles.clear();
  currentScript = resolvedLevel.script;

  if (!currentScript.isEmpty()) {
    if (!evaluateAndRunScript(currentScript)) {
      return false;
    }
    return !obstacles.isEmpty();
  }

  obstacles = resolvedLevel.walls;
  return !obstacles.isEmpty();
}

} // namespace nenoserpent::adapter
