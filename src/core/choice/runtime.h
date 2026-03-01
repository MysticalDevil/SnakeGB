#pragma once

#include <QList>
#include <QString>

namespace snakegb::core {

struct ChoiceSpec {
  int type = 0;
  QString name;
  QString description;
};

[[nodiscard]] auto pickRoguelikeChoices(uint seed, int count = 3) -> QList<ChoiceSpec>;

} // namespace snakegb::core
