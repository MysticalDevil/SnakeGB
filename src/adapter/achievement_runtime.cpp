#include "achievement_runtime.h"

#include "profile_bridge.h"
#include "core/achievement_rules.h"

namespace snakegb::adapter {

auto unlockAchievements(ProfileManager *profile, const int score, const int tickIntervalMs,
                        const bool timerActive) -> QStringList
{
    const QStringList unlockedTitles =
        snakegb::core::unlockedAchievementTitles(score, tickIntervalMs, timerActive);
    QStringList newlyUnlocked;
    newlyUnlocked.reserve(unlockedTitles.size());
    for (const QString &title : unlockedTitles) {
        if (snakegb::adapter::unlockMedal(profile, title)) {
            newlyUnlocked.append(title);
        }
    }
    return newlyUnlocked;
}

} // namespace snakegb::adapter
