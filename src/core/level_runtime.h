#pragma once

#include <QList>
#include <QPoint>
#include <QStringView>
#include <optional>

namespace snakegb::core {

auto dynamicObstaclesForLevel(QStringView levelName, int gameTickCounter) -> std::optional<QList<QPoint>>;

} // namespace snakegb::core

