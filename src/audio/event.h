#pragma once

namespace snakegb::audio {

enum class Event {
  Food,
  PowerUp,
  Crash,
  UiInteract,
  Confirm,
};

struct EventPayload {
  int score = 0;
  float pan = 0.0F;
};

} // namespace snakegb::audio
