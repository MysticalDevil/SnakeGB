#pragma once

#include "logging/mode.h"

namespace nenoserpent::logging {
auto applyLoggingPolicy(LogMode mode) -> void;
auto logModeName(LogMode mode) -> const char*;
} // namespace nenoserpent::logging
