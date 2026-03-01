#include "adapter/models/choice.h"

#include <QtCore/qstringliteral.h>

using namespace Qt::StringLiterals;

namespace snakegb::adapter {

auto buildChoiceModel(const QList<snakegb::core::ChoiceSpec>& choices) -> QVariantList {
  QVariantList model;
  model.reserve(choices.size());
  for (const auto& choice : choices) {
    QVariantMap entry;
    entry.insert(u"type"_s, choice.type);
    entry.insert(u"name"_s, choice.name);
    entry.insert(u"desc"_s, choice.description);
    model.append(entry);
  }
  return model;
}

auto choiceTypeAt(const QVariantList& choices, const int index) -> std::optional<int> {
  if (index < 0 || index >= choices.size()) {
    return std::nullopt;
  }
  const QVariantMap selected = choices[index].toMap();
  if (!selected.contains(u"type"_s)) {
    return std::nullopt;
  }
  bool ok = false;
  const int type = selected.value(u"type"_s).toInt(&ok);
  if (!ok) {
    return std::nullopt;
  }
  return type;
}

} // namespace snakegb::adapter
