#include "adapter/models/library.h"

using namespace Qt::StringLiterals;

namespace nenoserpent::adapter {
namespace {

auto createFruitEntry(const int type,
                      const QString& name,
                      const QString& description,
                      const bool discovered) -> QVariantMap {
  QVariantMap map;
  map.insert(u"type"_s, type);
  map.insert(u"name"_s, discovered ? name : u"??????"_s);
  map.insert(u"desc"_s, discovered ? description : u"Eat this fruit in-game to unlock its data."_s);
  map.insert(u"discovered"_s, discovered);
  return map;
}

auto createMedalEntry(const QString& id, const QString& hint) -> QVariantMap {
  QVariantMap map;
  map.insert(u"id"_s, id);
  map.insert(u"hint"_s, hint);
  return map;
}

struct MedalInfo {
  QString id;
  QString title;
  QString hint;
};

auto medalCatalog() -> const QList<MedalInfo>& {
  static const QList<MedalInfo> medals{
    {.id = u"gold_medal"_s, .title = u"Gold Medal"_s, .hint = u"Reach 50 points"_s},
    {.id = u"silver_medal"_s, .title = u"Silver Medal"_s, .hint = u"Reach 20 points"_s},
    {.id = u"speed_demon"_s, .title = u"Speed Demon"_s, .hint = u"Hit the top speed tier"_s},
    {.id = u"centurion"_s, .title = u"Centurion"_s, .hint = u"Crash 100 times"_s},
    {.id = u"gourmet"_s, .title = u"Gourmet"_s, .hint = u"Eat 500 food"_s},
    {.id = u"pacifist"_s, .title = u"Pacifist"_s, .hint = u"Stay alive 60s without food"_s},
    {.id = u"last_stand"_s, .title = u"Last Stand"_s, .hint = u"Survive 20s after shield breaks"_s},
    {.id = u"collector"_s,
     .title = u"Collector"_s,
     .hint = u"Collect 4 different powers in one run"_s},
    {.id = u"power_chain"_s,
     .title = u"Power Chain"_s,
     .hint = u"Trigger 3 different power effects in one run"_s},
    {.id = u"minimalist"_s,
     .title = u"Minimalist"_s,
     .hint = u"Score 25 without any special fruit"_s},
    {.id = u"steady_nerves"_s, .title = u"Steady Nerves"_s, .hint = u"Hold high speed for 30s"_s},
    {.id = u"phase_walker"_s,
     .title = u"Phase Walker"_s,
     .hint = u"Use Ghost or Portal to slip through danger"_s},
  };
  return medals;
}

} // namespace

auto fruitNameForType(const int type) -> QString {
  switch (type) {
  case 1:
    return u"Ghost"_s;
  case 2:
    return u"Slow"_s;
  case 3:
    return u"Magnet"_s;
  case 4:
    return u"Shield"_s;
  case 5:
    return u"Portal"_s;
  case 6:
    return u"Gold"_s;
  case 7:
    return u"Laser"_s;
  case 8:
    return u"Mini"_s;
  case 9:
    return u"Freeze"_s;
  case 10:
    return u"Scout"_s;
  case 11:
    return u"Vacuum"_s;
  case 12:
    return u"Anchor"_s;
  default:
    return u"Unknown"_s;
  }
}

auto buildFruitLibraryModel(const QList<int>& discoveredFruitTypes) -> QVariantList {
  struct FruitInfo {
    int type;
    QString name;
    QString description;
  };

  const QList<FruitInfo> fruits{
    {.type = 1, .name = u"Ghost"_s, .description = u"Pass through yourself."_s},
    {.type = 2, .name = u"Slow"_s, .description = u"Drops speed by one tier."_s},
    {.type = 3, .name = u"Magnet"_s, .description = u"Pulls food toward the snake."_s},
    {.type = 4, .name = u"Shield"_s, .description = u"Survive one collision."_s},
    {.type = 5, .name = u"Portal"_s, .description = u"Pass through obstacle walls."_s},
    {.type = 6, .name = u"Gold"_s, .description = u"2x points per food."_s},
    {.type = 7, .name = u"Laser"_s, .description = u"Breaks one obstacle."_s},
    {.type = 8, .name = u"Mini"_s, .description = u"Shrinks body by 50%."_s},
    {.type = 9, .name = u"Freeze"_s, .description = u"Freezes dynamic hazards briefly."_s},
    {.type = 10, .name = u"Scout"_s, .description = u"Reveals the safest next cell."_s},
    {.type = 11, .name = u"Vacuum"_s, .description = u"Pulls nearby food and power-ups inward."_s},
    {.type = 12, .name = u"Anchor"_s, .description = u"Locks the current speed tier."_s},
  };

  QVariantList result;
  result.reserve(fruits.size());
  for (const auto& fruit : fruits) {
    result.append(createFruitEntry(
      fruit.type, fruit.name, fruit.description, discoveredFruitTypes.contains(fruit.type)));
  }
  return result;
}

auto buildMedalLibraryModel() -> QVariantList {
  QVariantList result;
  result.reserve(medalCatalog().size());
  for (const auto& medal : medalCatalog()) {
    QVariantMap entry = createMedalEntry(medal.id, medal.hint);
    entry.insert(u"title"_s, medal.title);
    result.append(entry);
  }
  return result;
}

auto achievementTitleForId(const QString& id) -> QString {
  for (const auto& medal : medalCatalog()) {
    if (medal.id == id) {
      return medal.title;
    }
  }
  return QString{};
}

auto achievementHintForId(const QString& id) -> QString {
  for (const auto& medal : medalCatalog()) {
    if (medal.id == id) {
      return medal.hint;
    }
  }
  return QString{};
}

} // namespace nenoserpent::adapter
