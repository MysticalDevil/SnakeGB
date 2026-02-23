#include "game_logic.h"

#include <QJSValue>

#include "adapter/achievement_runtime.h"
#include "adapter/level_applier.h"
#include "adapter/level_loader.h"
#include "adapter/level_script_runtime.h"
#include "adapter/profile_bridge.h"
#include "core/level_runtime.h"

using namespace Qt::StringLiterals;

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

void GameLogic::checkAchievements()
{
    const QStringList newlyUnlocked = snakegb::adapter::unlockAchievements(
        m_profileManager.get(), m_score, m_timer->interval(), m_timer->isActive());
    for (const QString &title : newlyUnlocked) {
        emit achievementEarned(title);
        emit achievementsChanged();
    }
}

void GameLogic::runLevelScript()
{
    if (snakegb::adapter::applyLevelScriptStep(m_jsEngine, m_currentLevelName, m_gameTickCounter,
                                               m_obstacles)) {
        emit obstaclesChanged();
    }
}
