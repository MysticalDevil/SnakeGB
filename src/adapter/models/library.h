#pragma once

#include <QList>
#include <QVariantList>

namespace nenoserpent::adapter {

[[nodiscard]] auto buildFruitLibraryModel(const QList<int>& discoveredFruitTypes) -> QVariantList;
[[nodiscard]] auto buildMedalLibraryModel() -> QVariantList;

} // namespace nenoserpent::adapter
