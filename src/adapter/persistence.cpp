#include "adapter/engine_adapter.h"

#include "adapter/profile_bridge.h"
#include "fsm/game_state.h"

using namespace Qt::StringLiterals;

auto EngineAdapter::saveRepository() const -> snakegb::services::SaveRepository
{
    return snakegb::services::SaveRepository(m_profileManager.get());
}

void EngineAdapter::loadLastSession()
{
    const auto snapshot = saveRepository().loadSessionSnapshot();
    if (!snapshot.has_value()) {
        return;
    }

    resetReplayRuntimeTracking();
    m_sessionCore.applyMetaAction(snakegb::core::MetaAction::restorePersistedSession(
        snakegb::adapter::toCoreStateSnapshot(*snapshot)));
    syncSnakeModelFromCore();

    for (const auto &p : snapshot->body) {
        m_currentRecording.append(p);
    }

    m_timer->setInterval(m_sessionCore.currentTickIntervalMs());
    m_timer->start();

    emit scoreChanged();
    emit foodChanged();
    emit obstaclesChanged();
    emit ghostChanged();
    requestStateChange(Paused);
}

void EngineAdapter::updatePersistence()
{
    updateHighScore();
    snakegb::adapter::incrementCrashes(m_profileManager.get());
    clearSavedState();
}

void EngineAdapter::enterGameOverState()
{
    setInternalState(GameOver);
    updatePersistence();
}

void EngineAdapter::lazyInit()
{
    m_levelIndex = snakegb::adapter::levelIndex(m_profileManager.get());
    m_audioBus.applyVolume(snakegb::adapter::volume(m_profileManager.get()));

    snakegb::adapter::GhostSnapshot snapshot;
    if (saveRepository().loadGhostSnapshot(snapshot)) {
        m_bestRecording = snapshot.recording;
        m_bestRandomSeed = snapshot.randomSeed;
        m_bestInputHistory = snapshot.inputHistory;
        m_bestLevelIndex = snapshot.levelIndex;
        m_bestChoiceHistory = snapshot.choiceHistory;
    }

    loadLevelData(m_levelIndex);
    spawnFood();
    emit paletteChanged();
    emit shellColorChanged();
}

void EngineAdapter::updateHighScore()
{
    if (m_session.score > snakegb::adapter::highScore(m_profileManager.get())) {
        snakegb::adapter::updateHighScore(m_profileManager.get(), m_session.score);
        m_bestInputHistory = m_currentInputHistory;
        m_bestRecording = m_currentRecording;
        m_bestChoiceHistory = m_currentChoiceHistory;
        m_bestRandomSeed = m_randomSeed;
        m_bestLevelIndex = m_levelIndex;

        const snakegb::adapter::GhostSnapshot ghostSnapshot{
            .recording = m_bestRecording,
            .randomSeed = m_bestRandomSeed,
            .inputHistory = m_bestInputHistory,
            .levelIndex = m_bestLevelIndex,
            .choiceHistory = m_bestChoiceHistory,
        };
        const bool savedGhost = saveRepository().saveGhostSnapshot(ghostSnapshot);
        if (!savedGhost) {
            qWarning().noquote() << "[ReplayFlow][EngineAdapter] failed to persist ghost snapshot";
        }
        emit highScoreChanged();
    }
}

void EngineAdapter::saveCurrentState()
{
    if (m_profileManager) {
        saveRepository().saveSession(m_sessionCore.snapshot({}));
        emit hasSaveChanged();
    }
}

void EngineAdapter::clearSavedState()
{
    if (m_profileManager) {
        saveRepository().clearSession();
        emit hasSaveChanged();
    }
}
