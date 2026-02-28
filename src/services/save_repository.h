#pragma once

#include "adapter/ghost_store.h"
#include "adapter/session_state.h"
#include "core/state_snapshot.h"

#include <optional>

class ProfileManager;

namespace snakegb::services
{

class SaveRepository
{
public:
    explicit SaveRepository(ProfileManager *profile);

    [[nodiscard]] auto hasSession() const -> bool;
    [[nodiscard]] auto loadSessionSnapshot() const
        -> std::optional<snakegb::adapter::SessionSnapshot>;
    void saveSession(const snakegb::core::StateSnapshot &snapshot) const;
    void clearSession() const;

    [[nodiscard]] auto loadGhostSnapshot(snakegb::adapter::GhostSnapshot &snapshot) const -> bool;
    [[nodiscard]] auto saveGhostSnapshot(const snakegb::adapter::GhostSnapshot &snapshot) const
        -> bool;

private:
    ProfileManager *m_profile = nullptr;
};

} // namespace snakegb::services
