#pragma once

#include <optional>

#include <QByteArray>
#include <QJsonArray>
#include <QList>
#include <QPoint>
#include <QString>
#include <QStringView>

namespace nenoserpent::core {

struct FallbackLevelData {
  QString name;
  QString script;
  QList<QPoint> walls;
};

using ResolvedLevelData = FallbackLevelData;

auto dynamicObstaclesForLevel(QStringView levelName, int gameTickCounter)
  -> std::optional<QList<QPoint>>;
auto normalizedFallbackLevelIndex(int levelIndex) -> int;
auto fallbackLevelData(int levelIndex) -> FallbackLevelData;
auto wallsFromJsonArray(const QJsonArray& wallsJson) -> QList<QPoint>;
auto resolvedLevelDataFromJson(const QJsonArray& levelsJson, int levelIndex)
  -> std::optional<ResolvedLevelData>;
auto resolvedLevelDataFromJsonBytes(const QByteArray& levelsJsonBytes, int levelIndex)
  -> std::optional<ResolvedLevelData>;
auto levelCountFromJsonBytes(const QByteArray& levelsJsonBytes, int fallbackCount) -> int;

} // namespace nenoserpent::core
