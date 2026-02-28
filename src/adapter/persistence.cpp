#include "adapter/game_logic.h"

#include "adapter/ghost_store.h"
#include "adapter/profile_bridge.h"
#include "adapter/session_state.h"
#include "fsm/game_state.h"

using namespace Qt::StringLiterals;

void GameLogic::loadLastSession()
{
    const auto snapshot = snakegb::adapter::loadSessionSnapshot(m_profileManager.get());
    if (!snapshot.has_value()) {
        return;
    }

    m_sessionCore.restoreSnapshot({
        .state = {
            .food = snapshot->food,
            .direction = snapshot->direction,
            .score = snapshot->score,
            .obstacles = snapshot->obstacles,
        },
        .body = snapshot->body,
    });
    syncSnakeModelFromCore();
    resetTransientRuntimeState();
    resetReplayRuntimeTracking();
    m_session.direction = snapshot->direction;

    for (const auto &p : snapshot->body) {
        m_currentRecording.append(p);
    }

    m_timer->setInterval(normalTickIntervalMs());
    m_timer->start();

    emit scoreChanged();
    emit foodChanged();
    emit obstaclesChanged();
    emit ghostChanged();
    requestStateChange(Paused);
}

void GameLogic::updatePersistence()
{
    updateHighScore();
    snakegb::adapter::incrementCrashes(m_profileManager.get());
    clearSavedState();
}

void GameLogic::lazyInit()
{
    m_levelIndex = snakegb::adapter::levelIndex(m_profileManager.get());
    emit audioSetVolume(snakegb::adapter::volume(m_profileManager.get()));

    snakegb::adapter::GhostSnapshot snapshot;
    if (snakegb::adapter::loadGhostSnapshot(snapshot)) {
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

void GameLogic::updateHighScore()
{
    if (m_session.score > snakegb::adapter::highScore(m_profileManager.get())) {
        snakegb::adapter::updateHighScore(m_profileManager.get(), m_session.score);
        m_bestInputHistory = m_currentInputHistory;
        m_bestRecording = m_currentRecording;
        m_bestChoiceHistory = m_currentChoiceHistory;
        m_bestRandomSeed = m_randomSeed;
        m_bestLevelIndex = m_levelIndex;

        const bool savedGhost = snakegb::adapter::saveGhostSnapshot({
            .recording = m_bestRecording,
            .randomSeed = m_bestRandomSeed,
            .inputHistory = m_bestInputHistory,
            .levelIndex = m_bestLevelIndex,
            .choiceHistory = m_bestChoiceHistory,
        });
        if (!savedGhost) {
            qWarning().noquote() << "[ReplayFlow][GameLogic] failed to persist ghost snapshot";
        }
        emit highScoreChanged();
    }
}

void GameLogic::saveCurrentState()
{
    if (m_profileManager) {
        snakegb::adapter::saveSession(m_profileManager.get(), m_session.score, m_sessionCore.body(),
                                      m_session.obstacles, m_session.food, m_session.direction);
        emit hasSaveChanged();
    }
}

void GameLogic::clearSavedState()
{
    if (m_profileManager) {
        snakegb::adapter::clearSession(m_profileManager.get());
        emit hasSaveChanged();
    }
}
