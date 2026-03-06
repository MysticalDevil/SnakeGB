#include "core/achievement/rules.h"

namespace nenoserpent::core {

auto unlockedAchievementIds(const AchievementStats& stats) -> QStringList {
  QStringList unlocked;
  if (stats.score >= 20) {
    unlocked << QStringLiteral("silver_medal");
  }
  if (stats.score >= 50) {
    unlocked << QStringLiteral("gold_medal");
  }
  if (stats.timerActive && stats.tickIntervalMs <= 60) {
    unlocked << QStringLiteral("speed_demon");
  }
  if (stats.totalCrashes >= 100) {
    unlocked << QStringLiteral("centurion");
  }
  if (stats.totalFoodEaten >= 500) {
    unlocked << QStringLiteral("gourmet");
  }
  if (stats.noFoodElapsedMs >= 60000) {
    unlocked << QStringLiteral("pacifist");
  }
  if (stats.shieldConsumedThisRun && stats.ticksSinceShieldConsumedMs >= 20000) {
    unlocked << QStringLiteral("last_stand");
  }
  if (stats.collectedPowerTypesThisRun.size() >= 4) {
    unlocked << QStringLiteral("collector");
  }
  if (stats.triggeredPowerTypesThisRun.size() >= 3) {
    unlocked << QStringLiteral("power_chain");
  }
  if (!stats.usedAnyPowerThisRun && stats.score >= 25) {
    unlocked << QStringLiteral("minimalist");
  }
  if (stats.highSpeedElapsedMs >= 30000) {
    unlocked << QStringLiteral("steady_nerves");
  }
  if (stats.phaseWalkCount > 0) {
    unlocked << QStringLiteral("phase_walker");
  }
  return unlocked;
}

} // namespace nenoserpent::core
