#pragma once

#include <optional>

#include <QList>
#include <QVariant>

#include "core/choice/runtime.h"

namespace snakegb::adapter {

[[nodiscard]] auto buildChoiceModel(const QList<snakegb::core::ChoiceSpec>& choices)
  -> QVariantList;
[[nodiscard]] auto choiceTypeAt(const QVariantList& choices, int index) -> std::optional<int>;

} // namespace snakegb::adapter
