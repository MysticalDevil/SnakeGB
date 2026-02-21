#pragma once

#include <functional>
#include <QList>
#include <QPoint>
#include <deque>

namespace snakegb::core {

struct RoguelikeChoiceContext {
    int previousScore = 0;
    int newScore = 0;
    int lastChoiceScore = -1000;
};

struct CollisionProbe {
    bool hitsObstacle = false;
    int obstacleIndex = -1;
    bool hitsBody = false;
};

struct CollisionOutcome {
    bool collision = false;
    bool consumeShield = false;
    bool consumeLaser = false;
    int obstacleIndex = -1;
};

// Returns [0, 100]. 100 means guaranteed trigger, 0 means never trigger.
auto roguelikeChoiceChancePercent(const RoguelikeChoiceContext &ctx) -> int;
auto tickIntervalForScore(int score) -> int;

auto wrapAxis(int value, int size) -> int;
auto wrapPoint(const QPoint &point, int boardWidth, int boardHeight) -> QPoint;
auto buildSafeInitialSnakeBody(const QList<QPoint> &obstacles, int boardWidth, int boardHeight) -> std::deque<QPoint>;
auto collectFreeSpots(int boardWidth, int boardHeight,
                      const std::function<bool(const QPoint &)> &isBlocked) -> QList<QPoint>;
auto pickRandomFreeSpot(int boardWidth, int boardHeight,
                        const std::function<bool(const QPoint &)> &isBlocked,
                        const std::function<int(int)> &pickIndex, QPoint &pickedPoint) -> bool;
auto magnetCandidateSpots(const QPoint &food, const QPoint &head, int boardWidth, int boardHeight) -> QList<QPoint>;
auto probeCollision(const QPoint &wrappedHead, const QList<QPoint> &obstacles, const std::deque<QPoint> &snakeBody,
                    bool ghostActive) -> CollisionProbe;
auto collisionOutcomeForHead(const QPoint &head, int boardWidth, int boardHeight, const QList<QPoint> &obstacles,
                             const std::deque<QPoint> &snakeBody, bool ghostActive, bool portalActive,
                             bool laserActive, bool shieldActive) -> CollisionOutcome;

} // namespace snakegb::core
