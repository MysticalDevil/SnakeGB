#include "game_logic.h"

#include "adapter/profile_bridge.h"
#include "core/buff_runtime.h"
#include "core/game_rules.h"
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

    if (p != m_food) {
        return;
    }

    const int points =
        snakegb::core::foodPointsForBuff(static_cast<snakegb::core::BuffId>(m_activeBuff));

    const int previousScore = m_score;
    m_score += points;
    snakegb::adapter::logFoodEaten(m_profileManager.get());

    const float pan = (static_cast<float>(p.x()) / BOARD_WIDTH - 0.5F) * 1.4F;
    emit foodEaten(pan);

    m_timer->setInterval(normalTickIntervalMs());
    emit scoreChanged();
    spawnFood();

    if (shouldTriggerRoguelikeChoice(previousScore, m_score)) {
        m_lastRoguelikeChoiceScore = m_score;
        if (m_state == Replaying) {
            generateChoices();
        } else {
            requestStateChange(ChoiceSelection);
        }
    } else if (m_rng.bounded(100) < 15 && m_powerUpPos == QPoint(-1, -1)) {
        spawnPowerUp();
    }

    triggerHaptic(std::min(5, 2 + (m_score / 10)));
}

void GameLogic::handlePowerUpConsumption(const QPoint &head)
{
    const QPoint p = snakegb::core::wrapPoint(head, BOARD_WIDTH, BOARD_HEIGHT);

    if (p != m_powerUpPos) {
        return;
    }

    m_activeBuff = m_powerUpType;
    applyAcquiredBuffEffects(static_cast<int>(m_activeBuff), BuffDurationTicks, true, true);

    m_powerUpPos = QPoint(-1, -1);

    emit powerUpEaten();
    if (m_activeBuff == Slow) {
        m_timer->setInterval(250);
    }

    triggerHaptic(5);
    emit buffChanged();
    emit powerUpChanged();
}

void GameLogic::applyMiniShrink()
{
    const auto body = m_snakeModel.body();
    if (body.size() <= 3) {
        return;
    }
    std::deque<QPoint> nextBody;
    const size_t targetLength = snakegb::core::miniShrinkTargetLength(body.size(), 3);
    for (size_t i = 0; i < targetLength; ++i) {
        nextBody.push_back(body[i]);
    }
    m_snakeModel.reset(nextBody);
}

auto GameLogic::normalTickIntervalMs() const -> int
{
    if (m_activeBuff == Slow) {
        return 250;
    }
    return snakegb::core::tickIntervalForScore(m_score);
}

// NOLINTNEXTLINE(bugprone-easily-swappable-parameters)
void GameLogic::applyAcquiredBuffEffects(const int discoveredType, const int baseDurationTicks,
                                         const bool halfDurationForRich, const bool emitMiniPrompt)
{
    snakegb::adapter::discoverFruit(m_profileManager.get(), discoveredType);

    if (m_activeBuff == Shield) {
        m_shieldActive = true;
    }

    if (m_activeBuff == Mini) {
        applyMiniShrink();
        if (emitMiniPrompt) {
            emit eventPrompt(u"MINI BLITZ! SIZE CUT"_s);
        }
        m_activeBuff = None;
    }

    m_buffTicksRemaining =
        halfDurationForRich
            ? snakegb::core::buffDurationTicks(static_cast<snakegb::core::BuffId>(m_activeBuff),
                                               baseDurationTicks)
            : baseDurationTicks;
    m_buffTicksTotal = m_buffTicksRemaining;
}

auto GameLogic::shouldTriggerRoguelikeChoice(const int previousScore, const int newScore) -> bool
{
    const int chancePercent = snakegb::core::roguelikeChoiceChancePercent({
        .previousScore = previousScore,
        .newScore = newScore,
        .lastChoiceScore = m_lastRoguelikeChoiceScore,
    });
    if (chancePercent >= 100) {
        return true;
    }
    if (chancePercent <= 0) {
        return false;
    }
    return m_rng.bounded(100) < chancePercent;
}
