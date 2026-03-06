#pragma once

#include <QSet>
#include <QString>
#include <QStringList>

namespace nenoserpent::core {

struct AchievementStats {
  int score = 0;
  int tickIntervalMs = 0;
  bool timerActive = false;
  int totalCrashes = 0;
  int totalFoodEaten = 0;
  int noFoodElapsedMs = 0;
  int foodEatenThisRun = 0;
  bool usedAnyPowerThisRun = false;
  QSet<int> collectedPowerTypesThisRun;
  QSet<int> triggeredPowerTypesThisRun;
  bool shieldConsumedThisRun = false;
  int ticksSinceShieldConsumedMs = 0;
  int highSpeedElapsedMs = 0;
  int phaseWalkCount = 0;
};

auto unlockedAchievementIds(const AchievementStats& stats) -> QStringList;

} // namespace nenoserpent::core
