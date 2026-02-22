#include "profile_bridge.h"

#include "../profile_manager.h"

namespace snakegb::adapter
{

auto paletteIndex(const ProfileManager *profile) -> int
{
    return profile != nullptr ? profile->paletteIndex() : 0;
}

void setPaletteIndex(ProfileManager *profile, const int index)
{
    if (profile != nullptr) {
        profile->setPaletteIndex(index);
    }
}

auto shellIndex(const ProfileManager *profile) -> int
{
    return profile != nullptr ? profile->shellIndex() : 0;
}

void setShellIndex(ProfileManager *profile, const int index)
{
    if (profile != nullptr) {
        profile->setShellIndex(index);
    }
}

auto levelIndex(const ProfileManager *profile) -> int
{
    return profile != nullptr ? profile->levelIndex() : 0;
}

void setLevelIndex(ProfileManager *profile, const int index)
{
    if (profile != nullptr) {
        profile->setLevelIndex(index);
    }
}

auto volume(const ProfileManager *profile) -> float
{
    return profile != nullptr ? profile->volume() : 1.0F;
}

void setVolume(ProfileManager *profile, const float value)
{
    if (profile != nullptr) {
        profile->setVolume(value);
    }
}

auto highScore(const ProfileManager *profile) -> int
{
    return profile != nullptr ? profile->highScore() : 0;
}

void updateHighScore(ProfileManager *profile, const int score)
{
    if (profile != nullptr) {
        profile->updateHighScore(score);
    }
}

void incrementCrashes(ProfileManager *profile)
{
    if (profile != nullptr) {
        profile->incrementCrashes();
    }
}

void logFoodEaten(ProfileManager *profile)
{
    if (profile != nullptr) {
        profile->logFoodEaten();
    }
}

void discoverFruit(ProfileManager *profile, const int type)
{
    if (profile != nullptr) {
        profile->discoverFruit(type);
    }
}

auto unlockedMedals(const ProfileManager *profile) -> QStringList
{
    return profile != nullptr ? profile->unlockedMedals() : QStringList{};
}

auto unlockMedal(ProfileManager *profile, const QString &title) -> bool
{
    if (profile == nullptr) {
        return false;
    }
    return profile->unlockMedal(title);
}

auto discoveredFruits(const ProfileManager *profile) -> QList<int>
{
    return profile != nullptr ? profile->discoveredFruits() : QList<int>{};
}

auto hasSession(const ProfileManager *profile) -> bool
{
    return profile != nullptr ? profile->hasSession() : false;
}

void saveSession(ProfileManager *profile, const int score, const std::deque<QPoint> &body,
                 const QList<QPoint> &obstacles, const QPoint food, const QPoint direction)
{
    if (profile != nullptr) {
        profile->saveSession(score, body, obstacles, food, direction);
    }
}

void clearSession(ProfileManager *profile)
{
    if (profile != nullptr) {
        profile->clearSession();
    }
}

auto loadSession(ProfileManager *profile) -> QVariantMap
{
    return profile != nullptr ? profile->loadSession() : QVariantMap{};
}

auto loadSessionSnapshot(ProfileManager *profile) -> std::optional<SessionSnapshot>
{
    if (profile == nullptr || !profile->hasSession()) {
        return std::nullopt;
    }
    return decodeSessionSnapshot(profile->loadSession());
}

} // namespace snakegb::adapter
