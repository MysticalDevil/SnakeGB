#include <random>

#include <QtTest>

#include "core/session/core.h"

namespace {
struct SpawnDistribution {
  int center = 0;
  int edge = 0;
  int total = 0;
};

auto makeRandomBounded(const unsigned seed) {
  std::mt19937 rng(seed);
  return [rng](const int upperBound) mutable -> int {
    if (upperBound <= 1) {
      return 0;
    }
    std::uniform_int_distribution<int> distribution(0, upperBound - 1);
    return distribution(rng);
  };
}

auto isCenterPoint(const QPoint& point, const int boardWidth, const int boardHeight) -> bool {
  const int marginX = boardWidth / 4;
  const int marginY = boardHeight / 4;
  return point.x() >= marginX && point.x() < (boardWidth - marginX) && point.y() >= marginY &&
         point.y() < (boardHeight - marginY);
}

auto isEdgeBandPoint(const QPoint& point,
                     const int boardWidth,
                     const int boardHeight,
                     const int bandWidth) -> bool {
  return point.x() <= bandWidth || point.y() <= bandWidth ||
         point.x() >= (boardWidth - 1 - bandWidth) || point.y() >= (boardHeight - 1 - bandWidth);
}

auto buildCorridorObstacles() -> QList<QPoint> {
  QList<QPoint> obstacles;
  for (int y = 2; y <= 15; ++y) {
    if (y == 8 || y == 9) {
      continue;
    }
    obstacles.push_back(QPoint(9, y));
    obstacles.push_back(QPoint(10, y));
  }
  return obstacles;
}

auto buildDynamicObstacles(const int phase) -> QList<QPoint> {
  QList<QPoint> obstacles;
  const int xShift = phase % 2;
  const int yShift = (phase / 2) % 2;
  for (int y = 4; y <= 13; ++y) {
    obstacles.push_back(QPoint(8 + xShift, y));
  }
  for (int x = 5; x <= 14; ++x) {
    obstacles.push_back(QPoint(x, 8 + yShift));
  }
  return obstacles;
}
} // namespace

class TestSpawnDistribution : public QObject {
  Q_OBJECT

private slots:
  void testCorridorLevelSpawnDistributionAvoidsEdgeBias();
  void testDynamicLevelSpawnDistributionStaysCenterWeighted();
};

void TestSpawnDistribution::testCorridorLevelSpawnDistributionAvoidsEdgeBias() {
  constexpr int boardWidth = 20;
  constexpr int boardHeight = 18;
  constexpr int samples = 800;
  constexpr int edgeBand = 2;

  nenoserpent::core::SessionCore core;
  core.setBody({QPoint(1, 1), QPoint(1, 2), QPoint(1, 3)});
  core.state().obstacles = buildCorridorObstacles();

  auto randomBounded = makeRandomBounded(20260306U);
  SpawnDistribution stats;
  for (int i = 0; i < samples; ++i) {
    QVERIFY(core.spawnFood(boardWidth, boardHeight, randomBounded));
    const QPoint food = core.state().food;
    if (isCenterPoint(food, boardWidth, boardHeight)) {
      ++stats.center;
    }
    if (isEdgeBandPoint(food, boardWidth, boardHeight, edgeBand)) {
      ++stats.edge;
    }
    ++stats.total;
  }

  QVERIFY(stats.total == samples);
  QVERIFY2(stats.center > stats.edge,
           "corridor spawn regressed: center picks should exceed edge-band picks");
  const double edgeRatio = static_cast<double>(stats.edge) / static_cast<double>(stats.total);
  QVERIFY2(edgeRatio < 0.30, "corridor spawn regressed: edge ratio too high");
}

void TestSpawnDistribution::testDynamicLevelSpawnDistributionStaysCenterWeighted() {
  constexpr int boardWidth = 20;
  constexpr int boardHeight = 18;
  constexpr int samples = 900;
  constexpr int edgeBand = 2;

  nenoserpent::core::SessionCore core;
  core.setBody({QPoint(2, 2), QPoint(2, 3), QPoint(2, 4)});

  auto randomBounded = makeRandomBounded(20260307U);
  SpawnDistribution stats;
  for (int i = 0; i < samples; ++i) {
    core.state().obstacles = buildDynamicObstacles(i % 4);
    QVERIFY(core.spawnFood(boardWidth, boardHeight, randomBounded));
    const QPoint food = core.state().food;
    if (isCenterPoint(food, boardWidth, boardHeight)) {
      ++stats.center;
    }
    if (isEdgeBandPoint(food, boardWidth, boardHeight, edgeBand)) {
      ++stats.edge;
    }
    ++stats.total;
  }

  QVERIFY(stats.total == samples);
  QVERIFY2(stats.center >= (stats.edge + 80),
           "dynamic spawn regressed: center should clearly dominate edge-band picks");
  const double centerRatio = static_cast<double>(stats.center) / static_cast<double>(stats.total);
  QVERIFY2(centerRatio >= 0.45, "dynamic spawn regressed: center ratio too low");
}

QTEST_MAIN(TestSpawnDistribution)
#include "test_spawn_distribution.moc"
