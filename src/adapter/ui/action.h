#pragma once

#include <functional>
#include <QString>

namespace snakegb::adapter
{

enum class UiActionKind
{
    Unknown = 0,
    NavUp,
    NavDown,
    NavLeft,
    NavRight,
    Primary,
    Start,
    Secondary,
    SelectShort,
    Back,
    ToggleShellColor,
    ToggleMusic,
    QuitToMenu,
    Quit,
    NextPalette,
    DeleteSave,
    StateStartMenu,
    StateSplash,
    FeedbackLight,
    FeedbackUi,
    FeedbackHeavy,
    SetLibraryIndex,
    SetMedalIndex,
};

struct UiAction
{
    UiActionKind kind = UiActionKind::Unknown;
    int value = 0;
};

struct UiActionDispatchCallbacks
{
    std::function<void(int, int)> onMove;
    std::function<void()> onStart;
    std::function<void()> onSecondary;
    std::function<void()> onSelect;
    std::function<void()> onBack;
    std::function<void()> onToggleShellColor;
    std::function<void()> onToggleMusic;
    std::function<void()> onQuitToMenu;
    std::function<void()> onQuit;
    std::function<void()> onNextPalette;
    std::function<void()> onDeleteSave;
    std::function<void()> onStateStartMenu;
    std::function<void()> onStateSplash;
    std::function<void()> onFeedbackLight;
    std::function<void()> onFeedbackUi;
    std::function<void()> onFeedbackHeavy;
    std::function<void(int)> onSetLibraryIndex;
    std::function<void(int)> onSetMedalIndex;
};

[[nodiscard]] auto parseUiAction(const QString &action) -> UiAction;
auto dispatchUiAction(const UiAction &action, const UiActionDispatchCallbacks &callbacks) -> void;

} // namespace snakegb::adapter
