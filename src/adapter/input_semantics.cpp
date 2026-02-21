#include "input_semantics.h"

#include "../game_engine_interface.h"

namespace snakegb::adapter {

auto resolveBackActionForState(const int state) -> BackAction {
    using StateId = IGameEngine::StateId;
    switch (state) {
        case StateId::Paused:
        case StateId::GameOver:
        case StateId::Replaying:
        case StateId::ChoiceSelection:
        case StateId::Library:
        case StateId::MedalRoom:
            return BackAction::QuitToMenu;
        case StateId::StartMenu:
            return BackAction::QuitApplication;
        default:
            return BackAction::None;
    }
}

} // namespace snakegb::adapter
