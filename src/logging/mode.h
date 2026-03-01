#pragma once

namespace snakegb::logging {
enum class LogMode {
  Release,
  Dev,
  Debug,
};

inline auto detectBuildLogMode() -> LogMode {
#if defined(SNAKEGB_BUILD_DEBUG)
  return LogMode::Debug;
#elif defined(SNAKEGB_BUILD_DEV)
  return LogMode::Dev;
#else
  return LogMode::Release;
#endif
}
} // namespace snakegb::logging
