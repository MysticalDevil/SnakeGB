#pragma once

namespace nenoserpent::logging {
enum class LogMode {
  Release,
  Dev,
  Debug,
};

inline auto detectBuildLogMode() -> LogMode {
#if defined(NENOSERPENT_BUILD_DEBUG)
  return LogMode::Debug;
#elif defined(NENOSERPENT_BUILD_DEV)
  return LogMode::Dev;
#else
  return LogMode::Release;
#endif
}
} // namespace nenoserpent::logging
