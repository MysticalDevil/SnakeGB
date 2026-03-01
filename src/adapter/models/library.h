#pragma once

#include <QList>
#include <QString>
#include <QVariantList>

namespace nenoserpent::adapter {

[[nodiscard]] auto fruitNameForType(int type) -> QString;
[[nodiscard]] auto buildFruitLibraryModel(const QList<int>& discoveredFruitTypes) -> QVariantList;
[[nodiscard]] auto buildMedalLibraryModel() -> QVariantList;

} // namespace nenoserpent::adapter
