#include "adapter/game_logic.h"

#include <QDateTime>

#include "fsm/game_state.h"
#include "fsm/state_factory.h"

namespace
{
constexpr int InitialInterval = 200;
} // namespace

void GameLogic::restart()
{
    resetTransientRuntimeState();
    m_sessionCore.applyMetaAction(snakegb::core::MetaAction::resetReplayRuntime());
    resetReplayRuntimeTracking();

    m_randomSeed = static_cast<uint>(QDateTime::currentMSecsSinceEpoch());
    m_rng.seed(m_randomSeed);

    loadLevelData(m_levelIndex);
    m_sessionCore.applyMetaAction(snakegb::core::MetaAction::bootstrapForLevel(
        m_session.obstacles, BOARD_WIDTH, BOARD_HEIGHT));
    syncSnakeModelFromCore();
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

    resetTransientRuntimeState();
    m_sessionCore.applyMetaAction(snakegb::core::MetaAction::resetReplayRuntime());
    resetReplayRuntimeTracking();

    loadLevelData(m_bestLevelIndex);
    m_sessionCore.applyMetaAction(snakegb::core::MetaAction::bootstrapForLevel(
        m_session.obstacles, BOARD_WIDTH, BOARD_HEIGHT));
    syncSnakeModelFromCore();
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

void GameLogic::enterReplayState()
{
    setInternalState(Replaying);
    m_replayInputHistoryIndex = 0;
    m_replayChoiceHistoryIndex = 0;
}

void GameLogic::debugSeedReplayBuffPreview()
{
    stopEngineTimer();
    resetTransientRuntimeState();
    loadLevelData(m_levelIndex);
    m_sessionCore.applyMetaAction(snakegb::core::MetaAction::seedPreviewState({
        .obstacles = m_session.obstacles,
        .body = {{10, 4}, {10, 5}, {10, 6}, {10, 7}},
        .food = QPoint(12, 7),
        .direction = QPoint(0, -1),
        .powerUpPos = QPoint(-1, -1),
        .powerUpType = 0,
        .score = 42,
        .tickCounter = 64,
        .activeBuff = Shield,
        .buffTicksRemaining = 92,
        .buffTicksTotal = 120,
        .shieldActive = true,
    }));
    syncSnakeModelFromCore();

    emit scoreChanged();
    emit foodChanged();
    emit powerUpChanged();
    emit buffChanged();
    emit ghostChanged();

    setInternalState(Replaying);
}

void GameLogic::togglePause()
{
    if (m_state == Playing) {
        requestStateChange(Paused);
    } else if (m_state == Paused) {
        requestStateChange(Playing);
    }
}

void GameLogic::lazyInitState()
{
    if (!m_fsmState) {
        if (auto nextState = snakegb::fsm::createStateFor(*this, Splash); nextState) {
            changeState(std::move(nextState));
        }
    }
}
