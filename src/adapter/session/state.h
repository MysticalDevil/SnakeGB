#pragma once

#include <deque>
#include <optional>

#include <QList>
#include <QPoint>
#include <QVariantMap>

#include "core/session/snapshot.h"

namespace nenoserpent::adapter {

struct SessionSnapshot {
  int score = 0;
  QPoint food;
  QPoint direction;
  QList<QPoint> obstacles;
  std::deque<QPoint> body;
};

[[nodiscard]] auto decodeSessionSnapshot(const QVariantMap& data) -> std::optional<SessionSnapshot>;
[[nodiscard]] auto toCoreStateSnapshot(const SessionSnapshot& snapshot)
  -> nenoserpent::core::StateSnapshot;
[[nodiscard]] auto fromCoreStateSnapshot(const nenoserpent::core::StateSnapshot& snapshot)
  -> SessionSnapshot;

} // namespace nenoserpent::adapter
