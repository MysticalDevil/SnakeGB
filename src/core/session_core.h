#pragma once

#include "game_rules.h"
#include "session_step_types.h"
#include "session_runtime.h"
#include "state_snapshot.h"

#include <QPoint>

#include <cstddef>
#include <deque>

namespace snakegb::core {

class SessionCore
{
public:
    [[nodiscard]] auto state() -> SessionState & { return m_state; }
    [[nodiscard]] auto state() const -> const SessionState & { return m_state; }
    [[nodiscard]] auto body() -> std::deque<QPoint> & { return m_body; }
    [[nodiscard]] auto body() const -> const std::deque<QPoint> & { return m_body; }

    [[nodiscard]] auto inputQueue() -> std::deque<QPoint> & { return m_inputQueue; }
    [[nodiscard]] auto inputQueue() const -> const std::deque<QPoint> & { return m_inputQueue; }

    void setDirection(const QPoint &direction);
    [[nodiscard]] auto direction() const -> QPoint;

    [[nodiscard]] auto tickCounter() const -> int;
    void incrementTick();
    [[nodiscard]] auto headPosition() const -> QPoint;

    auto enqueueDirection(const QPoint &direction, std::size_t maxQueueSize = 2) -> bool;
    auto consumeQueuedInput(QPoint &nextInput) -> bool;
    void clearQueuedInput();
    void setBody(const std::deque<QPoint> &body);
    void applyMovement(const QPoint &newHead, bool grew);
    auto checkCollision(const QPoint &head, int boardWidth, int boardHeight) -> CollisionOutcome;
    auto consumeFood(const QPoint &head, int boardWidth, int boardHeight,
                     const std::function<int(int)> &randomBounded) -> FoodConsumptionResult;
    auto consumePowerUp(const QPoint &head, int baseDurationTicks, bool halfDurationForRich)
        -> PowerUpConsumptionResult;
    auto tickBuffCountdown() -> bool;
    auto spawnFood(int boardWidth, int boardHeight, const std::function<int(int)> &randomBounded)
        -> bool;
    auto spawnPowerUp(int boardWidth, int boardHeight, const std::function<int(int)> &randomBounded)
        -> bool;
    auto applyMagnetAttraction(int boardWidth, int boardHeight) -> MagnetAttractionResult;
    auto advanceSessionStep(const SessionAdvanceConfig &config,
                            const std::function<int(int)> &randomBounded) -> SessionAdvanceResult;

    void resetTransientRuntimeState();
    void resetReplayRuntimeState();

    [[nodiscard]] auto snapshot(const std::deque<QPoint> &body) const -> StateSnapshot;
    void restoreSnapshot(const StateSnapshot &snapshot);

private:
    [[nodiscard]] auto isOccupied(const QPoint &point) const -> bool;

    SessionState m_state;
    std::deque<QPoint> m_body;
    std::deque<QPoint> m_inputQueue;
};

} // namespace snakegb::core
