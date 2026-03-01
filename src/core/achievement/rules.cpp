#include "core/achievement/rules.h"

namespace nenoserpent::core {

auto unlockedAchievementTitles(int score, int tickIntervalMs, bool timerActive) -> QStringList {
  QStringList unlocked;
  if (score >= 20) {
    unlocked << QStringLiteral("Silver Medal (20 Pts)");
  }
  if (score >= 50) {
    unlocked << QStringLiteral("Gold Medal (50 Pts)");
  }
  if (timerActive && tickIntervalMs <= 60) {
    unlocked << QStringLiteral("Speed Demon");
  }
  return unlocked;
}

} // namespace nenoserpent::core
