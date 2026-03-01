#include "adapter/session/state.h"

using namespace Qt::StringLiterals;

namespace snakegb::adapter {

auto decodeSessionSnapshot(const QVariantMap &data) -> std::optional<SessionSnapshot> {
    SessionSnapshot snapshot;
    snapshot.score = data.value(u"score"_s).toInt();
    snapshot.food = data.value(u"food"_s).toPoint();
    snapshot.direction = data.value(u"dir"_s).toPoint();

    const QVariantList obstacleList = data.value(u"obstacles"_s).toList();
    for (const auto &item : obstacleList) {
        snapshot.obstacles.append(item.toPoint());
    }

    const QVariantList bodyList = data.value(u"body"_s).toList();
    for (const auto &item : bodyList) {
        snapshot.body.emplace_back(item.toPoint());
    }
    if (snapshot.body.empty()) {
        return std::nullopt;
    }

    return snapshot;
}

auto toCoreStateSnapshot(const SessionSnapshot &snapshot) -> snakegb::core::StateSnapshot
{
    return {
        .state =
            {
                .food = snapshot.food,
                .direction = snapshot.direction,
                .score = snapshot.score,
                .obstacles = snapshot.obstacles,
            },
        .body = snapshot.body,
    };
}

auto fromCoreStateSnapshot(const snakegb::core::StateSnapshot &snapshot) -> SessionSnapshot
{
    return {
        .score = snapshot.state.score,
        .food = snapshot.state.food,
        .direction = snapshot.state.direction,
        .obstacles = snapshot.state.obstacles,
        .body = snapshot.body,
    };
}

} // namespace snakegb::adapter
