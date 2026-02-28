#pragma once

#include "session_state.h"

#include <QList>
#include <QPoint>
#include <QStringList>
#include <QVariantMap>

#include <deque>
#include <optional>

class ProfileManager;

namespace snakegb::adapter
{

[[nodiscard]] auto paletteIndex(const ProfileManager *profile) -> int;
void setPaletteIndex(ProfileManager *profile, int index);
[[nodiscard]] auto shellIndex(const ProfileManager *profile) -> int;
void setShellIndex(ProfileManager *profile, int index);

[[nodiscard]] auto levelIndex(const ProfileManager *profile) -> int;
void setLevelIndex(ProfileManager *profile, int index);

[[nodiscard]] auto volume(const ProfileManager *profile) -> float;
void setVolume(ProfileManager *profile, float value);

[[nodiscard]] auto highScore(const ProfileManager *profile) -> int;
void updateHighScore(ProfileManager *profile, int score);

void incrementCrashes(ProfileManager *profile);
void logFoodEaten(ProfileManager *profile);
void discoverFruit(ProfileManager *profile, int type);

[[nodiscard]] auto unlockedMedals(const ProfileManager *profile) -> QStringList;
[[nodiscard]] auto unlockMedal(ProfileManager *profile, const QString &title) -> bool;
[[nodiscard]] auto discoveredFruits(const ProfileManager *profile) -> QList<int>;

[[nodiscard]] auto hasSession(const ProfileManager *profile) -> bool;
void saveSession(ProfileManager *profile, int score, const std::deque<QPoint> &body,
                 const QList<QPoint> &obstacles, QPoint food, QPoint direction);
void saveSession(ProfileManager *profile, const snakegb::core::StateSnapshot &snapshot);
void clearSession(ProfileManager *profile);
[[nodiscard]] auto loadSession(ProfileManager *profile) -> QVariantMap;
[[nodiscard]] auto loadSessionSnapshot(ProfileManager *profile) -> std::optional<SessionSnapshot>;

} // namespace snakegb::adapter
