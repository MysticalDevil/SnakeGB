#pragma once

#include <array>
#include <optional>

#include "audio/event.h"
#include "audio/score.h"

namespace snakegb::audio {

enum class CueKind {
  Beep,
  Crash,
  Score,
};

struct CueSpec {
  Event event;
  CueKind kind = CueKind::Beep;
  ScoreCueId scoreCue = ScoreCueId::Confirm;
  int frequencyHz = 0;
  int durationMs = 0;
  bool updatesScore = false;
};

inline constexpr std::array<CueSpec, 5> CueTable{{
  {.event = Event::Food,
   .kind = CueKind::Beep,
   .frequencyHz = 880,
   .durationMs = 100,
   .updatesScore = true},
  {.event = Event::PowerUp, .kind = CueKind::Beep, .frequencyHz = 1200, .durationMs = 150},
  {.event = Event::Crash, .kind = CueKind::Crash, .durationMs = 500},
  {.event = Event::UiInteract, .kind = CueKind::Beep, .frequencyHz = 200, .durationMs = 50},
  {.event = Event::Confirm, .kind = CueKind::Score, .scoreCue = ScoreCueId::Confirm},
}};

[[nodiscard]] inline auto cueForEvent(const Event event) -> std::optional<CueSpec> {
  for (const auto& cue : CueTable) {
    if (cue.event == event) {
      return cue;
    }
  }
  return std::nullopt;
}

} // namespace snakegb::audio
