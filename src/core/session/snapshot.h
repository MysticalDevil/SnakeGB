#pragma once

#include <deque>

#include <QPoint>

#include "core/session/state.h"

namespace nenoserpent::core {

struct StateSnapshot {
  SessionState state;
  std::deque<QPoint> body;
};

} // namespace nenoserpent::core
