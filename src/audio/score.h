#pragma once

#include <array>
#include <span>

namespace snakegb::audio {

enum class ScoreCueId {
  UiInteract,
  Confirm,
};

enum class ScoreTrackId {
  Menu,
  Gameplay,
};

struct ScoreStep {
  int frequencyHz = 0;
  int durationMs = 0;
  double duty = 0.5;
  int amplitude = 32;
};

struct ScoreTrackStep {
  int leadFrequencyHz = 0;
  int bassFrequencyHz = 0;
  int durationMs = 0;
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

inline constexpr std::array<ScoreTrackStep, 8> MenuTrackSteps{{
  {.leadFrequencyHz = 523, .bassFrequencyHz = 262, .durationMs = 260},
  {.leadFrequencyHz = 659, .bassFrequencyHz = 330, .durationMs = 260},
  {.leadFrequencyHz = 784, .bassFrequencyHz = 392, .durationMs = 420},
  {.leadFrequencyHz = 659, .bassFrequencyHz = 330, .durationMs = 260},
  {.leadFrequencyHz = 523, .bassFrequencyHz = 262, .durationMs = 260},
  {.leadFrequencyHz = 392, .bassFrequencyHz = 196, .durationMs = 420},
  {.leadFrequencyHz = 440, .bassFrequencyHz = 220, .durationMs = 260},
  {.leadFrequencyHz = 494, .bassFrequencyHz = 247, .durationMs = 420},
}};

inline constexpr std::array<ScoreTrackStep, 26> GameplayTrackSteps{{
  {.leadFrequencyHz = 440, .bassFrequencyHz = 220, .durationMs = 300},
  {.leadFrequencyHz = 494, .bassFrequencyHz = 247, .durationMs = 300},
  {.leadFrequencyHz = 523, .bassFrequencyHz = 261, .durationMs = 300},
  {.leadFrequencyHz = 587, .bassFrequencyHz = 293, .durationMs = 300},
  {.leadFrequencyHz = 659, .bassFrequencyHz = 329, .durationMs = 600},
  {.leadFrequencyHz = 587, .bassFrequencyHz = 293, .durationMs = 600},
  {.leadFrequencyHz = 523, .bassFrequencyHz = 261, .durationMs = 300},
  {.leadFrequencyHz = 494, .bassFrequencyHz = 247, .durationMs = 300},
  {.leadFrequencyHz = 440, .bassFrequencyHz = 220, .durationMs = 600},
  {.leadFrequencyHz = 0, .bassFrequencyHz = 0, .durationMs = 300},
  {.leadFrequencyHz = 330, .bassFrequencyHz = 165, .durationMs = 300},
  {.leadFrequencyHz = 392, .bassFrequencyHz = 196, .durationMs = 300},
  {.leadFrequencyHz = 440, .bassFrequencyHz = 220, .durationMs = 600},
  {.leadFrequencyHz = 392, .bassFrequencyHz = 196, .durationMs = 300},
  {.leadFrequencyHz = 330, .bassFrequencyHz = 165, .durationMs = 300},
  {.leadFrequencyHz = 293, .bassFrequencyHz = 146, .durationMs = 600},
  {.leadFrequencyHz = 440, .bassFrequencyHz = 220, .durationMs = 300},
  {.leadFrequencyHz = 494, .bassFrequencyHz = 247, .durationMs = 300},
  {.leadFrequencyHz = 523, .bassFrequencyHz = 261, .durationMs = 300},
  {.leadFrequencyHz = 587, .bassFrequencyHz = 293, .durationMs = 300},
  {.leadFrequencyHz = 659, .bassFrequencyHz = 329, .durationMs = 600},
  {.leadFrequencyHz = 784, .bassFrequencyHz = 392, .durationMs = 600},
  {.leadFrequencyHz = 880, .bassFrequencyHz = 440, .durationMs = 600},
  {.leadFrequencyHz = 784, .bassFrequencyHz = 392, .durationMs = 300},
  {.leadFrequencyHz = 659, .bassFrequencyHz = 329, .durationMs = 300},
  {.leadFrequencyHz = 587, .bassFrequencyHz = 293, .durationMs = 600},
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

[[nodiscard]] inline auto scoreTrackSteps(const ScoreTrackId trackId)
  -> std::span<const ScoreTrackStep> {
  switch (trackId) {
  case ScoreTrackId::Menu:
    return MenuTrackSteps;
  case ScoreTrackId::Gameplay:
    return GameplayTrackSteps;
  }
  return {};
}

} // namespace snakegb::audio
