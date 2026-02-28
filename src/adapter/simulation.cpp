#include "adapter/game_logic.h"

#include "adapter/profile_bridge.h"
#include "core/game_rules.h"
#include "core/replay_timeline.h"
#include "core/session_runtime.h"

using namespace Qt::StringLiterals;

auto GameLogic::advanceSessionStep(const snakegb::core::SessionAdvanceConfig &config)
    -> snakegb::core::SessionAdvanceResult
{
    const auto result = m_sessionCore.advanceSessionStep(
        config, [this](const int bound) { return m_rng.bounded(bound); });

    applyCollisionMitigationEffects(result);

    if (result.ateFood) {
        applyFoodConsumptionEffects(result.foodPan, result.triggerChoice, result.spawnPowerUp);
    }

    if (result.atePowerUp) {
        applyPowerUpConsumptionEffects(result);
    }

    if (result.appliedMovement) {
        applyMovementEffects(result);
    }

    return result;
}

// NOLINTNEXTLINE(bugprone-easily-swappable-parameters)
void GameLogic::applyReplayTimelineForCurrentTick(int &inputHistoryIndex, int &choiceHistoryIndex)
{
    snakegb::core::applyReplayChoiceForTick(
        m_bestChoiceHistory, m_sessionCore.tickCounter(), choiceHistoryIndex,
        [this](const int index) { selectChoice(index); });
    snakegb::core::applyReplayInputsForTick(
        m_bestInputHistory, m_sessionCore.tickCounter(), inputHistoryIndex,
        [this](const QPoint &direction) { m_sessionCore.setDirection(direction); });
}

void GameLogic::applyCollisionMitigationEffects(
    const snakegb::core::SessionAdvanceResult &result)
{
    if (result.consumeLaser && result.obstacleIndex >= 0 &&
        result.obstacleIndex < m_session.obstacles.size()) {
        emit obstaclesChanged();
        triggerHaptic(8);
        emit buffChanged();
    }
    if (result.consumeShield) {
        triggerHaptic(5);
        emit buffChanged();
    }
}

void GameLogic::applyChoiceTransition()
{
    if (m_state == Replaying) {
        generateChoices();
    } else {
        requestStateChange(ChoiceSelection);
    }
}

void GameLogic::applyFoodConsumptionEffects(const float pan, const bool triggerChoice,
                                            const bool spawnPowerUpAfterFood)
{
    emit foodEaten(pan);
    m_timer->setInterval(normalTickIntervalMs());
    emit scoreChanged();
    spawnFood();

    if (triggerChoice) {
        applyChoiceTransition();
    } else if (spawnPowerUpAfterFood) {
        spawnPowerUp();
    }

    triggerHaptic(std::min(5, 2 + (m_session.score / 10)));
}

void GameLogic::applyPowerUpConsumptionEffects(
    const snakegb::core::SessionAdvanceResult &result)
{
    snakegb::adapter::discoverFruit(m_profileManager.get(), m_session.powerUpType);
    if (result.miniApplied) {
        syncSnakeModelFromCore();
        emit eventPrompt(u"MINI BLITZ! SIZE CUT"_s);
    }

    emit powerUpEaten();
    m_timer->setInterval(result.slowMode ? 250 : normalTickIntervalMs());

    triggerHaptic(5);
    emit buffChanged();
    emit powerUpChanged();
}

void GameLogic::applyMovementEffects(const snakegb::core::SessionAdvanceResult &result)
{
    syncSnakeModelFromCore();
    m_currentRecording.append(m_sessionCore.headPosition());

    if (m_ghostFrameIndex < static_cast<int>(m_bestRecording.size())) {
        m_ghostFrameIndex++;
        emit ghostChanged();
    }
    if (result.movedFood) {
        emit foodChanged();
    }
    if (result.magnetAteFood) {
        applyFoodConsumptionEffects(result.magnetFoodPan, result.triggerChoiceAfterMagnet,
                                    result.spawnPowerUpAfterMagnet);
    }
    checkAchievements();
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
    m_sessionCore.incrementTick();
}

void GameLogic::applyMagnetAttraction()
{
    const QPoint head = m_sessionCore.headPosition();
    const auto result = m_sessionCore.applyMagnetAttraction(BOARD_WIDTH, BOARD_HEIGHT);
    if (result.moved) {
        emit foodChanged();
    }
    if (result.ate) {
        handleFoodConsumption(head);
    }
}

void GameLogic::deactivateBuff()
{
    m_timer->setInterval(normalTickIntervalMs());
    emit buffChanged();
}
