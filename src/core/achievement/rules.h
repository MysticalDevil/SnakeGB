#pragma once

#include <QString>
#include <QStringList>

namespace snakegb::core {

auto unlockedAchievementTitles(int score, int tickIntervalMs, bool timerActive) -> QStringList;

} // namespace snakegb::core
