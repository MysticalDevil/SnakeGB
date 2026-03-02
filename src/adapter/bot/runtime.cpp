#include "adapter/bot/runtime.h"

namespace nenoserpent::adapter::bot {

auto step(const RuntimeInput& input) -> RuntimeOutput {
  RuntimeOutput output{};
  output.nextCooldownTicks = input.cooldownTicks;
  if (!input.enabled) {
    output.nextCooldownTicks = 0;
    return output;
  }

  if (output.nextCooldownTicks > 0) {
    --output.nextCooldownTicks;
  }

  if (input.state == AppState::Playing) {
    output.enqueueDirection = pickDirection(input.snapshot);
    return output;
  }

  if (output.nextCooldownTicks > 0) {
    return output;
  }

  if (input.state == AppState::ChoiceSelection) {
    const int bestIndex = pickChoiceIndex(input.choices);
    if (bestIndex < 0) {
      return output;
    }
    output.setChoiceIndex = bestIndex;
    output.triggerStart = true;
    output.consumeTick = true;
    output.nextCooldownTicks = 2;
    return output;
  }

  if (input.state == AppState::StartMenu || input.state == AppState::Paused ||
      input.state == AppState::GameOver || input.state == AppState::Replaying) {
    output.triggerStart = true;
    output.consumeTick = true;
    output.nextCooldownTicks = 4;
    return output;
  }

  return output;
}

} // namespace nenoserpent::adapter::bot
