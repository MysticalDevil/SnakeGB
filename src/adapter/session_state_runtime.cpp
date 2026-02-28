#include "adapter/game_logic.h"

#include <QList>

#include "adapter/profile_bridge.h"
#include "core/game_rules.h"

using namespace Qt::StringLiterals;

auto GameLogic::hasSave() const -> bool
{
    return saveRepository().hasSession();
}

auto GameLogic::hasReplay() const noexcept -> bool
{
    return !m_bestInputHistory.isEmpty();
}

void GameLogic::resetTransientRuntimeState()
{
    m_sessionCore.resetTransientRuntimeState();
    m_choicePending = false;
    m_choiceIndex = 0;
}

void GameLogic::resetReplayRuntimeTracking()
{
    m_ghostFrameIndex = 0;
    m_replayInputHistoryIndex = 0;
    m_replayChoiceHistoryIndex = 0;
    m_currentInputHistory.clear();
    m_currentRecording.clear();
    m_currentChoiceHistory.clear();
}

void GameLogic::nextLevel()
{
    const int levelCount = m_levelRepository.levelCount();
    m_levelIndex = (m_levelIndex + 1) % levelCount;
    loadLevelData(m_levelIndex);
    if (m_state == StartMenu && hasSave()) {
        clearSavedState();
    }
    emit levelChanged();
    snakegb::adapter::setLevelIndex(m_profileManager.get(), m_levelIndex);
}
