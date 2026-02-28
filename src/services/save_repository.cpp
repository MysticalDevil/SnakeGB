#include "services/save_repository.h"

#include "profile_manager.h"

namespace snakegb::services
{

SaveRepository::SaveRepository(ProfileManager *profile) : m_profile(profile) {}

auto SaveRepository::hasSession() const -> bool
{
    return m_profile != nullptr && m_profile->hasSession();
}

auto SaveRepository::loadSessionSnapshot() const -> std::optional<snakegb::adapter::SessionSnapshot>
{
    if (!hasSession()) {
        return std::nullopt;
    }
    return snakegb::adapter::decodeSessionSnapshot(m_profile->loadSession());
}

void SaveRepository::saveSession(const snakegb::core::StateSnapshot &snapshot) const
{
    if (m_profile == nullptr) {
        return;
    }

    const auto persisted = snakegb::adapter::fromCoreStateSnapshot(snapshot);
    m_profile->saveSession(persisted.score, persisted.body, persisted.obstacles, persisted.food,
                           persisted.direction);
}

void SaveRepository::clearSession() const
{
    if (m_profile != nullptr) {
        m_profile->clearSession();
    }
}

auto SaveRepository::loadGhostSnapshot(snakegb::adapter::GhostSnapshot &snapshot) const -> bool
{
    return snakegb::adapter::loadGhostSnapshot(snapshot);
}

auto SaveRepository::saveGhostSnapshot(const snakegb::adapter::GhostSnapshot &snapshot) const
    -> bool
{
    return snakegb::adapter::saveGhostSnapshot(snapshot);
}

} // namespace snakegb::services
