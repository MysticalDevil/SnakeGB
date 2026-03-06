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
  struct MedalInfo {
    QString title;
    QString description;
  };
  const QList<MedalInfo> medals{
    {.title = u"Gold Medal (50 Pts)"_s, .description = u"Reach 50 points"_s},
    {.title = u"Silver Medal (20 Pts)"_s, .description = u"Reach 20 points"_s},
    {.title = u"Centurion (100 Crashes)"_s, .description = u"Crash 100 times"_s},
    {.title = u"Gourmet (500 Food)"_s, .description = u"Eat 500 food"_s},
    {.title = u"Untouchable"_s, .description = u"20 Ghost triggers"_s},
    {.title = u"Speed Demon"_s, .description = u"Max speed reached"_s},
    {.title = u"Pacifist (60s No Food)"_s, .description = u"60s no food"_s},
  };

  QVariantList result;
  result.reserve(medals.size());
  for (const auto& medal : medals) {
    result.append(createMedalEntry(medal.title, medal.description));
  }
  return result;
}

} // namespace nenoserpent::adapter
