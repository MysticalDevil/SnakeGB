#include "adapter/achievement/runtime.h"

#include "adapter/profile/bridge.h"
#include "core/achievement/rules.h"

namespace nenoserpent::adapter {

auto unlockAchievements(ProfileManager* profile, const nenoserpent::core::AchievementStats& stats)
  -> QStringList {
  const QStringList unlockedIds = nenoserpent::core::unlockedAchievementIds(stats);
  QStringList newlyUnlocked;
  newlyUnlocked.reserve(unlockedIds.size());
  for (const QString& id : unlockedIds) {
    if (nenoserpent::adapter::unlockMedal(profile, id)) {
      newlyUnlocked.append(id);
    }
  }
  return newlyUnlocked;
}

} // namespace nenoserpent::adapter
