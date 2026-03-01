#include "core/level/runtime.h"

#include <QJsonDocument>
#include <QJsonObject>

namespace snakegb::core {

namespace {

auto phaseOffset(const int tick, const int phaseTicks, const std::initializer_list<int> phases)
  -> int {
  const QList<int> values(phases);
  if (values.isEmpty()) {
    return 0;
  }
  const int safePhaseTicks = std::max(1, phaseTicks);
  const int phaseCount = static_cast<int>(values.size());
  const int index = (tick / safePhaseTicks) % phaseCount;
  return values[index];
}

auto shiftingBoxWalls(const int min, const int max) -> QList<QPoint> {
  return QList<QPoint>{QPoint(min, min),
                       QPoint(min + 1, min),
                       QPoint(max - 1, min),
                       QPoint(max, min),
                       QPoint(min, max),
                       QPoint(min + 1, max),
                       QPoint(max - 1, max),
                       QPoint(max, max),
                       QPoint(min, min + 1),
                       QPoint(min, max - 1),
                       QPoint(max, min + 1),
                       QPoint(max, max - 1)};
}

} // namespace

auto dynamicObstaclesForLevel(QStringView levelName, int gameTickCounter)
  -> std::optional<QList<QPoint>> {
  if (levelName == u"Dynamic Pulse") {
    const int offset = phaseOffset(gameTickCounter, 12, {0, 1, 2, 3, 2, 1});
    const int x1 = 5 + offset;
    const int x2 = 15 - offset;
    return QList<QPoint>{QPoint(x1, 5), QPoint(x1, 6), QPoint(x2, 12), QPoint(x2, 13)};
  }

  if (levelName == u"Crossfire") {
    const int offset = phaseOffset(gameTickCounter, 10, {0, 1, 2, 1});
    const int left = 5 + offset;
    const int right = 14 - offset;
    const int top = 5 + offset;
    const int bottom = 12 - offset;
    return QList<QPoint>{QPoint(left, 8),
                         QPoint(left, 9),
                         QPoint(right, 8),
                         QPoint(right, 9),
                         QPoint(9, top),
                         QPoint(10, bottom)};
  }

  if (levelName == u"Shifting Box") {
    const int offset = phaseOffset(gameTickCounter, 14, {0, 1, 2, 1});
    const int min = 4 + offset;
    const int max = 15 - offset;
    return shiftingBoxWalls(min, max);
  }

  return std::nullopt;
}

auto normalizedFallbackLevelIndex(int levelIndex) -> int {
  static constexpr int fallbackCount = 6;
  return ((levelIndex % fallbackCount) + fallbackCount) % fallbackCount;
}

auto fallbackLevelData(int levelIndex) -> FallbackLevelData {
  const int normalized = normalizedFallbackLevelIndex(levelIndex);
  switch (normalized) {
  case 0:
    return {.name = QStringLiteral("Classic"), .script = QString(), .walls = {}};
  case 1:
    return {.name = QStringLiteral("The Cage"),
            .script = QString(),
            .walls = {QPoint(5, 5),
                      QPoint(6, 5),
                      QPoint(14, 5),
                      QPoint(15, 5),
                      QPoint(5, 12),
                      QPoint(6, 12),
                      QPoint(14, 12),
                      QPoint(15, 12)}};
  case 2:
    return {.name = QStringLiteral("Dynamic Pulse"),
            .script = QStringLiteral(
              "function onTick(tick) { var phases = [0,1,2,3,2,1]; var offset = "
              "phases[Math.floor(tick / 12) % phases.length]; var x1 = 5 + offset; var "
              "x2 = 15 - offset; return [{x: x1, y: 5}, {x: x1, y: 6}, {x: x2, y: 12}, "
              "{x: x2, y: 13}]; }"),
            .walls = {}};
  case 3:
    return {.name = QStringLiteral("Tunnel Run"),
            .script = QString(),
            .walls = {QPoint(9, 4),
                      QPoint(9, 5),
                      QPoint(9, 6),
                      QPoint(9, 7),
                      QPoint(9, 10),
                      QPoint(9, 11),
                      QPoint(9, 12),
                      QPoint(9, 13),
                      QPoint(10, 4),
                      QPoint(10, 5),
                      QPoint(10, 6),
                      QPoint(10, 7),
                      QPoint(10, 10),
                      QPoint(10, 11),
                      QPoint(10, 12),
                      QPoint(10, 13)}};
  case 4:
    return {.name = QStringLiteral("Crossfire"),
            .script = QStringLiteral(
              "function onTick(tick) { var phases = [0,1,2,1]; var offset = "
              "phases[Math.floor(tick / 10) % phases.length]; var left = 5 + offset; "
              "var right = 14 - offset; var top = 5 + offset; var bottom = 12 - offset; "
              "return [{x:left,y:8},{x:left,y:9},{x:right,y:8},{x:right,y:9},{x:9,y:top},"
              "{x:10,y:bottom}]; }"),
            .walls = {QPoint(5, 8),
                      QPoint(6, 8),
                      QPoint(7, 8),
                      QPoint(8, 8),
                      QPoint(11, 8),
                      QPoint(12, 8),
                      QPoint(13, 8),
                      QPoint(14, 8),
                      QPoint(5, 9),
                      QPoint(6, 9),
                      QPoint(7, 9),
                      QPoint(8, 9),
                      QPoint(11, 9),
                      QPoint(12, 9),
                      QPoint(13, 9),
                      QPoint(14, 9)}};
  case 5:
    return {.name = QStringLiteral("Shifting Box"),
            .script = QStringLiteral(
              "function onTick(tick) { var phases = [0,1,2,1]; var d = "
              "phases[Math.floor(tick / 14) % phases.length]; var min = 4 + d; var max = "
              "15 - d; return "
              "[{x:min,y:min},{x:min+1,y:min},{x:max-1,y:min},{x:max,y:min},{x:min,y:"
              "max},{x:min+1,y:max},{x:max-1,y:max},{x:max,y:max},{x:min,y:min+1},{x:min,"
              "y:max-1},{x:max,y:min+1},{x:max,y:max-1}]; }"),
            .walls = {QPoint(4, 4),
                      QPoint(5, 4),
                      QPoint(6, 4),
                      QPoint(13, 4),
                      QPoint(14, 4),
                      QPoint(15, 4),
                      QPoint(4, 13),
                      QPoint(5, 13),
                      QPoint(6, 13),
                      QPoint(13, 13),
                      QPoint(14, 13),
                      QPoint(15, 13),
                      QPoint(4, 5),
                      QPoint(4, 12),
                      QPoint(15, 5),
                      QPoint(15, 12)}};
  default:
    break;
  }
  return {.name = QStringLiteral("Classic"), .script = QString(), .walls = {}};
}

auto wallsFromJsonArray(const QJsonArray& wallsJson) -> QList<QPoint> {
  QList<QPoint> walls;
  walls.reserve(wallsJson.size());
  for (const auto& item : wallsJson) {
    const auto wall = item.toObject();
    walls.append(
      QPoint(wall.value(QStringLiteral("x")).toInt(), wall.value(QStringLiteral("y")).toInt()));
  }
  return walls;
}

auto resolvedLevelDataFromJson(const QJsonArray& levelsJson, const int levelIndex)
  -> std::optional<ResolvedLevelData> {
  if (levelsJson.isEmpty()) {
    return std::nullopt;
  }
  const int levelCount = static_cast<int>(levelsJson.size());
  const int normalized = ((levelIndex % levelCount) + levelCount) % levelCount;
  const auto levelObject = levelsJson[normalized].toObject();

  ResolvedLevelData resolved;
  resolved.name = levelObject.value(QStringLiteral("name")).toString();
  resolved.script = levelObject.value(QStringLiteral("script")).toString();
  if (resolved.script.isEmpty()) {
    resolved.walls = wallsFromJsonArray(levelObject.value(QStringLiteral("walls")).toArray());
  }
  return resolved;
}

auto resolvedLevelDataFromJsonBytes(const QByteArray& levelsJsonBytes, const int levelIndex)
  -> std::optional<ResolvedLevelData> {
  const QJsonDocument document = QJsonDocument::fromJson(levelsJsonBytes);
  if (!document.isObject()) {
    return std::nullopt;
  }
  const QJsonArray levels = document.object().value(QStringLiteral("levels")).toArray();
  return resolvedLevelDataFromJson(levels, levelIndex);
}

auto levelCountFromJsonBytes(const QByteArray& levelsJsonBytes, const int fallbackCount) -> int {
  const QJsonDocument document = QJsonDocument::fromJson(levelsJsonBytes);
  if (!document.isObject()) {
    return fallbackCount;
  }
  const QJsonArray levels = document.object().value(QStringLiteral("levels")).toArray();
  if (levels.isEmpty()) {
    return fallbackCount;
  }
  return static_cast<int>(levels.size());
}

} // namespace snakegb::core
