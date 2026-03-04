#include "adapter/bot/features.h"

#include <ranges>

namespace nenoserpent::adapter::bot {

namespace {

auto collidesAt(const Snapshot& snapshot, const QPoint& cell) -> float {
  const bool outOfBounds = cell.x() < 0 || cell.y() < 0 || cell.x() >= snapshot.boardWidth ||
                           cell.y() >= snapshot.boardHeight;
  if (outOfBounds) {
    return 1.0F;
  }
  if (snapshot.obstacles.contains(cell) ||
      std::ranges::find(snapshot.body, cell) != snapshot.body.end()) {
    return 1.0F;
  }
  return 0.0F;
}

} // namespace

auto extractFeatures(const Snapshot& snapshot) -> Features {
  Features features{};
  const QPoint up(0, -1);
  const QPoint right(1, 0);
  const QPoint down(0, 1);
  const QPoint left(-1, 0);

  auto& v = features.values;
  v[0] = static_cast<float>(snapshot.levelIndex);
  v[1] = static_cast<float>(snapshot.score);
  v[2] = static_cast<float>(snapshot.body.size());
  v[3] = static_cast<float>(snapshot.head.x());
  v[4] = static_cast<float>(snapshot.head.y());
  v[5] = static_cast<float>(snapshot.direction.x());
  v[6] = static_cast<float>(snapshot.direction.y());
  v[7] = static_cast<float>(snapshot.food.x() - snapshot.head.x());
  v[8] = static_cast<float>(snapshot.food.y() - snapshot.head.y());
  v[9] = static_cast<float>(snapshot.powerUpPos.x() - snapshot.head.x());
  v[10] = static_cast<float>(snapshot.powerUpPos.y() - snapshot.head.y());
  v[11] = static_cast<float>(snapshot.powerUpType);
  v[12] = snapshot.powerUpType > 0 ? 1.0F : 0.0F;
  v[13] = snapshot.ghostActive ? 1.0F : 0.0F;
  v[14] = snapshot.shieldActive ? 1.0F : 0.0F;
  v[15] = snapshot.portalActive ? 1.0F : 0.0F;
  v[16] = snapshot.laserActive ? 1.0F : 0.0F;
  v[17] = collidesAt(snapshot, snapshot.head + up);
  v[18] = collidesAt(snapshot, snapshot.head + right);
  v[19] = collidesAt(snapshot, snapshot.head + down);
  v[20] = collidesAt(snapshot, snapshot.head + left);
  return features;
}

auto directionClass(const QPoint& direction) -> int {
  if (direction == QPoint(0, -1)) {
    return 0;
  }
  if (direction == QPoint(1, 0)) {
    return 1;
  }
  if (direction == QPoint(0, 1)) {
    return 2;
  }
  if (direction == QPoint(-1, 0)) {
    return 3;
  }
  return -1;
}

auto classDirection(const int actionClass) -> std::optional<QPoint> {
  switch (actionClass) {
  case 0:
    return QPoint(0, -1);
  case 1:
    return QPoint(1, 0);
  case 2:
    return QPoint(0, 1);
  case 3:
    return QPoint(-1, 0);
  default:
    return std::nullopt;
  }
}

} // namespace nenoserpent::adapter::bot
