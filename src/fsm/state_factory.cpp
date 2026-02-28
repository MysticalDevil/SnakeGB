#include "state_factory.h"

#include "game_engine_interface.h"
#include "states.h"

namespace snakegb::fsm
{

auto createStateFor(IGameEngine &engine, int state) -> std::unique_ptr<GameState>
{
    switch (state) {
    case AppState::Splash:
        return std::make_unique<SplashState>(engine);
    case AppState::StartMenu:
        return std::make_unique<MenuState>(engine);
    case AppState::Playing:
        return std::make_unique<PlayingState>(engine);
    case AppState::Paused:
        return std::make_unique<PausedState>(engine);
    case AppState::GameOver:
        return std::make_unique<GameOverState>(engine);
    case AppState::Replaying:
        return std::make_unique<ReplayingState>(engine);
    case AppState::ChoiceSelection:
        return std::make_unique<ChoiceState>(engine);
    case AppState::Library:
        return std::make_unique<LibraryState>(engine);
    case AppState::MedalRoom:
        return std::make_unique<MedalRoomState>(engine);
    default:
        return nullptr;
    }
}

} // namespace snakegb::fsm
