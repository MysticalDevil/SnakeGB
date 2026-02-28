#include "session_core.h"

namespace snakegb::core {

void SessionCore::setDirection(const QPoint &direction)
{
    m_state.direction = direction;
}

auto SessionCore::direction() const -> QPoint
{
    return m_state.direction;
}

auto SessionCore::tickCounter() const -> int
{
    return m_state.tickCounter;
}

auto SessionCore::headPosition() const -> QPoint
{
    return m_body.empty() ? QPoint() : m_body.front();
}

void SessionCore::incrementTick()
{
    m_state.tickCounter++;
}

auto SessionCore::enqueueDirection(const QPoint &direction, const std::size_t maxQueueSize) -> bool
{
    if (m_inputQueue.size() >= maxQueueSize) {
        return false;
    }

    const QPoint lastDirection = m_inputQueue.empty() ? m_state.direction : m_inputQueue.back();
    if (((direction.x() != 0) && lastDirection.x() == -direction.x()) ||
        ((direction.y() != 0) && lastDirection.y() == -direction.y())) {
        return false;
    }

    m_inputQueue.push_back(direction);
    return true;
}

auto SessionCore::consumeQueuedInput(QPoint &nextInput) -> bool
{
    if (m_inputQueue.empty()) {
        return false;
    }

    nextInput = m_inputQueue.front();
    m_inputQueue.pop_front();
    return true;
}

void SessionCore::clearQueuedInput()
{
    m_inputQueue.clear();
}

void SessionCore::setBody(const std::deque<QPoint> &body)
{
    m_body = body;
}

void SessionCore::applyMovement(const QPoint &newHead, const bool grew)
{
    m_body.push_front(newHead);
    if (!grew && !m_body.empty()) {
        m_body.pop_back();
    }
}

auto SessionCore::checkCollision(const QPoint &head, const int boardWidth, const int boardHeight)
    -> CollisionOutcome
{
    const auto outcome = collisionOutcomeForHead(head, boardWidth, boardHeight, m_state.obstacles,
                                                 m_body,
                                                 m_state.activeBuff ==
                                                     static_cast<int>(BuffId::Ghost),
                                                 m_state.activeBuff ==
                                                     static_cast<int>(BuffId::Portal),
                                                 m_state.activeBuff ==
                                                     static_cast<int>(BuffId::Laser),
                                                 m_state.shieldActive);

    if (outcome.consumeLaser && outcome.obstacleIndex >= 0 &&
        outcome.obstacleIndex < m_state.obstacles.size()) {
        m_state.obstacles.removeAt(outcome.obstacleIndex);
        m_state.activeBuff = static_cast<int>(BuffId::None);
    }

    if (outcome.consumeShield) {
        m_state.shieldActive = false;
    }

    return outcome;
}

auto SessionCore::consumeFood(const QPoint &head, const int boardWidth, const int boardHeight,
                              const std::function<int(int)> &randomBounded)
    -> FoodConsumptionResult
{
    const auto result =
        planFoodConsumption(head, m_state, boardWidth, boardHeight, randomBounded);
    if (!result.ate) {
        return result;
    }

    m_state.score = result.newScore;
    if (result.triggerChoice) {
        m_state.lastRoguelikeChoiceScore = m_state.score;
    }
    return result;
}

auto SessionCore::consumePowerUp(const QPoint &head, const int baseDurationTicks,
                                 const bool halfDurationForRich) -> PowerUpConsumptionResult
{
    const auto result = planPowerUpConsumption(head, m_state, baseDurationTicks, halfDurationForRich);
    if (!result.ate) {
        return result;
    }

    if (result.shieldActivated) {
        m_state.shieldActive = true;
    }
    if (result.miniApplied) {
        m_body = applyMiniShrink(m_body, 3);
    }
    m_state.activeBuff = result.activeBuffAfter;
    m_state.buffTicksRemaining = result.buffTicksRemaining;
    m_state.buffTicksTotal = result.buffTicksTotal;
    m_state.powerUpPos = QPoint(-1, -1);
    return result;
}

void SessionCore::resetTransientRuntimeState()
{
    m_state.direction = {0, -1};
    m_inputQueue.clear();
    m_state.activeBuff = 0;
    m_state.buffTicksRemaining = 0;
    m_state.buffTicksTotal = 0;
    m_state.shieldActive = false;
    m_state.powerUpPos = QPoint(-1, -1);
}

void SessionCore::resetReplayRuntimeState()
{
    m_state.tickCounter = 0;
    m_state.lastRoguelikeChoiceScore = -1000;
}

auto SessionCore::snapshot(const std::deque<QPoint> &body) const -> StateSnapshot
{
    return {
        .state = m_state,
        .body = body.empty() ? m_body : body,
    };
}

void SessionCore::restoreSnapshot(const StateSnapshot &snapshot)
{
    m_state = snapshot.state;
    m_body = snapshot.body;
    m_inputQueue.clear();
}

} // namespace snakegb::core
