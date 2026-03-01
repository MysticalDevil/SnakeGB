#pragma once

#include <QList>
#include <QString>

namespace nenoserpent::core {

struct ChoiceSpec {
  int type = 0;
  QString name;
  QString description;
};

[[nodiscard]] auto pickRoguelikeChoices(uint seed, int count = 3) -> QList<ChoiceSpec>;

} // namespace nenoserpent::core
