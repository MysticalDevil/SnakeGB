#pragma once

namespace nenoserpent::audio {

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

} // namespace nenoserpent::audio
