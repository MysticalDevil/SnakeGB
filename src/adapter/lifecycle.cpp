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
    resetReplayRuntimeTracking();
    m_session.score = 0;

    m_randomSeed = static_cast<uint>(QDateTime::currentMSecsSinceEpoch());
    m_rng.seed(m_randomSeed);

    loadLevelData(m_levelIndex);
    m_sessionCore.setBody(buildSafeInitialSnakeBody());
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

    setInternalState(Replaying);
    resetTransientRuntimeState();
    resetReplayRuntimeTracking();
    m_session.score = 0;

    loadLevelData(m_bestLevelIndex);
    m_sessionCore.setBody(buildSafeInitialSnakeBody());
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

void GameLogic::debugSeedReplayBuffPreview()
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
    m_session.activeBuff = Shield;
    m_session.buffTicksRemaining = 92;
    m_session.buffTicksTotal = 120;
    m_session.shieldActive = true;

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
