#pragma once

#include <deque>
#include <optional>

#include <QList>
#include <QPoint>
#include <QVariantMap>

#include "core/session/snapshot.h"

namespace snakegb::adapter {

struct SessionSnapshot {
  int score = 0;
  QPoint food;
  QPoint direction;
  QList<QPoint> obstacles;
  std::deque<QPoint> body;
};

[[nodiscard]] auto decodeSessionSnapshot(const QVariantMap& data) -> std::optional<SessionSnapshot>;
[[nodiscard]] auto toCoreStateSnapshot(const SessionSnapshot& snapshot)
  -> snakegb::core::StateSnapshot;
[[nodiscard]] auto fromCoreStateSnapshot(const snakegb::core::StateSnapshot& snapshot)
  -> SessionSnapshot;

} // namespace snakegb::adapter
