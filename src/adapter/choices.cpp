#include "adapter/game_logic.h"

#include "adapter/choice_models.h"
#include "adapter/profile_bridge.h"
#include "core/choice_runtime.h"
#include "core/session_runtime.h"
#include "fsm/game_state.h"

using namespace Qt::StringLiterals;

namespace
{
constexpr int BuffDurationTicks = 40;
} // namespace

void GameLogic::generateChoices()
{
    const QList<snakegb::core::ChoiceSpec> allChoices =
        snakegb::core::pickRoguelikeChoices(m_rng.generate(), 3);
    m_choices = snakegb::adapter::buildChoiceModel(allChoices);
    emit choicesChanged();
}

void GameLogic::selectChoice(const int index)
{
    if (index < 0 || index >= m_choices.size()) {
        return;
    }

    if (m_state != Replaying) {
        m_currentChoiceHistory.append({.frame = m_session.tickCounter, .index = index});
    }

    const auto type = snakegb::adapter::choiceTypeAt(m_choices, index);
    if (!type.has_value()) {
        return;
    }
    m_session.lastRoguelikeChoiceScore = m_session.score;
    const auto result =
        snakegb::core::planPowerUpAcquisition(type.value(), BuffDurationTicks * 2, false);
    snakegb::adapter::discoverFruit(m_profileManager.get(), type.value());
    if (result.shieldActivated) {
        m_session.shieldActive = true;
    }
    if (result.miniApplied) {
        const auto nextBody = snakegb::core::applyMiniShrink(m_snakeModel.body(), 3);
        m_snakeModel.reset(nextBody);
        emit eventPrompt(u"MINI BLITZ! SIZE CUT"_s);
    }
    m_session.activeBuff = static_cast<PowerUp>(result.activeBuffAfter);
    m_session.buffTicksRemaining = result.buffTicksRemaining;
    m_session.buffTicksTotal = result.buffTicksTotal;

    emit buffChanged();
    if (m_state == Replaying) {
        m_timer->setInterval(normalTickIntervalMs());
        return;
    }

    m_timer->setInterval(500);

    QTimer::singleShot(500, this, [this]() -> void {
        if (m_state == Playing) {
            m_timer->setInterval(normalTickIntervalMs());
        }
    });

    requestStateChange(Playing);
}
