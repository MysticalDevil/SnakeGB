#include "logging/policy.h"

#include <QLoggingCategory>
#include <QString>

namespace {
auto releaseRules() -> QString {
  return QStringLiteral("snakegb.*.debug=false\n"
                        "snakegb.*.info=false\n"
                        "snakegb.*.warning=false\n");
}

auto devRules() -> QString {
  return QStringLiteral("snakegb.*.debug=false\n"
                        "snakegb.*.info=true\n"
                        "snakegb.*.warning=true\n");
}

auto debugRules() -> QString {
  return QStringLiteral("snakegb.*.debug=true\n"
                        "snakegb.*.info=true\n"
                        "snakegb.*.warning=true\n");
}
} // namespace

namespace snakegb::logging {
auto applyLoggingPolicy(const LogMode mode) -> void {
  switch (mode) {
  case LogMode::Release:
    QLoggingCategory::setFilterRules(releaseRules());
    return;
  case LogMode::Dev:
    QLoggingCategory::setFilterRules(devRules());
    return;
  case LogMode::Debug:
    QLoggingCategory::setFilterRules(debugRules());
    return;
  }
}

auto logModeName(const LogMode mode) -> const char* {
  switch (mode) {
  case LogMode::Release:
    return "release";
  case LogMode::Dev:
    return "dev";
  case LogMode::Debug:
    return "debug";
  }
  return "release";
}
} // namespace snakegb::logging
