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

auto choiceSpecForType(const int type) -> std::optional<snakegb::core::ChoiceSpec>
{
    using snakegb::core::ChoiceSpec;
    switch (type) {
    case GameLogic::Ghost:
        return ChoiceSpec{.type = GameLogic::Ghost, .name = u"Ghost"_s, .description = u"Pass through self"_s};
    case GameLogic::Slow:
        return ChoiceSpec{.type = GameLogic::Slow, .name = u"Slow"_s, .description = u"Decrease speed"_s};
    case GameLogic::Magnet:
        return ChoiceSpec{.type = GameLogic::Magnet, .name = u"Magnet"_s, .description = u"Attract food"_s};
    case GameLogic::Shield:
        return ChoiceSpec{.type = GameLogic::Shield, .name = u"Shield"_s, .description = u"One extra life"_s};
    case GameLogic::Portal:
        return ChoiceSpec{.type = GameLogic::Portal, .name = u"Portal"_s, .description = u"Phase through walls"_s};
    case GameLogic::Double:
        return ChoiceSpec{.type = GameLogic::Double, .name = u"Double"_s, .description = u"Double points"_s};
    case GameLogic::Rich:
        return ChoiceSpec{.type = GameLogic::Rich, .name = u"Diamond"_s, .description = u"Triple points"_s};
    case GameLogic::Laser:
        return ChoiceSpec{.type = GameLogic::Laser, .name = u"Laser"_s, .description = u"Break obstacle"_s};
    case GameLogic::Mini:
        return ChoiceSpec{.type = GameLogic::Mini, .name = u"Mini"_s, .description = u"Shrink body"_s};
    default:
        return std::nullopt;
    }
}

auto buildDebugChoiceSpecs(const QVariantList &types) -> QList<snakegb::core::ChoiceSpec>
{
    QList<snakegb::core::ChoiceSpec> result;
    QList<int> seenTypes;

    for (const QVariant &entry : types) {
        bool ok = false;
        const int type = entry.toInt(&ok);
        if (!ok || seenTypes.contains(type)) {
            continue;
        }
        const auto spec = choiceSpecForType(type);
        if (!spec.has_value()) {
            continue;
        }
        result.append(spec.value());
        seenTypes.append(type);
        if (result.size() >= 3) {
            return result;
        }
    }

    for (int type = GameLogic::Ghost; type <= GameLogic::Mini && result.size() < 3; ++type) {
        if (seenTypes.contains(type)) {
            continue;
        }
        const auto spec = choiceSpecForType(type);
        if (!spec.has_value()) {
            continue;
        }
        result.append(spec.value());
    }

    return result;
}
} // namespace

void GameLogic::generateChoices()
{
    const QList<snakegb::core::ChoiceSpec> allChoices =
        snakegb::core::pickRoguelikeChoices(m_rng.generate(), 3);
    m_choices = snakegb::adapter::buildChoiceModel(allChoices);
    emit choicesChanged();
}

void GameLogic::debugSeedChoicePreview(const QVariantList &types)
{
    stopEngineTimer();
    resetTransientRuntimeState();
    m_session.score = 42;
    m_session.tickCounter = 64;
    loadLevelData(m_levelIndex);
    m_sessionCore.setBody({{10, 4}, {10, 5}, {10, 6}, {10, 7}});
    syncSnakeModelFromCore();
    m_session.food = QPoint(12, 7);
    m_session.powerUpPos = QPoint(-1, -1);
    m_session.powerUpType = 0;
    m_choices = snakegb::adapter::buildChoiceModel(buildDebugChoiceSpecs(types));
    m_choiceIndex = 0;

    emit scoreChanged();
    emit foodChanged();
    emit powerUpChanged();
    emit buffChanged();
    emit ghostChanged();
    emit choicesChanged();
    emit choiceIndexChanged();

    setInternalState(ChoiceSelection);
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
        m_sessionCore.setBody(snakegb::core::applyMiniShrink(m_sessionCore.body(), 3));
        syncSnakeModelFromCore();
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
