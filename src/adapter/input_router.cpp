#include "adapter/game_logic.h"

#include <QCoreApplication>

#include "adapter/input_semantics.h"
#include "adapter/profile_bridge.h"
#include "adapter/ui_action.h"
#include "fsm/game_state.h"

using namespace Qt::StringLiterals;

void GameLogic::dispatchUiAction(const QString &action)
{
    const snakegb::adapter::UiAction uiAction = snakegb::adapter::parseUiAction(action);
    snakegb::adapter::dispatchUiAction(
        uiAction,
        {
            .onMove = [this](const int dx, const int dy) -> void { move(dx, dy); },
            .onStart = [this]() -> void { handleStart(); },
            .onSecondary = [this]() -> void { handleBAction(); },
            .onSelect = [this]() -> void { handleSelect(); },
            .onBack = [this]() -> void {
                switch (snakegb::adapter::resolveBackActionForState(static_cast<int>(m_state))) {
                case snakegb::adapter::BackAction::QuitToMenu:
                    quitToMenu();
                    break;
                case snakegb::adapter::BackAction::QuitApplication:
                    quit();
                    break;
                case snakegb::adapter::BackAction::None:
                    break;
                }
            },
            .onToggleShellColor = [this]() -> void { nextShellColor(); },
            .onToggleMusic = [this]() -> void { toggleMusic(); },
            .onQuitToMenu = [this]() -> void { quitToMenu(); },
            .onQuit = [this]() -> void { quit(); },
            .onNextPalette = [this]() -> void { nextPalette(); },
            .onDeleteSave = [this]() -> void { deleteSave(); },
            .onStateStartMenu = [this]() -> void { requestStateChange(StartMenu); },
            .onStateSplash = [this]() -> void { requestStateChange(Splash); },
            .onFeedbackLight = [this]() -> void { triggerHaptic(1); },
            .onFeedbackUi = [this]() -> void { triggerHaptic(5); },
            .onFeedbackHeavy = [this]() -> void { triggerHaptic(8); },
            .onSetLibraryIndex = [this](const int index) -> void { setLibraryIndex(index); },
            .onSetMedalIndex = [this](const int index) -> void { setMedalIndex(index); },
        });
}

void GameLogic::move(const int dx, const int dy)
{
    dispatchStateCallback([dx, dy](GameState &state) -> void { state.handleInput(dx, dy); });

    if (m_state == Playing && m_sessionCore.enqueueDirection(QPoint(dx, dy))) {
        emit uiInteractTriggered();
    }
}

void GameLogic::nextPalette()
{
    if (!m_profileManager) {
        return;
    }
    const int nextIdx = (snakegb::adapter::paletteIndex(m_profileManager.get()) + 1) % 5;
    snakegb::adapter::setPaletteIndex(m_profileManager.get(), nextIdx);
    emit paletteChanged();
    emit uiInteractTriggered();
}

void GameLogic::nextShellColor()
{
    if (!m_profileManager) {
        return;
    }
    const int nextIdx = (snakegb::adapter::shellIndex(m_profileManager.get()) + 1) % 7;
    snakegb::adapter::setShellIndex(m_profileManager.get(), nextIdx);
    emit shellColorChanged();
    emit uiInteractTriggered();
}

void GameLogic::handleBAction()
{
    // Unified semantics:
    // - B is always the secondary visual action (palette cycle).
    // - Back/menu navigation uses Select/Back action paths.
    if (m_state == StartMenu || m_state == Playing || m_state == Paused || m_state == GameOver ||
        m_state == Replaying || m_state == ChoiceSelection || m_state == Library ||
        m_state == MedalRoom) {
        nextPalette();
    }
}

void GameLogic::quitToMenu()
{
    if (m_state == Playing || m_state == Paused || m_state == ChoiceSelection) {
        saveCurrentState();
    }
    requestStateChange(StartMenu);
}

void GameLogic::toggleMusic()
{
    m_musicEnabled = !m_musicEnabled;
    qInfo().noquote() << "[AudioFlow][GameLogic] toggleMusic ->" << m_musicEnabled;
    m_audioBus.handleMusicToggle(m_musicEnabled, static_cast<int>(m_state));
    emit musicEnabledChanged();
}

void GameLogic::quit()
{
    if (m_state == Playing || m_state == Paused || m_state == ChoiceSelection) {
        saveCurrentState();
    }
    QCoreApplication::quit();
}

void GameLogic::handleSelect()
{
    if (m_state == StartMenu) {
        nextLevel();
        return;
    }
    dispatchStateCallback([](GameState &state) -> void { state.handleSelect(); });
}

void GameLogic::handleStart()
{
    dispatchStateCallback([](GameState &state) -> void { state.handleStart(); });
}

void GameLogic::deleteSave()
{
    clearSavedState();
    // Clearing save should also reset level selection to default.
    m_levelIndex = 0;
    snakegb::adapter::setLevelIndex(m_profileManager.get(), m_levelIndex);
    loadLevelData(m_levelIndex);
    emit levelChanged();
}
