#include "adapter/game_logic.h"

#include "core/game_rules.h"
#include "core/session_runtime.h"

auto GameLogic::checkCollision(const QPoint &head) -> bool
{
    const auto outcome = m_sessionCore.checkCollision(head, BOARD_WIDTH, BOARD_HEIGHT);

    if (outcome.consumeLaser && outcome.obstacleIndex >= 0 &&
        outcome.obstacleIndex < m_session.obstacles.size()) {
        emit obstaclesChanged();
        triggerHaptic(8);
        emit buffChanged();
    }
    if (outcome.consumeShield) {
        triggerHaptic(5);
        emit buffChanged();
    }
    return outcome.collision;
}

void GameLogic::applyMovement(const QPoint &newHead, const bool grew)
{
    const QPoint p = snakegb::core::wrapPoint(newHead, BOARD_WIDTH, BOARD_HEIGHT);

    m_sessionCore.applyMovement(p, grew);
    syncSnakeModelFromCore();
    m_currentRecording.append(p);

    if (m_ghostFrameIndex < static_cast<int>(m_bestRecording.size())) {
        m_ghostFrameIndex++;
        emit ghostChanged();
    }
    applyMagnetAttraction();
    checkAchievements();
}

void GameLogic::applyPostTickTasks()
{
    if (!m_currentScript.isEmpty()) {
        runLevelScript();
    }
    m_session.tickCounter++;
}

void GameLogic::applyMagnetAttraction()
{
    if (m_session.activeBuff != Magnet || m_session.food == QPoint(-1, -1) ||
        m_sessionCore.body().empty()) {
        return;
    }

    const QPoint head = m_sessionCore.headPosition();
    const auto result = snakegb::core::applyMagnetAttraction(
        head, BOARD_WIDTH, BOARD_HEIGHT, m_session,
        [this](const QPoint &pos) { return isOccupied(pos); });
    if (result.moved) {
        m_session.food = result.newFood;
        emit foodChanged();
    }
    if (result.ate) {
        handleFoodConsumption(head);
    }
}

void GameLogic::deactivateBuff()
{
    m_session.activeBuff = None;
    m_session.buffTicksRemaining = 0;
    m_session.buffTicksTotal = 0;
    m_session.shieldActive = false;
    m_timer->setInterval(normalTickIntervalMs());
    emit buffChanged();
}
