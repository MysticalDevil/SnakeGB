#pragma once

#include <QString>
#include <QStringList>

namespace nenoserpent::core {

auto unlockedAchievementTitles(int score, int tickIntervalMs, bool timerActive) -> QStringList;

} // namespace nenoserpent::core
