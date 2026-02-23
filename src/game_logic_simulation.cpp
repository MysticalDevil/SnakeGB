#include "game_logic.h"

#include "core/game_rules.h"
#include "core/session_runtime.h"

auto GameLogic::checkCollision(const QPoint &head) -> bool
{
    const snakegb::core::CollisionOutcome outcome = snakegb::core::collisionOutcomeForHead(
        head, BOARD_WIDTH, BOARD_HEIGHT, m_obstacles, m_snakeModel.body(), m_activeBuff == Ghost,
        m_activeBuff == Portal, m_activeBuff == Laser, m_shieldActive);

    if (outcome.consumeLaser && outcome.obstacleIndex >= 0 &&
        outcome.obstacleIndex < m_obstacles.size()) {
        m_obstacles.removeAt(outcome.obstacleIndex);
        m_activeBuff = None;
        emit obstaclesChanged();
        triggerHaptic(8);
        emit buffChanged();
    }
    if (outcome.consumeShield) {
        m_shieldActive = false;
        triggerHaptic(5);
        emit buffChanged();
    }
    return outcome.collision;
}

void GameLogic::applyMovement(const QPoint &newHead, const bool grew)
{
    const QPoint p = snakegb::core::wrapPoint(newHead, BOARD_WIDTH, BOARD_HEIGHT);

    m_snakeModel.moveHead(p, grew);
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
    m_gameTickCounter++;
}

void GameLogic::applyMagnetAttraction()
{
    if (m_activeBuff != Magnet || m_food == QPoint(-1, -1) || m_snakeModel.body().empty()) {
        return;
    }

    const QPoint head = m_snakeModel.body().front();
    const auto result = snakegb::core::applyMagnetAttraction(
        m_food, head, BOARD_WIDTH, BOARD_HEIGHT,
        [this](const QPoint &pos) { return isOccupied(pos); }, m_powerUpPos);
    if (result.moved) {
        m_food = result.newFood;
        emit foodChanged();
    }
    if (result.ate) {
        handleFoodConsumption(head);
    }
}

void GameLogic::deactivateBuff()
{
    m_activeBuff = None;
    m_buffTicksRemaining = 0;
    m_buffTicksTotal = 0;
    m_shieldActive = false;
    m_timer->setInterval(normalTickIntervalMs());
    emit buffChanged();
}
