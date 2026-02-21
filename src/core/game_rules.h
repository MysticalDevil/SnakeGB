#pragma once

#include <QList>
#include <QPoint>
#include <deque>

namespace snakegb::core {

struct RoguelikeChoiceContext {
    int previousScore = 0;
    int newScore = 0;
    int lastChoiceScore = -1000;
};

// Returns [0, 100]. 100 means guaranteed trigger, 0 means never trigger.
auto roguelikeChoiceChancePercent(const RoguelikeChoiceContext &ctx) -> int;

auto wrapAxis(int value, int size) -> int;
auto wrapPoint(const QPoint &point, int boardWidth, int boardHeight) -> QPoint;
auto buildSafeInitialSnakeBody(const QList<QPoint> &obstacles, int boardWidth, int boardHeight) -> std::deque<QPoint>;

} // namespace snakegb::core
