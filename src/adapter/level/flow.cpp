#include <QJSValue>

#include "adapter/achievement/runtime.h"
#include "adapter/engine.h"
#include "adapter/level/applier.h"
#include "adapter/level/script_runtime.h"
#include "adapter/models/library.h"
#include "adapter/profile/bridge.h"
#include "core/level/runtime.h"
#include "power_up_id.h"

using namespace Qt::StringLiterals;

void EngineAdapter::applyFallbackLevelData(const int levelIndex) {
  const nenoserpent::core::FallbackLevelData fallback =
    nenoserpent::core::fallbackLevelData(levelIndex);
  m_session.obstacles.clear();
  m_currentLevelName = fallback.name;
  m_currentScript = fallback.script;
  if (!m_currentScript.isEmpty()) {
    const QJSValue res = m_jsEngine.evaluate(m_currentScript);
    if (!res.isError()) {
      runLevelScript();
    }
  } else {
    m_session.obstacles = fallback.walls;
  }
  emit obstaclesChanged();
}

void EngineAdapter::loadLevelData(const int i) {
  const int safeIndex = nenoserpent::core::normalizedFallbackLevelIndex(i);
  m_currentLevelName = nenoserpent::core::fallbackLevelData(safeIndex).name;

  const auto resolvedLevel = m_levelRepository.loadResolvedLevel(i);
  if (!resolvedLevel.has_value()) {
    applyFallbackLevelData(safeIndex);
    return;
  }

  const bool applied =
    nenoserpent::adapter::applyResolvedLevelData(*resolvedLevel,
                                                 m_currentLevelName,
                                                 m_currentScript,
                                                 m_session.obstacles,
                                                 [this](const QString& script) -> bool {
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

void EngineAdapter::checkAchievements() {
  const nenoserpent::core::AchievementStats stats{
    .score = m_session.score,
    .tickIntervalMs = m_timer->interval(),
    .timerActive = m_timer->isActive(),
    .totalCrashes = nenoserpent::adapter::totalCrashes(m_profileManager.get()),
    .totalFoodEaten = nenoserpent::adapter::totalFoodEaten(m_profileManager.get()),
    .noFoodElapsedMs = m_noFoodElapsedMs,
    .foodEatenThisRun = m_foodEatenThisRun,
    .usedAnyPowerThisRun = m_usedAnyPowerThisRun,
    .collectedPowerTypesThisRun = m_collectedPowerTypesThisRun,
    .triggeredPowerTypesThisRun = m_triggeredPowerTypesThisRun,
    .shieldConsumedThisRun = m_shieldConsumedThisRun,
    .ticksSinceShieldConsumedMs = m_sinceShieldConsumedMs,
    .highSpeedElapsedMs = m_highSpeedElapsedMs,
    .phaseWalkCount = m_phaseWalkCount,
  };

  const QStringList newlyUnlocked =
    nenoserpent::adapter::unlockAchievements(m_profileManager.get(), stats);
  for (const QString& id : newlyUnlocked) {
    emit achievementEarned(nenoserpent::adapter::achievementTitleForId(id));
    emit achievementsChanged();
  }
}

void EngineAdapter::runLevelScript() {
  if (m_session.activeBuff == PowerUpId::Freeze) {
    return;
  }
  if (nenoserpent::adapter::applyLevelScriptStep(
        m_jsEngine, m_currentLevelName, m_session.tickCounter, m_session.obstacles)) {
    emit obstaclesChanged();
  }
}
