#include "game_logic.h"

#include <QDateTime>

#include "adapter/ghost_store.h"
#include "adapter/choice_models.h"
#include "adapter/level_loader.h"
#include "adapter/profile_bridge.h"
#include "adapter/session_state.h"
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

void GameLogic::loadLastSession()
{
    const auto snapshot = snakegb::adapter::loadSessionSnapshot(m_profileManager.get());
    if (!snapshot.has_value()) {
        return;
    }

    m_score = snapshot->score;
    m_food = snapshot->food;
    m_direction = snapshot->direction;
    m_obstacles = snapshot->obstacles;
    m_snakeModel.reset(snapshot->body);
    m_inputQueue.clear();
    resetTransientRuntimeState();
    resetReplayRuntimeTracking();
    m_direction = snapshot->direction;

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

void GameLogic::updateHighScore()
{
    if (m_score > snakegb::adapter::highScore(m_profileManager.get())) {
        snakegb::adapter::updateHighScore(m_profileManager.get(), m_score);
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
        snakegb::adapter::saveSession(m_profileManager.get(), m_score, m_snakeModel.body(),
                                      m_obstacles, m_food, m_direction);
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

auto GameLogic::buildSafeInitialSnakeBody() const -> std::deque<QPoint>
{
    return snakegb::core::buildSafeInitialSnakeBody(m_obstacles, BOARD_WIDTH, BOARD_HEIGHT);
}
