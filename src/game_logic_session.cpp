#include "game_logic.h"

#include <QDateTime>

#include "adapter/choice_models.h"
#include "adapter/level_loader.h"
#include "adapter/profile_bridge.h"
#include "core/choice_runtime.h"
#include "core/game_rules.h"
#include "fsm/game_state.h"
#include "fsm/state_factory.h"

using namespace Qt::StringLiterals;

namespace
{
constexpr int InitialInterval = 200;
constexpr int BuffDurationTicks = 40;
} // namespace

auto GameLogic::hasSave() const -> bool
{
    return snakegb::adapter::hasSession(m_profileManager.get());
}

auto GameLogic::hasReplay() const noexcept -> bool
{
    return !m_bestInputHistory.isEmpty();
}

void GameLogic::resetTransientRuntimeState()
{
    m_direction = {0, -1};
    m_inputQueue.clear();
    m_activeBuff = None;
    m_buffTicksRemaining = 0;
    m_buffTicksTotal = 0;
    m_shieldActive = false;
    m_powerUpPos = QPoint(-1, -1);
    m_choicePending = false;
    m_choiceIndex = 0;
}

void GameLogic::resetReplayRuntimeTracking()
{
    m_gameTickCounter = 0;
    m_ghostFrameIndex = 0;
    m_lastRoguelikeChoiceScore = -1000;
    m_currentInputHistory.clear();
    m_currentRecording.clear();
    m_currentChoiceHistory.clear();
}

void GameLogic::restart()
{
    resetTransientRuntimeState();
    resetReplayRuntimeTracking();
    m_score = 0;

    m_randomSeed = static_cast<uint>(QDateTime::currentMSecsSinceEpoch());
    m_rng.seed(m_randomSeed);

    loadLevelData(m_levelIndex);
    m_snakeModel.reset(buildSafeInitialSnakeBody());
    clearSavedState();

    m_timer->setInterval(InitialInterval);
    m_timer->start();
    spawnFood();

    emit buffChanged();
    emit powerUpChanged();
    emit scoreChanged();
    emit foodChanged();
    requestStateChange(Playing);
}

void GameLogic::startReplay()
{
    if (m_bestInputHistory.isEmpty()) {
        return;
    }

    setInternalState(Replaying);
    resetTransientRuntimeState();
    resetReplayRuntimeTracking();
    m_score = 0;

    loadLevelData(m_bestLevelIndex);
    m_snakeModel.reset(buildSafeInitialSnakeBody());
    m_rng.seed(m_bestRandomSeed);
    m_timer->setInterval(InitialInterval);
    m_timer->start();
    spawnFood();

    emit scoreChanged();
    emit foodChanged();
    emit ghostChanged();
    if (auto nextState = snakegb::fsm::createStateFor(*this, Replaying); nextState) {
        changeState(std::move(nextState));
    }
}

void GameLogic::togglePause()
{
    if (m_state == Playing) {
        requestStateChange(Paused);
    } else if (m_state == Paused) {
        requestStateChange(Playing);
    }
}

void GameLogic::nextLevel()
{
    const int levelCount{
        snakegb::adapter::readLevelCountFromResource(u"qrc:/src/levels/levels.json"_s, 6)};
    m_levelIndex = (m_levelIndex + 1) % levelCount;
    loadLevelData(m_levelIndex);
    if (m_state == StartMenu && hasSave()) {
        clearSavedState();
    }
    emit levelChanged();
    snakegb::adapter::setLevelIndex(m_profileManager.get(), m_levelIndex);
}

void GameLogic::lazyInitState()
{
    if (!m_fsmState) {
        if (auto nextState = snakegb::fsm::createStateFor(*this, Splash); nextState) {
            changeState(std::move(nextState));
        }
    }
}

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

auto GameLogic::buildSafeInitialSnakeBody() const -> std::deque<QPoint>
{
    return snakegb::core::buildSafeInitialSnakeBody(m_obstacles, BOARD_WIDTH, BOARD_HEIGHT);
}
