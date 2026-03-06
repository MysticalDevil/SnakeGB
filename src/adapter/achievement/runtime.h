#pragma once

#include <QStringList>

#include "core/achievement/rules.h"

class ProfileManager;

namespace nenoserpent::adapter {

auto unlockAchievements(ProfileManager* profile, const nenoserpent::core::AchievementStats& stats)
  -> QStringList;

} // namespace nenoserpent::adapter
