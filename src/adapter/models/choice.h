#pragma once

#include <optional>

#include <QList>
#include <QVariant>

#include "core/choice/runtime.h"

namespace nenoserpent::adapter {

[[nodiscard]] auto buildChoiceModel(const QList<nenoserpent::core::ChoiceSpec>& choices)
  -> QVariantList;
[[nodiscard]] auto choiceTypeAt(const QVariantList& choices, int index) -> std::optional<int>;

} // namespace nenoserpent::adapter
