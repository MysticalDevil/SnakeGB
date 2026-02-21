#include "ui_action.h"

#include <QtCore/qstringliteral.h>

using namespace Qt::StringLiterals;

namespace snakegb::adapter {

auto parseUiAction(const QString &action) -> UiAction {
    if (action == u"nav_up"_s) return {UiActionKind::NavUp, 0};
    if (action == u"nav_down"_s) return {UiActionKind::NavDown, 0};
    if (action == u"nav_left"_s) return {UiActionKind::NavLeft, 0};
    if (action == u"nav_right"_s) return {UiActionKind::NavRight, 0};
    if (action == u"primary"_s) return {UiActionKind::Primary, 0};
    if (action == u"start"_s) return {UiActionKind::Start, 0};
    if (action == u"secondary"_s) return {UiActionKind::Secondary, 0};
    if (action == u"select_short"_s) return {UiActionKind::SelectShort, 0};
    if (action == u"back"_s) return {UiActionKind::Back, 0};
    if (action == u"toggle_shell_color"_s) return {UiActionKind::ToggleShellColor, 0};
    if (action == u"toggle_music"_s) return {UiActionKind::ToggleMusic, 0};
    if (action == u"quit_to_menu"_s) return {UiActionKind::QuitToMenu, 0};
    if (action == u"quit"_s) return {UiActionKind::Quit, 0};
    if (action == u"next_palette"_s) return {UiActionKind::NextPalette, 0};
    if (action == u"delete_save"_s) return {UiActionKind::DeleteSave, 0};
    if (action == u"state_start_menu"_s) return {UiActionKind::StateStartMenu, 0};
    if (action == u"state_splash"_s) return {UiActionKind::StateSplash, 0};
    if (action == u"feedback_light"_s) return {UiActionKind::FeedbackLight, 0};
    if (action == u"feedback_ui"_s) return {UiActionKind::FeedbackUi, 0};
    if (action == u"feedback_heavy"_s) return {UiActionKind::FeedbackHeavy, 0};

    if (action.startsWith(u"set_library_index:"_s)) {
        bool ok = false;
        const int value = action.sliced(18).toInt(&ok);
        if (ok) return {UiActionKind::SetLibraryIndex, value};
        return {UiActionKind::Unknown, 0};
    }
    if (action.startsWith(u"set_medal_index:"_s)) {
        bool ok = false;
        const int value = action.sliced(16).toInt(&ok);
        if (ok) return {UiActionKind::SetMedalIndex, value};
        return {UiActionKind::Unknown, 0};
    }

    return {UiActionKind::Unknown, 0};
}

} // namespace snakegb::adapter
