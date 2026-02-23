#include "runtime/game_logic.h"

#include "adapter/level_loader.h"
#include "adapter/profile_bridge.h"
#include "core/game_rules.h"
using namespace Qt::StringLiterals;

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

auto GameLogic::buildSafeInitialSnakeBody() const -> std::deque<QPoint>
{
    return snakegb::core::buildSafeInitialSnakeBody(m_obstacles, BOARD_WIDTH, BOARD_HEIGHT);
}
