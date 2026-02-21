#include "level_runtime.h"

#include <cmath>

namespace snakegb::core {

auto dynamicObstaclesForLevel(QStringView levelName, int gameTickCounter) -> std::optional<QList<QPoint>> {
    if (levelName == u"Dynamic Pulse") {
        const int a = static_cast<int>(std::floor(std::abs(std::sin(gameTickCounter * 0.1)) * 10.0));
        const int x1 = 5 + a;
        const int x2 = 15 - a;
        return QList<QPoint>{QPoint(x1, 5), QPoint(x1, 6), QPoint(x2, 12), QPoint(x2, 13)};
    }

    if (levelName == u"Crossfire") {
        const int t = (gameTickCounter / 2) % 8;
        const int left = 4 + t;
        const int right = 15 - t;
        return QList<QPoint>{
            QPoint(left, 8), QPoint(left, 9), QPoint(right, 8), QPoint(right, 9), QPoint(9, 4 + t), QPoint(10, 13 - t)};
    }

    if (levelName == u"Shifting Box") {
        const int d = static_cast<int>(std::floor((std::sin(gameTickCounter * 0.08) + 1.0) * 2.0));
        const int min = 4 + d;
        const int max = 15 - d;
        return QList<QPoint>{
            QPoint(min, min),       QPoint(min + 1, min),   QPoint(max - 1, min), QPoint(max, min),
            QPoint(min, max),       QPoint(min + 1, max),   QPoint(max - 1, max), QPoint(max, max),
            QPoint(min, min + 1),   QPoint(min, max - 1),   QPoint(max, min + 1), QPoint(max, max - 1)};
    }

    return std::nullopt;
}

} // namespace snakegb::core

