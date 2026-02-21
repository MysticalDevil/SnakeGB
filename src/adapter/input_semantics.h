#pragma once

namespace snakegb::adapter {

enum class BackAction {
    None = 0,
    QuitToMenu,
    QuitApplication,
};

[[nodiscard]] auto resolveBackActionForState(int state) -> BackAction;

} // namespace snakegb::adapter
