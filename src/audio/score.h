#pragma once

#include <array>
#include <cmath>
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

enum class PulseDuty : int {
  Narrow = 0,
  Quarter = 1,
  Half = 2,
  Wide = 3,
};

enum class Pitch : int {
  Rest = -1,
  C3 = 48,
  D3 = 50,
  E3 = 52,
  F3 = 53,
  G3 = 55,
  A3 = 57,
  B3 = 59,
  C4 = 60,
  D4 = 62,
  E4 = 64,
  F4 = 65,
  G4 = 67,
  A4 = 69,
  B4 = 71,
  C5 = 72,
  D5 = 74,
  E5 = 76,
  F5 = 77,
  G5 = 79,
  A5 = 81,
};

struct ScoreStep {
  int frequencyHz = 0;
  int durationMs = 0;
  double duty = 0.5;
  int amplitude = 32;
};

struct ScoreTrackStep {
  Pitch leadPitch = Pitch::Rest;
  Pitch bassPitch = Pitch::Rest;
  int durationMs = 0;
  PulseDuty leadDuty = PulseDuty::Quarter;
  PulseDuty bassDuty = PulseDuty::Half;
};

[[nodiscard]] inline auto dutyCycle(const PulseDuty duty) -> double {
  switch (duty) {
  case PulseDuty::Narrow:
    return 0.125;
  case PulseDuty::Quarter:
    return 0.25;
  case PulseDuty::Half:
    return 0.5;
  case PulseDuty::Wide:
    return 0.75;
  }
  return 0.5;
}

[[nodiscard]] inline auto pitchFrequencyHz(const Pitch pitch) -> int {
  if (pitch == Pitch::Rest) {
    return 0;
  }
  const auto midiNote = static_cast<int>(pitch);
  const auto semitoneOffset = static_cast<double>(midiNote - 69) / 12.0;
  return static_cast<int>(std::lround(440.0 * std::exp2(semitoneOffset)));
}

inline constexpr std::array<ScoreStep, 2> UiInteractCueSteps{{
  {.frequencyHz = 262, .durationMs = 22, .duty = 0.5, .amplitude = 18},
  {.frequencyHz = 330, .durationMs = 28, .duty = 0.5, .amplitude = 18},
}};

inline constexpr std::array<ScoreStep, 3> ConfirmCueSteps{{
  {.frequencyHz = 1046, .durationMs = 45, .duty = 0.25, .amplitude = 24},
  {.frequencyHz = 1318, .durationMs = 45, .duty = 0.25, .amplitude = 24},
  {.frequencyHz = 1567, .durationMs = 70, .duty = 0.25, .amplitude = 26},
}};

inline constexpr std::array<ScoreTrackStep, 32> MenuTrackSteps{{
  {.leadPitch = Pitch::E5, .bassPitch = Pitch::C3, .durationMs = 180},
  {.leadPitch = Pitch::G5, .bassPitch = Pitch::C3, .durationMs = 180},
  {.leadPitch = Pitch::A5, .bassPitch = Pitch::F3, .durationMs = 180},
  {.leadPitch = Pitch::G5, .bassPitch = Pitch::F3, .durationMs = 180},
  {.leadPitch = Pitch::E5, .bassPitch = Pitch::C3, .durationMs = 180},
  {.leadPitch = Pitch::D5, .bassPitch = Pitch::G3, .durationMs = 180},
  {.leadPitch = Pitch::E5, .bassPitch = Pitch::A3, .durationMs = 180},
  {.leadPitch = Pitch::G5, .bassPitch = Pitch::A3, .durationMs = 360},

  {.leadPitch = Pitch::A5, .bassPitch = Pitch::F3, .durationMs = 180},
  {.leadPitch = Pitch::G5, .bassPitch = Pitch::F3, .durationMs = 180},
  {.leadPitch = Pitch::E5, .bassPitch = Pitch::C3, .durationMs = 180},
  {.leadPitch = Pitch::C5, .bassPitch = Pitch::C3, .durationMs = 180},
  {.leadPitch = Pitch::D5, .bassPitch = Pitch::G3, .durationMs = 180},
  {.leadPitch = Pitch::E5, .bassPitch = Pitch::G3, .durationMs = 180},
  {.leadPitch = Pitch::D5, .bassPitch = Pitch::C3, .durationMs = 180},
  {.leadPitch = Pitch::C5, .bassPitch = Pitch::C3, .durationMs = 360},

  {.leadPitch = Pitch::G4, .bassPitch = Pitch::A3, .durationMs = 180},
  {.leadPitch = Pitch::C5, .bassPitch = Pitch::A3, .durationMs = 180},
  {.leadPitch = Pitch::E5, .bassPitch = Pitch::A3, .durationMs = 180},
  {.leadPitch = Pitch::G5, .bassPitch = Pitch::A3, .durationMs = 180},
  {.leadPitch = Pitch::F5, .bassPitch = Pitch::F3, .durationMs = 180},
  {.leadPitch = Pitch::E5, .bassPitch = Pitch::F3, .durationMs = 180},
  {.leadPitch = Pitch::D5, .bassPitch = Pitch::G3, .durationMs = 180},
  {.leadPitch = Pitch::E5, .bassPitch = Pitch::G3, .durationMs = 360},

  {.leadPitch = Pitch::G5, .bassPitch = Pitch::C3, .durationMs = 180},
  {.leadPitch = Pitch::A5, .bassPitch = Pitch::F3, .durationMs = 180},
  {.leadPitch = Pitch::G5, .bassPitch = Pitch::F3, .durationMs = 180},
  {.leadPitch = Pitch::E5, .bassPitch = Pitch::C3, .durationMs = 180},
  {.leadPitch = Pitch::D5, .bassPitch = Pitch::G3, .durationMs = 180},
  {.leadPitch = Pitch::E5, .bassPitch = Pitch::A3, .durationMs = 180},
  {.leadPitch = Pitch::C5, .bassPitch = Pitch::C3, .durationMs = 180},
  {.leadPitch = Pitch::G4, .bassPitch = Pitch::C3, .durationMs = 420},
}};

inline constexpr std::array<ScoreTrackStep, 26> GameplayTrackSteps{{
  {.leadPitch = Pitch::A4, .bassPitch = Pitch::A3, .durationMs = 300, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::B4, .bassPitch = Pitch::B3, .durationMs = 300, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::C5, .bassPitch = Pitch::C4, .durationMs = 300, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::D5, .bassPitch = Pitch::D3, .durationMs = 300, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::E5, .bassPitch = Pitch::E3, .durationMs = 600, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::D5, .bassPitch = Pitch::D3, .durationMs = 600, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::C5, .bassPitch = Pitch::C4, .durationMs = 300, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::B4, .bassPitch = Pitch::B3, .durationMs = 300, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::A4, .bassPitch = Pitch::A3, .durationMs = 600, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::Rest, .bassPitch = Pitch::Rest, .durationMs = 300},
  {.leadPitch = Pitch::E4, .bassPitch = Pitch::E3, .durationMs = 300, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::G4, .bassPitch = Pitch::G3, .durationMs = 300, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::A4, .bassPitch = Pitch::A3, .durationMs = 600, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::G4, .bassPitch = Pitch::G3, .durationMs = 300, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::E4, .bassPitch = Pitch::E3, .durationMs = 300, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::D4, .bassPitch = Pitch::D3, .durationMs = 600, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::A4, .bassPitch = Pitch::A3, .durationMs = 300, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::B4, .bassPitch = Pitch::B3, .durationMs = 300, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::C5, .bassPitch = Pitch::C4, .durationMs = 300, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::D5, .bassPitch = Pitch::D3, .durationMs = 300, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::E5, .bassPitch = Pitch::E3, .durationMs = 600, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::G5, .bassPitch = Pitch::G3, .durationMs = 600, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::A5, .bassPitch = Pitch::A3, .durationMs = 600, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::G5, .bassPitch = Pitch::G3, .durationMs = 300, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::E5, .bassPitch = Pitch::E3, .durationMs = 300, .leadDuty = PulseDuty::Half},
  {.leadPitch = Pitch::D5, .bassPitch = Pitch::D3, .durationMs = 600, .leadDuty = PulseDuty::Half},
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
