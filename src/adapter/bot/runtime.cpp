#include "adapter/bot/runtime.h"

namespace nenoserpent::adapter::bot {

namespace {

struct ResolvedBackend {
  const BotBackend* primary = nullptr;
  QString reason;
  bool usedFallback = false;
};

auto resolveBackend(const RuntimeInput& input) -> ResolvedBackend {
  if (input.backend != nullptr && input.backend->isAvailable()) {
    return {.primary = input.backend, .reason = {}, .usedFallback = false};
  }
  if (input.backend != nullptr && input.fallbackBackend != nullptr &&
      input.fallbackBackend->isAvailable()) {
    return {
      .primary = input.fallbackBackend,
      .reason = QStringLiteral("backend-unavailable"),
      .usedFallback = true,
    };
  }
  if (input.fallbackBackend != nullptr && input.fallbackBackend->isAvailable()) {
    return {
      .primary = input.fallbackBackend,
      .reason = QStringLiteral("primary-missing"),
      .usedFallback = true,
    };
  }
  if (input.backend != nullptr) {
    return {.primary = input.backend, .reason = {}, .usedFallback = false};
  }
  return {.primary = &ruleBackend(), .reason = {}, .usedFallback = false};
}

} // namespace

auto step(const RuntimeInput& input) -> RuntimeOutput {
  const StrategyConfig& strategy =
    (input.strategy != nullptr) ? *input.strategy : defaultStrategyConfig();
  const auto resolved = resolveBackend(input);
  const BotBackend& backend = *resolved.primary;
  RuntimeOutput output{};
  output.nextCooldownTicks = input.cooldownTicks;
  output.backend = backend.name();
  output.usedFallback = resolved.usedFallback;
  output.fallbackReason = resolved.reason;
  if (!input.enabled) {
    output.nextCooldownTicks = 0;
    return output;
  }

  if (output.nextCooldownTicks > 0) {
    --output.nextCooldownTicks;
  }

  if (input.state == AppState::Playing) {
    output.enqueueDirection = backend.decideDirection(input.snapshot, strategy);
    if (!output.enqueueDirection.has_value() && input.fallbackBackend != nullptr &&
        input.fallbackBackend != &backend && input.fallbackBackend->isAvailable()) {
      output.enqueueDirection = input.fallbackBackend->decideDirection(input.snapshot, strategy);
      if (output.enqueueDirection.has_value()) {
        output.backend = input.fallbackBackend->name();
        output.usedFallback = true;
        output.fallbackReason = QStringLiteral("direction-empty");
      }
    }
    return output;
  }

  if (output.nextCooldownTicks > 0) {
    return output;
  }

  if (input.state == AppState::ChoiceSelection) {
    int bestIndex = backend.decideChoice(input.choices, strategy);
    if (bestIndex < 0 && input.fallbackBackend != nullptr && input.fallbackBackend != &backend &&
        input.fallbackBackend->isAvailable()) {
      bestIndex = input.fallbackBackend->decideChoice(input.choices, strategy);
      if (bestIndex >= 0) {
        output.backend = input.fallbackBackend->name();
        output.usedFallback = true;
        output.fallbackReason = QStringLiteral("choice-empty");
      }
    }
    if (bestIndex < 0) {
      return output;
    }
    output.setChoiceIndex = bestIndex;
    output.triggerStart = true;
    output.consumeTick = true;
    output.nextCooldownTicks = strategy.choiceCooldownTicks;
    return output;
  }

  if (input.state == AppState::StartMenu || input.state == AppState::Paused ||
      input.state == AppState::GameOver || input.state == AppState::Replaying) {
    output.triggerStart = true;
    output.consumeTick = true;
    output.nextCooldownTicks = strategy.stateActionCooldownTicks;
    return output;
  }

  return output;
}

} // namespace nenoserpent::adapter::bot
