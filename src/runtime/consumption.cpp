#include "runtime/game_logic.h"

#include "adapter/profile_bridge.h"
#include "core/game_rules.h"
#include "core/session_runtime.h"
#include "fsm/game_state.h"

#include <algorithm>

using namespace Qt::StringLiterals;

namespace
{
constexpr int BuffDurationTicks = 40;
} // namespace

void GameLogic::handleFoodConsumption(const QPoint &head)
{
    const QPoint p = snakegb::core::wrapPoint(head, BOARD_WIDTH, BOARD_HEIGHT);
    const auto result = snakegb::core::planFoodConsumption(
        p, m_food, BOARD_WIDTH, BOARD_HEIGHT, m_activeBuff, m_score, m_lastRoguelikeChoiceScore,
        m_powerUpPos, [this](const int bound) { return m_rng.bounded(bound); });
    if (!result.ate) {
        return;
    }

    m_score = result.newScore;
    snakegb::adapter::logFoodEaten(m_profileManager.get());

    emit foodEaten(result.pan);

    m_timer->setInterval(normalTickIntervalMs());
    emit scoreChanged();
    spawnFood();

    if (result.triggerChoice) {
        m_lastRoguelikeChoiceScore = m_score;
        if (m_state == Replaying) {
            generateChoices();
        } else {
            requestStateChange(ChoiceSelection);
        }
    } else if (result.spawnPowerUp) {
        spawnPowerUp();
    }

    triggerHaptic(std::min(5, 2 + (m_score / 10)));
}

void GameLogic::handlePowerUpConsumption(const QPoint &head)
{
    const QPoint p = snakegb::core::wrapPoint(head, BOARD_WIDTH, BOARD_HEIGHT);
    const auto result = snakegb::core::planPowerUpConsumption(
        p, m_powerUpPos, m_powerUpType, BuffDurationTicks, true);
    if (!result.ate) {
        return;
    }

    snakegb::adapter::discoverFruit(m_profileManager.get(), m_powerUpType);
    if (result.shieldActivated) {
        m_shieldActive = true;
    }
    if (result.miniApplied) {
        const auto nextBody = snakegb::core::applyMiniShrink(m_snakeModel.body(), 3);
        m_snakeModel.reset(nextBody);
        emit eventPrompt(u"MINI BLITZ! SIZE CUT"_s);
    }
    m_activeBuff = static_cast<PowerUp>(result.activeBuffAfter);
    m_buffTicksRemaining = result.buffTicksRemaining;
    m_buffTicksTotal = result.buffTicksTotal;

    m_powerUpPos = QPoint(-1, -1);

    emit powerUpEaten();
    m_timer->setInterval(result.slowMode ? 250 : normalTickIntervalMs());

    triggerHaptic(5);
    emit buffChanged();
    emit powerUpChanged();
}

auto GameLogic::normalTickIntervalMs() const -> int
{
    if (m_activeBuff == Slow) {
        return 250;
    }
    return snakegb::core::tickIntervalForScore(m_score);
}
