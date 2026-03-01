#pragma once

#include <deque>

#include <QPoint>

#include "core/session/state.h"

namespace snakegb::core {

struct StateSnapshot {
  SessionState state;
  std::deque<QPoint> body;
};

} // namespace snakegb::core
