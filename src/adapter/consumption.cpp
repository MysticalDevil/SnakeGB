#include "adapter/game_logic.h"

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
    const auto result = m_sessionCore.consumeFood(
        head, BOARD_WIDTH, BOARD_HEIGHT, [this](const int bound) { return m_rng.bounded(bound); });
    if (!result.ate) {
        return;
    }

    snakegb::adapter::logFoodEaten(m_profileManager.get());

    emit foodEaten(result.pan);

    m_timer->setInterval(m_sessionCore.currentTickIntervalMs());
    emit scoreChanged();
    spawnFood();

    if (result.triggerChoice) {
        if (m_state == Replaying) {
            generateChoices();
        } else {
            requestStateChange(ChoiceSelection);
        }
    } else if (result.spawnPowerUp) {
        spawnPowerUp();
    }

    triggerHaptic(std::min(5, 2 + (m_session.score / 10)));
}

void GameLogic::handlePowerUpConsumption(const QPoint &head)
{
    const auto result = m_sessionCore.consumePowerUp(head, BuffDurationTicks, true);
    if (!result.ate) {
        return;
    }

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
