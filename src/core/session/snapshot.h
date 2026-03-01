#pragma once

#include "core/session/state.h"

#include <QPoint>

#include <deque>

namespace snakegb::core {

struct StateSnapshot {
    SessionState state;
    std::deque<QPoint> body;
};

} // namespace snakegb::core
