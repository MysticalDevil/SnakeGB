#pragma once

#include <array>
#include <span>

namespace snakegb::audio {

enum class ScoreCueId {
  UiInteract,
  Confirm,
};

struct ScoreStep {
  int frequencyHz = 0;
  int durationMs = 0;
  double duty = 0.5;
  int amplitude = 32;
};

inline constexpr std::array<ScoreStep, 2> UiInteractCueSteps{{
  {.frequencyHz = 262, .durationMs = 22, .duty = 0.5, .amplitude = 18},
  {.frequencyHz = 330, .durationMs = 28, .duty = 0.5, .amplitude = 18},
}};

inline constexpr std::array<ScoreStep, 3> ConfirmCueSteps{{
  {.frequencyHz = 1046, .durationMs = 45, .duty = 0.25, .amplitude = 24},
  {.frequencyHz = 1318, .durationMs = 45, .duty = 0.25, .amplitude = 24},
  {.frequencyHz = 1567, .durationMs = 70, .duty = 0.25, .amplitude = 26},
}};

[[nodiscard]] inline auto scoreCueSteps(const ScoreCueId cueId) -> std::span<const ScoreStep> {
  switch (cueId) {
  case ScoreCueId::UiInteract:
    return UiInteractCueSteps;
  case ScoreCueId::Confirm:
    return ConfirmCueSteps;
  }
  return {};
}

} // namespace snakegb::audio
