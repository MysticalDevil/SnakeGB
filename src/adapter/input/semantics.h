#pragma once

namespace nenoserpent::adapter {

enum class BackAction {
  None = 0,
  QuitToMenu,
  QuitApplication,
};

[[nodiscard]] auto resolveBackActionForState(int state) -> BackAction;

} // namespace nenoserpent::adapter
