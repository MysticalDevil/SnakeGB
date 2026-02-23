#include "game_logic.h"

#include "adapter/choice_models.h"
#include "core/choice_runtime.h"
#include "fsm/game_state.h"

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
        m_currentChoiceHistory.append({.frame = m_gameTickCounter, .index = index});
    }

    const auto type = snakegb::adapter::choiceTypeAt(m_choices, index);
    if (!type.has_value()) {
        return;
    }
    m_lastRoguelikeChoiceScore = m_score;
    m_activeBuff = static_cast<PowerUp>(type.value());
    applyAcquiredBuffEffects(type.value(), BuffDurationTicks * 2, false, true);

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
