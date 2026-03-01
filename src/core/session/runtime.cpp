#include "core/session/runtime.h"

namespace {

// NOLINTNEXTLINE(bugprone-easily-swappable-parameters)
auto buildPowerUpResult(const int powerUpType, const int baseDurationTicks,
                        const bool halfDurationForRich) -> snakegb::core::PowerUpConsumptionResult
{
    snakegb::core::PowerUpConsumptionResult result;
    const int acquired = powerUpType;
    if (acquired == static_cast<int>(snakegb::core::BuffId::Shield)) {
        result.shieldActivated = true;
    }

    if (acquired == static_cast<int>(snakegb::core::BuffId::Mini)) {
        result.miniApplied = true;
        result.activeBuffAfter = static_cast<int>(snakegb::core::BuffId::None);
    } else {
        result.activeBuffAfter = acquired;
    }

    const snakegb::core::BuffId durationBuff =
        halfDurationForRich ? static_cast<snakegb::core::BuffId>(result.activeBuffAfter)
                            : static_cast<snakegb::core::BuffId>(acquired);
    const int duration =
        halfDurationForRich ? snakegb::core::buffDurationTicks(durationBuff, baseDurationTicks)
                            : baseDurationTicks;
    result.buffTicksRemaining = duration;
    result.buffTicksTotal = duration;
    result.slowMode = (acquired == static_cast<int>(snakegb::core::BuffId::Slow));
    return result;
}

} // namespace

namespace snakegb::core {

// NOLINTBEGIN(bugprone-easily-swappable-parameters)
auto planFoodConsumption(const QPoint &head, const QPoint &food, const int boardWidth,
                         const int boardHeight, const int activeBuff, const int currentScore,
                         const int lastChoiceScore, const QPoint &powerUpPos,
                         const std::function<int(int)> &randomBounded)
    -> FoodConsumptionResult
{
    FoodConsumptionResult result;
    const QPoint wrapped = wrapPoint(head, boardWidth, boardHeight);
    if (wrapped != food) {
        return result;
    }

    result.ate = true;
    result.previousScore = currentScore;
    const int points = foodPointsForBuff(static_cast<BuffId>(activeBuff));
    result.newScore = currentScore + points;
    result.pan = (static_cast<float>(wrapped.x()) / static_cast<float>(boardWidth) - 0.5F) * 1.4F;

    const int chancePercent = roguelikeChoiceChancePercent({
        .previousScore = result.previousScore,
        .newScore = result.newScore,
        .lastChoiceScore = lastChoiceScore,
    });
    if (chancePercent >= 100) {
        result.triggerChoice = true;
        return result;
    }
    if (chancePercent > 0 && randomBounded(100) < chancePercent) {
        result.triggerChoice = true;
        return result;
    }

    if (randomBounded(100) < 15 && powerUpPos == QPoint(-1, -1)) {
        result.spawnPowerUp = true;
    }
    return result;
}
// NOLINTEND(bugprone-easily-swappable-parameters)

auto planFoodConsumption(const QPoint &head, const SessionState &state, const int boardWidth,
                         const int boardHeight, const std::function<int(int)> &randomBounded)
    -> FoodConsumptionResult
{
    return planFoodConsumption(head, state.food, boardWidth, boardHeight, state.activeBuff,
                               state.score, state.lastRoguelikeChoiceScore, state.powerUpPos,
                               randomBounded);
}

auto planPowerUpConsumption(const QPoint &head, const QPoint &powerUpPos, const int powerUpType,
                            const int baseDurationTicks, const bool halfDurationForRich)
    -> PowerUpConsumptionResult
{
    PowerUpConsumptionResult result;
    if (head != powerUpPos) {
        return result;
    }

    result.ate = true;
    result = buildPowerUpResult(powerUpType, baseDurationTicks, halfDurationForRich);
    result.ate = true;
    return result;
}

auto planPowerUpConsumption(const QPoint &head, const SessionState &state,
                            const int baseDurationTicks, const bool halfDurationForRich)
    -> PowerUpConsumptionResult
{
    return planPowerUpConsumption(head, state.powerUpPos, state.powerUpType, baseDurationTicks,
                                  halfDurationForRich);
}

auto planPowerUpAcquisition(const int powerUpType, const int baseDurationTicks,
                            const bool halfDurationForRich) -> PowerUpConsumptionResult
{
    PowerUpConsumptionResult result = buildPowerUpResult(powerUpType, baseDurationTicks, halfDurationForRich);
    result.ate = true;
    return result;
}

auto applyMiniShrink(const std::deque<QPoint> &body, const std::size_t minimumLength)
    -> std::deque<QPoint>
{
    if (body.size() <= minimumLength) {
        return body;
    }
    std::deque<QPoint> nextBody;
    const std::size_t targetLength = miniShrinkTargetLength(body.size(), minimumLength);
    for (std::size_t i = 0; i < targetLength && i < body.size(); ++i) {
        nextBody.push_back(body[i]);
    }
    return nextBody;
}

auto applyMagnetAttraction(const QPoint &food, const QPoint &head, const int boardWidth,
                           const int boardHeight, const std::function<bool(const QPoint &)> &isOccupied,
                           const QPoint &powerUpPos) -> MagnetAttractionResult
{
    MagnetAttractionResult result;
    if (food == head) {
        result.ate = true;
        result.newFood = food;
        return result;
    }

    const QList<QPoint> candidates = magnetCandidateSpots(food, head, boardWidth, boardHeight);
    for (const QPoint &candidate : candidates) {
        if (candidate == food) {
            continue;
        }
        if (candidate == head || (!isOccupied(candidate) && candidate != powerUpPos)) {
            result.moved = true;
            result.ate = (candidate == head);
            result.newFood = candidate;
            return result;
        }
    }
    return result;
}

auto applyMagnetAttraction(const QPoint &head, const int boardWidth, const int boardHeight,
                           const SessionState &state,
                           const std::function<bool(const QPoint &)> &isOccupied)
    -> MagnetAttractionResult
{
    return applyMagnetAttraction(state.food, head, boardWidth, boardHeight, isOccupied,
                                 state.powerUpPos);
}

} // namespace snakegb::core
