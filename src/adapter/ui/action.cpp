#include "adapter/ui/action.h"

#include <utility>

#include <QtCore/qstringliteral.h>

using namespace Qt::StringLiterals;

namespace snakegb::adapter {

namespace {
template <class... Ts> struct Overloaded : Ts... {
  using Ts::operator()...;
};

template <class... Ts> Overloaded(Ts...) -> Overloaded<Ts...>;
} // namespace

auto parseUiAction(const QString& action) -> UiAction {
  if (action == u"nav_up"_s)
    return NavAction{0, -1};
  if (action == u"nav_down"_s)
    return NavAction{0, 1};
  if (action == u"nav_left"_s)
    return NavAction{-1, 0};
  if (action == u"nav_right"_s)
    return NavAction{1, 0};
  if (action == u"primary"_s)
    return PrimaryAction{};
  if (action == u"start"_s)
    return StartAction{};
  if (action == u"secondary"_s)
    return SecondaryAction{};
  if (action == u"select_short"_s)
    return SelectShortAction{};
  if (action == u"back"_s)
    return BackCommandAction{};
  if (action == u"toggle_shell_color"_s)
    return ToggleShellColorAction{};
  if (action == u"toggle_music"_s)
    return ToggleMusicAction{};
  if (action == u"quit_to_menu"_s)
    return QuitToMenuAction{};
  if (action == u"quit"_s)
    return QuitAction{};
  if (action == u"next_palette"_s)
    return NextPaletteAction{};
  if (action == u"delete_save"_s)
    return DeleteSaveAction{};
  if (action == u"state_start_menu"_s)
    return StateStartMenuAction{};
  if (action == u"state_splash"_s)
    return StateSplashAction{};
  if (action == u"feedback_light"_s)
    return FeedbackLightAction{};
  if (action == u"feedback_ui"_s)
    return FeedbackUiAction{};
  if (action == u"feedback_heavy"_s)
    return FeedbackHeavyAction{};

  if (action.startsWith(u"set_library_index:"_s)) {
    bool ok = false;
    const int value = action.sliced(18).toInt(&ok);
    if (ok)
      return SetLibraryIndexAction{value};
    return UnknownAction{};
  }
  if (action.startsWith(u"set_medal_index:"_s)) {
    bool ok = false;
    const int value = action.sliced(16).toInt(&ok);
    if (ok)
      return SetMedalIndexAction{value};
    return UnknownAction{};
  }

  return UnknownAction{};
}

auto dispatchUiAction(const UiAction& action, const UiActionDispatchCallbacks& callbacks) -> void {
  std::visit(Overloaded{
               [&](const UnknownAction&) -> void {},
               [&](const NavAction& nav) -> void {
                 if (callbacks.onMove)
                   callbacks.onMove(nav.dx, nav.dy);
               },
               [&](const PrimaryAction&) -> void {
                 if (callbacks.onStart)
                   callbacks.onStart();
               },
               [&](const StartAction&) -> void {
                 if (callbacks.onStart)
                   callbacks.onStart();
               },
               [&](const SecondaryAction&) -> void {
                 if (callbacks.onSecondary)
                   callbacks.onSecondary();
               },
               [&](const SelectShortAction&) -> void {
                 if (callbacks.onSelect)
                   callbacks.onSelect();
               },
               [&](const BackCommandAction&) -> void {
                 if (callbacks.onBack)
                   callbacks.onBack();
               },
               [&](const ToggleShellColorAction&) -> void {
                 if (callbacks.onToggleShellColor)
                   callbacks.onToggleShellColor();
               },
               [&](const ToggleMusicAction&) -> void {
                 if (callbacks.onToggleMusic)
                   callbacks.onToggleMusic();
               },
               [&](const QuitToMenuAction&) -> void {
                 if (callbacks.onQuitToMenu)
                   callbacks.onQuitToMenu();
               },
               [&](const QuitAction&) -> void {
                 if (callbacks.onQuit)
                   callbacks.onQuit();
               },
               [&](const NextPaletteAction&) -> void {
                 if (callbacks.onNextPalette)
                   callbacks.onNextPalette();
               },
               [&](const DeleteSaveAction&) -> void {
                 if (callbacks.onDeleteSave)
                   callbacks.onDeleteSave();
               },
               [&](const StateStartMenuAction&) -> void {
                 if (callbacks.onStateStartMenu)
                   callbacks.onStateStartMenu();
               },
               [&](const StateSplashAction&) -> void {
                 if (callbacks.onStateSplash)
                   callbacks.onStateSplash();
               },
               [&](const FeedbackLightAction&) -> void {
                 if (callbacks.onFeedbackLight)
                   callbacks.onFeedbackLight();
               },
               [&](const FeedbackUiAction&) -> void {
                 if (callbacks.onFeedbackUi)
                   callbacks.onFeedbackUi();
               },
               [&](const FeedbackHeavyAction&) -> void {
                 if (callbacks.onFeedbackHeavy)
                   callbacks.onFeedbackHeavy();
               },
               [&](const SetLibraryIndexAction& setIndex) -> void {
                 if (callbacks.onSetLibraryIndex)
                   callbacks.onSetLibraryIndex(setIndex.value);
               },
               [&](const SetMedalIndexAction& setIndex) -> void {
                 if (callbacks.onSetMedalIndex)
                   callbacks.onSetMedalIndex(setIndex.value);
               },
             },
             action);
}

} // namespace snakegb::adapter
