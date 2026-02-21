#pragma once

#include <QString>

namespace snakegb::adapter {

enum class UiActionKind {
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

struct UiAction {
    UiActionKind kind = UiActionKind::Unknown;
    int value = 0;
};

[[nodiscard]] auto parseUiAction(const QString &action) -> UiAction;

} // namespace snakegb::adapter
