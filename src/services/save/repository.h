#pragma once

#include <optional>

#include "adapter/ghost/store.h"
#include "adapter/session/state.h"
#include "core/session/snapshot.h"

class ProfileManager;

namespace nenoserpent::services {

class SaveRepository {
public:
  explicit SaveRepository(ProfileManager* profile);

  [[nodiscard]] auto hasSession() const -> bool;
  [[nodiscard]] auto loadSessionSnapshot() const
    -> std::optional<nenoserpent::adapter::SessionSnapshot>;
  void saveSession(const nenoserpent::core::StateSnapshot& snapshot) const;
  void clearSession() const;

  [[nodiscard]] auto loadGhostSnapshot(nenoserpent::adapter::GhostSnapshot& snapshot) const -> bool;
  [[nodiscard]] auto saveGhostSnapshot(const nenoserpent::adapter::GhostSnapshot& snapshot) const
    -> bool;

private:
  ProfileManager* m_profile = nullptr;
};

} // namespace nenoserpent::services
