#include "input_semantics.h"

#include "game_engine_interface.h"

namespace snakegb::adapter {

auto resolveBackActionForState(const int state) -> BackAction {
    switch (state) {
        case AppState::Paused:
        case AppState::GameOver:
        case AppState::Replaying:
        case AppState::ChoiceSelection:
        case AppState::Library:
        case AppState::MedalRoom:
            return BackAction::QuitToMenu;
        case AppState::StartMenu:
            return BackAction::QuitApplication;
        default:
            return BackAction::None;
    }
}

} // namespace snakegb::adapter
