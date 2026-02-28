#include "adapter/game_logic.h"

#include "adapter/profile_bridge.h"

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
    const auto result = m_sessionCore.applyReplayTimeline(m_bestInputHistory, inputHistoryIndex,
                                                          m_bestChoiceHistory,
                                                          choiceHistoryIndex);
    if (result.choiceIndex.has_value()) {
        selectChoice(*result.choiceIndex);
    }
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
    m_timer->setInterval(m_sessionCore.currentTickIntervalMs());
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
    m_timer->setInterval(result.slowMode ? 250 : m_sessionCore.currentTickIntervalMs());

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

void GameLogic::applyPostTickTasks()
{
    if (!m_currentScript.isEmpty()) {
        runLevelScript();
    }
    m_sessionCore.finishRuntimeUpdate();
}

void GameLogic::deactivateBuff()
{
    m_timer->setInterval(m_sessionCore.currentTickIntervalMs());
    emit buffChanged();
}
