#pragma once

#include "logging/mode.h"

namespace snakegb::logging {
auto applyLoggingPolicy(LogMode mode) -> void;
auto logModeName(LogMode mode) -> const char*;
} // namespace snakegb::logging
