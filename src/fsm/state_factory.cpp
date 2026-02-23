#include "state_factory.h"

#include "../game_engine_interface.h"
#include "states.h"

namespace snakegb::fsm
{

auto createStateFor(IGameEngine &engine, int state) -> std::unique_ptr<GameState>
{
    switch (state) {
    case IGameEngine::Splash:
        return std::make_unique<SplashState>(engine);
    case IGameEngine::StartMenu:
        return std::make_unique<MenuState>(engine);
    case IGameEngine::Playing:
        return std::make_unique<PlayingState>(engine);
    case IGameEngine::Paused:
        return std::make_unique<PausedState>(engine);
    case IGameEngine::GameOver:
        return std::make_unique<GameOverState>(engine);
    case IGameEngine::Replaying:
        return std::make_unique<ReplayingState>(engine);
    case IGameEngine::ChoiceSelection:
        return std::make_unique<ChoiceState>(engine);
    case IGameEngine::Library:
        return std::make_unique<LibraryState>(engine);
    case IGameEngine::MedalRoom:
        return std::make_unique<MedalRoomState>(engine);
    default:
        return nullptr;
    }
}

} // namespace snakegb::fsm
