#include "services/save/repository.h"

#include "profile_manager.h"

namespace nenoserpent::services {

SaveRepository::SaveRepository(ProfileManager* profile)
    : m_profile(profile) {
}

auto SaveRepository::hasSession() const -> bool {
  return m_profile != nullptr && m_profile->hasSession();
}

auto SaveRepository::loadSessionSnapshot() const
  -> std::optional<nenoserpent::adapter::SessionSnapshot> {
  if (!hasSession()) {
    return std::nullopt;
  }
  return nenoserpent::adapter::decodeSessionSnapshot(m_profile->loadSession());
}

void SaveRepository::saveSession(const nenoserpent::core::StateSnapshot& snapshot) const {
  if (m_profile == nullptr) {
    return;
  }

  const auto persisted = nenoserpent::adapter::fromCoreStateSnapshot(snapshot);
  m_profile->saveSession(
    persisted.score, persisted.body, persisted.obstacles, persisted.food, persisted.direction);
}

void SaveRepository::clearSession() const {
  if (m_profile != nullptr) {
    m_profile->clearSession();
  }
}

auto SaveRepository::loadGhostSnapshot(nenoserpent::adapter::GhostSnapshot& snapshot) const -> bool {
  return nenoserpent::adapter::loadGhostSnapshot(snapshot);
}

auto SaveRepository::saveGhostSnapshot(const nenoserpent::adapter::GhostSnapshot& snapshot) const
  -> bool {
  return nenoserpent::adapter::saveGhostSnapshot(snapshot);
}

} // namespace nenoserpent::services
