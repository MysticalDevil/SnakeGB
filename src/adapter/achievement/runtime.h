#pragma once

#include <QStringList>

class ProfileManager;

namespace snakegb::adapter {

auto unlockAchievements(ProfileManager* profile, int score, int tickIntervalMs, bool timerActive)
  -> QStringList;

} // namespace snakegb::adapter
