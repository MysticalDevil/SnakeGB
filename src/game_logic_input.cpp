#include "game_logic.h"

#include <QCoreApplication>

#include "adapter/input_semantics.h"
#include "adapter/ui_action.h"
#include "fsm/game_state.h"
#include "profile_manager.h"

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

    if (m_state == Playing && m_inputQueue.size() < 2) {
        const QPoint last = m_inputQueue.empty() ? m_direction : m_inputQueue.back();
        if (((dx != 0) && last.x() == -dx) || ((dy != 0) && last.y() == -dy)) {
            return;
        }
        m_inputQueue.emplace_back(dx, dy);
        emit uiInteractTriggered();
    }
}

void GameLogic::nextPalette()
{
    if (m_profileManager) {
        const int nextIdx = (m_profileManager->paletteIndex() + 1) % 5;
        m_profileManager->setPaletteIndex(nextIdx);
        emit paletteChanged();
        emit uiInteractTriggered();
    }
}

void GameLogic::nextShellColor()
{
    if (m_profileManager) {
        const int nextIdx = (m_profileManager->shellIndex() + 1) % 7;
        m_profileManager->setShellIndex(nextIdx);
        emit shellColorChanged();
        emit uiInteractTriggered();
    }
}

void GameLogic::handleBAction()
{
    // Unified semantics:
    // - Active gameplay states: secondary visual action (palette cycle)
    // - Navigation/overlay states: back to menu
    // - Menu root: palette cycle (quit uses Back/Esc)
    if (m_state == Playing || m_state == ChoiceSelection) {
        nextPalette();
        return;
    }

    if (m_state == StartMenu) {
        nextPalette();
        return;
    }

    if (m_state == Paused || m_state == GameOver || m_state == Replaying || m_state == Library ||
        m_state == MedalRoom) {
        quitToMenu();
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
    emit audioSetMusicEnabled(m_musicEnabled);
    if (m_musicEnabled && m_state != Splash) {
        emit audioStartMusic();
    } else if (!m_musicEnabled) {
        emit audioStopMusic();
    }
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
    if (m_profileManager) {
        m_profileManager->setLevelIndex(m_levelIndex);
    }
    loadLevelData(m_levelIndex);
    emit levelChanged();
}
