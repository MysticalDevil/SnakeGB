#include "game_logic.h"

#include <QDateTime>
#include <QJSValue>

#include "adapter/ghost_store.h"
#include "adapter/level_applier.h"
#include "adapter/level_loader.h"
#include "adapter/level_script_runtime.h"
#include "adapter/session_state.h"
#include "core/achievement_rules.h"
#include "core/choice_runtime.h"
#include "core/game_rules.h"
#include "core/level_runtime.h"
#include "fsm/game_state.h"
#include "fsm/state_factory.h"
#include "profile_manager.h"

using namespace Qt::StringLiterals;

namespace
{
constexpr int InitialInterval = 200;
constexpr int BuffDurationTicks = 40;
} // namespace

auto GameLogic::hasSave() const -> bool
{
    if (m_profileManager) {
        return m_profileManager->hasSession();
    }
    return false;
}

auto GameLogic::hasReplay() const noexcept -> bool
{
    return !m_bestInputHistory.isEmpty();
}

void GameLogic::restart()
{
    m_direction = {0, -1};
    m_inputQueue.clear();
    m_score = 0;
    m_activeBuff = None;
    m_buffTicksRemaining = 0;
    m_buffTicksTotal = 0;
    m_shieldActive = false;
    m_powerUpPos = QPoint(-1, -1);
    m_choicePending = false;
    m_choiceIndex = 0;

    m_randomSeed = static_cast<uint>(QDateTime::currentMSecsSinceEpoch());
    m_rng.seed(m_randomSeed);
    m_gameTickCounter = 0;
    m_ghostFrameIndex = 0;
    m_lastRoguelikeChoiceScore = -1000;
    m_currentInputHistory.clear();
    m_currentRecording.clear();
    m_currentChoiceHistory.clear();

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
    m_currentRecording.clear();
    m_direction = {0, -1};
    m_inputQueue.clear();
    m_score = 0;
    m_activeBuff = None;
    m_buffTicksRemaining = 0;
    m_buffTicksTotal = 0;
    m_shieldActive = false;
    m_powerUpPos = QPoint(-1, -1);

    loadLevelData(m_bestLevelIndex);
    m_snakeModel.reset(buildSafeInitialSnakeBody());
    m_rng.seed(m_bestRandomSeed);
    m_gameTickCounter = 0;
    m_ghostFrameIndex = 0;
    m_lastRoguelikeChoiceScore = -1000;
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
    if (!m_profileManager || !m_profileManager->hasSession()) {
        return;
    }

    const auto snapshot = snakegb::adapter::decodeSessionSnapshot(m_profileManager->loadSession());
    if (!snapshot.has_value()) {
        return;
    }

    m_score = snapshot->score;
    m_food = snapshot->food;
    m_direction = snapshot->direction;
    m_obstacles = snapshot->obstacles;
    m_snakeModel.reset(snapshot->body);
    m_inputQueue.clear();
    m_currentInputHistory.clear();
    m_currentRecording.clear();
    m_currentChoiceHistory.clear();
    m_lastRoguelikeChoiceScore = -1000;
    m_activeBuff = None;
    m_buffTicksRemaining = 0;
    m_buffTicksTotal = 0;
    m_shieldActive = false;

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
    const int levelCount =
        snakegb::adapter::readLevelCountFromResource(u"qrc:/src/levels/levels.json"_s, 6);
    m_levelIndex = (m_levelIndex + 1) % levelCount;
    loadLevelData(m_levelIndex);
    if (m_state == StartMenu && hasSave()) {
        clearSavedState();
    }
    emit levelChanged();
    if (m_profileManager) {
        m_profileManager->setLevelIndex(m_levelIndex);
    }
}

void GameLogic::updatePersistence()
{
    updateHighScore();
    if (m_profileManager) {
        m_profileManager->incrementCrashes();
    }
    clearSavedState();
}

void GameLogic::lazyInit()
{
    if (m_profileManager) {
        m_levelIndex = m_profileManager->levelIndex();
        emit audioSetVolume(m_profileManager->volume());
    }

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
    m_choices.clear();

    const QList<snakegb::core::ChoiceSpec> allChoices =
        snakegb::core::pickRoguelikeChoices(m_rng.generate(), 3);
    for (const auto &choice : allChoices) {
        QVariantMap m;
        m.insert(u"type"_s, choice.type);
        m.insert(u"name"_s, choice.name);
        m.insert(u"desc"_s, choice.description);
        m_choices.append(m);
    }
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

    const int type = m_choices[index].toMap().value(u"type"_s).toInt();
    m_lastRoguelikeChoiceScore = m_score;
    m_activeBuff = static_cast<PowerUp>(type);
    applyAcquiredBuffEffects(type, BuffDurationTicks * 2, false, true);

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
    if (m_profileManager && m_score > m_profileManager->highScore()) {
        m_profileManager->updateHighScore(m_score);
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
        m_profileManager->saveSession(m_score, m_snakeModel.body(), m_obstacles, m_food,
                                      m_direction);
        emit hasSaveChanged();
    }
}

void GameLogic::clearSavedState()
{
    if (m_profileManager) {
        m_profileManager->clearSession();
        emit hasSaveChanged();
    }
}

void GameLogic::applyFallbackLevelData(const int levelIndex)
{
    const snakegb::core::FallbackLevelData fallback = snakegb::core::fallbackLevelData(levelIndex);
    m_obstacles.clear();
    m_currentLevelName = fallback.name;
    m_currentScript = fallback.script;
    if (!m_currentScript.isEmpty()) {
        const QJSValue res = m_jsEngine.evaluate(m_currentScript);
        if (!res.isError()) {
            runLevelScript();
        }
    } else {
        m_obstacles = fallback.walls;
    }
    emit obstaclesChanged();
}

void GameLogic::loadLevelData(const int i)
{
    const int safeIndex = snakegb::core::normalizedFallbackLevelIndex(i);
    m_currentLevelName = snakegb::core::fallbackLevelData(safeIndex).name;

    const auto resolvedLevel =
        snakegb::adapter::loadResolvedLevelFromResource(u"qrc:/src/levels/levels.json"_s, i);
    if (!resolvedLevel.has_value()) {
        applyFallbackLevelData(safeIndex);
        return;
    }

    const bool applied = snakegb::adapter::applyResolvedLevelData(
        *resolvedLevel, m_currentLevelName, m_currentScript, m_obstacles,
        [this](const QString &script) -> bool {
            const QJSValue res = m_jsEngine.evaluate(script);
            if (res.isError()) {
                return false;
            }
            runLevelScript();
            return true;
        });
    if (!applied) {
        applyFallbackLevelData(safeIndex);
        return;
    }
    emit obstaclesChanged();
}

auto GameLogic::buildSafeInitialSnakeBody() const -> std::deque<QPoint>
{
    return snakegb::core::buildSafeInitialSnakeBody(m_obstacles, BOARD_WIDTH, BOARD_HEIGHT);
}

void GameLogic::checkAchievements()
{
    if (!m_profileManager) {
        return;
    }

    const QStringList unlockedTitles =
        snakegb::core::unlockedAchievementTitles(m_score, m_timer->interval(), m_timer->isActive());

    auto unlockTitle = [this](const QString &title) -> void {
        if (m_profileManager->unlockMedal(title)) {
            emit achievementEarned(title);
            emit achievementsChanged();
        }
    };

    for (const QString &title : unlockedTitles) {
        unlockTitle(title);
    }
}

void GameLogic::runLevelScript()
{
    if (snakegb::adapter::tryApplyOnTickScript(m_jsEngine, m_gameTickCounter, m_obstacles)) {
        emit obstaclesChanged();
        return;
    }
    if (snakegb::adapter::applyDynamicLevelFallback(m_currentLevelName, m_gameTickCounter,
                                                    m_obstacles)) {
        emit obstaclesChanged();
    }
}
