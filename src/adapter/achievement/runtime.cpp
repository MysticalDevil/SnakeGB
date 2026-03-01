#include "adapter/achievement/runtime.h"

#include "adapter/profile/bridge.h"
#include "core/achievement/rules.h"

namespace nenoserpent::adapter {

auto unlockAchievements(ProfileManager* profile,
                        const int score,
                        const int tickIntervalMs,
                        const bool timerActive,
                        const int noFoodElapsedMs) -> QStringList {
  const QStringList unlockedTitles =
    nenoserpent::core::unlockedAchievementTitles(score, tickIntervalMs, timerActive);
  QStringList newlyUnlocked;
  newlyUnlocked.reserve(unlockedTitles.size() + 5);
  for (const QString& title : unlockedTitles) {
    if (nenoserpent::adapter::unlockMedal(profile, title)) {
      newlyUnlocked.append(title);
    }
  }
  if (nenoserpent::adapter::totalCrashes(profile) >= 100 &&
      nenoserpent::adapter::unlockMedal(profile, QStringLiteral("Centurion (100 Crashes)"))) {
    newlyUnlocked.append(QStringLiteral("Centurion (100 Crashes)"));
  }
  if (nenoserpent::adapter::totalFoodEaten(profile) >= 500 &&
      nenoserpent::adapter::unlockMedal(profile, QStringLiteral("Gourmet (500 Food)"))) {
    newlyUnlocked.append(QStringLiteral("Gourmet (500 Food)"));
  }
  if (nenoserpent::adapter::totalGhostTriggers(profile) >= 20 &&
      nenoserpent::adapter::unlockMedal(profile, QStringLiteral("Untouchable"))) {
    newlyUnlocked.append(QStringLiteral("Untouchable"));
  }
  if (noFoodElapsedMs >= 60000 &&
      nenoserpent::adapter::unlockMedal(profile, QStringLiteral("Pacifist (60s No Food)"))) {
    newlyUnlocked.append(QStringLiteral("Pacifist (60s No Food)"));
  }
  return newlyUnlocked;
}

} // namespace nenoserpent::adapter
