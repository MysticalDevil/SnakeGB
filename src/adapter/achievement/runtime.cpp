#include "adapter/achievement/runtime.h"

#include "adapter/profile/bridge.h"
#include "core/achievement/rules.h"

namespace nenoserpent::adapter {

auto unlockAchievements(ProfileManager* profile,
                        const int score,
                        const int tickIntervalMs,
                        const bool timerActive) -> QStringList {
  const QStringList unlockedTitles =
    nenoserpent::core::unlockedAchievementTitles(score, tickIntervalMs, timerActive);
  QStringList newlyUnlocked;
  newlyUnlocked.reserve(unlockedTitles.size());
  for (const QString& title : unlockedTitles) {
    if (nenoserpent::adapter::unlockMedal(profile, title)) {
      newlyUnlocked.append(title);
    }
  }
  return newlyUnlocked;
}

} // namespace nenoserpent::adapter
