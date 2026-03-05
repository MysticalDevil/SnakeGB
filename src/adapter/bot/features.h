#pragma once

#include <array>
#include <optional>

#include <QPoint>

#include "adapter/bot/controller.h"

namespace nenoserpent::adapter::bot {

struct Features {
  static constexpr int kSize = 21;
  std::array<float, kSize> values{};
};

[[nodiscard]] auto extractFeatures(const Snapshot& snapshot) -> Features;
[[nodiscard]] auto directionClass(const QPoint& direction) -> int;
[[nodiscard]] auto classDirection(int actionClass) -> std::optional<QPoint>;

} // namespace nenoserpent::adapter::bot
