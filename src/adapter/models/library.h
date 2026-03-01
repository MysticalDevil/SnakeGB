#pragma once

#include <QList>
#include <QVariantList>

namespace snakegb::adapter {

[[nodiscard]] auto buildFruitLibraryModel(const QList<int>& discoveredFruitTypes) -> QVariantList;
[[nodiscard]] auto buildMedalLibraryModel() -> QVariantList;

} // namespace snakegb::adapter
