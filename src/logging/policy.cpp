#include "logging/policy.h"

#include <QLoggingCategory>
#include <QString>

namespace {
auto releaseRules() -> QString {
  return QStringLiteral("NenoSerpent.*.debug=false\n"
                        "NenoSerpent.*.info=false\n"
                        "NenoSerpent.*.warning=false\n");
}

auto devRules() -> QString {
  return QStringLiteral("NenoSerpent.*.debug=false\n"
                        "NenoSerpent.*.info=true\n"
                        "NenoSerpent.*.warning=true\n");
}

auto debugRules() -> QString {
  return QStringLiteral("NenoSerpent.*.debug=true\n"
                        "NenoSerpent.*.info=true\n"
                        "NenoSerpent.*.warning=true\n");
}
} // namespace

namespace nenoserpent::logging {
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
} // namespace nenoserpent::logging
