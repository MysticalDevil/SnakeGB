#pragma once

#include <QList>
#include <QString>
#include <QVariantList>

namespace nenoserpent::adapter {

[[nodiscard]] auto fruitNameForType(int type) -> QString;
[[nodiscard]] auto buildFruitLibraryModel(const QList<int>& discoveredFruitTypes) -> QVariantList;
[[nodiscard]] auto buildMedalLibraryModel() -> QVariantList;
[[nodiscard]] auto achievementTitleForId(const QString& id) -> QString;
[[nodiscard]] auto achievementHintForId(const QString& id) -> QString;

} // namespace nenoserpent::adapter
