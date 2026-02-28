#pragma once

#include "game_rules.h"
#include "replay_types.h"
#include "session_step_types.h"
#include "session_runtime.h"
#include "state_snapshot.h"

#include <QPoint>

#include <cstddef>
#include <deque>
#include <optional>

namespace snakegb::core {

struct PreviewSeed {
    QList<QPoint> obstacles;
    std::deque<QPoint> body;
    QPoint food = {0, 0};
    QPoint direction = {0, -1};
    QPoint powerUpPos = {-1, -1};
    int powerUpType = 0;
    int score = 0;
    int tickCounter = 0;
    int activeBuff = 0;
    int buffTicksRemaining = 0;
    int buffTicksTotal = 0;
    bool shieldActive = false;
};

struct ReplayTimelineApplication {
    bool appliedInput = false;
    QPoint appliedDirection = {0, 0};
    std::optional<int> choiceIndex;
};

struct RuntimeUpdateResult {
    bool buffExpired = false;
};

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
    auto applyChoiceSelection(int powerUpType, int baseDurationTicks, bool halfDurationForRich)
        -> PowerUpConsumptionResult;
    auto spawnFood(int boardWidth, int boardHeight, const std::function<int(int)> &randomBounded)
        -> bool;
    auto spawnPowerUp(int boardWidth, int boardHeight, const std::function<int(int)> &randomBounded)
        -> bool;
    auto applyMagnetAttraction(int boardWidth, int boardHeight) -> MagnetAttractionResult;
    auto applyReplayTimeline(const QList<ReplayFrame> &inputFrames, int &inputHistoryIndex,
                             const QList<ChoiceRecord> &choiceFrames, int &choiceHistoryIndex)
        -> ReplayTimelineApplication;
    auto beginRuntimeUpdate() -> RuntimeUpdateResult;
    void finishRuntimeUpdate();
    auto advanceSessionStep(const SessionAdvanceConfig &config,
                            const std::function<int(int)> &randomBounded) -> SessionAdvanceResult;
    void bootstrapForLevel(QList<QPoint> obstacles, int boardWidth, int boardHeight);
    void restorePersistedSession(const StateSnapshot &snapshot);
    void seedPreviewState(const PreviewSeed &seed);

    void resetTransientRuntimeState();
    void resetReplayRuntimeState();

    [[nodiscard]] auto snapshot(const std::deque<QPoint> &body) const -> StateSnapshot;
    void restoreSnapshot(const StateSnapshot &snapshot);

private:
    void incrementTick();
    auto tickBuffCountdown() -> bool;
    [[nodiscard]] auto isOccupied(const QPoint &point) const -> bool;
    void applyPowerUpResult(const PowerUpConsumptionResult &result);

    SessionState m_state;
    std::deque<QPoint> m_body;
    std::deque<QPoint> m_inputQueue;
};

} // namespace snakegb::core
