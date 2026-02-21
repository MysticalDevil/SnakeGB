#pragma once

#include <QList>
#include <QPoint>
#include <QVariantMap>

#include <deque>
#include <optional>

namespace snakegb::adapter {

struct SessionSnapshot {
    int score = 0;
    QPoint food;
    QPoint direction;
    QList<QPoint> obstacles;
    std::deque<QPoint> body;
};

[[nodiscard]] auto decodeSessionSnapshot(const QVariantMap &data) -> std::optional<SessionSnapshot>;

} // namespace snakegb::adapter
