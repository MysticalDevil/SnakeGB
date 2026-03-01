#pragma once

#include <span>

#include <QStringView>
#include <QVector>

namespace snakegb::audio {

enum class ScoreCueId {
  UiInteract,
  Confirm,
};

enum class ScoreTrackId {
  Menu,
  Gameplay,
  Replay,
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

[[nodiscard]] auto dutyCycle(PulseDuty duty) -> double;
[[nodiscard]] auto pitchFrequencyHz(Pitch pitch) -> int;
[[nodiscard]] auto pitchFromName(QStringView name) -> Pitch;
[[nodiscard]] auto scoreCueSteps(ScoreCueId cueId) -> std::span<const ScoreStep>;
[[nodiscard]] auto scoreTrackSteps(ScoreTrackId trackId) -> std::span<const ScoreTrackStep>;

} // namespace snakegb::audio
