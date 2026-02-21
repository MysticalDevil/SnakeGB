#pragma once

#include <QList>
#include <QPoint>
#include <QJsonArray>
#include <QString>
#include <QStringView>
#include <optional>

namespace snakegb::core {

struct FallbackLevelData {
    QString name;
    QString script;
    QList<QPoint> walls;
};

auto dynamicObstaclesForLevel(QStringView levelName, int gameTickCounter) -> std::optional<QList<QPoint>>;
auto normalizedFallbackLevelIndex(int levelIndex) -> int;
auto fallbackLevelData(int levelIndex) -> FallbackLevelData;
auto wallsFromJsonArray(const QJsonArray &wallsJson) -> QList<QPoint>;

} // namespace snakegb::core
