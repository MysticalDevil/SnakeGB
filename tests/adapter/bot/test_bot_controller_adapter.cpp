#include <QtTest/QtTest>

#include "adapter/bot/controller.h"
#include "power_up_id.h"

class BotControllerAdapterTest final : public QObject {
  Q_OBJECT

private slots:
  void avoidsImmediateCollisionWhenChoosingDirection();
  void picksShieldOverOtherChoices();
  void picksMiniAsTopPriorityChoiceByDefault();
  void respectsCustomChoicePriorityFromStrategy();
};

void BotControllerAdapterTest::avoidsImmediateCollisionWhenChoosingDirection() {
  const auto direction = nenoserpent::adapter::bot::pickDirection({
    .head = QPoint(10, 10),
    .direction = QPoint(0, -1),
    .food = QPoint(10, 5),
    .boardWidth = 20,
    .boardHeight = 18,
    .obstacles = {QPoint(10, 9)},
    .body = {QPoint(10, 10), QPoint(10, 11), QPoint(10, 12)},
  });

  QVERIFY(direction.has_value());
  QVERIFY(*direction != QPoint(0, -1));
}

void BotControllerAdapterTest::picksShieldOverOtherChoices() {
  const QVariantList choices = {
    QVariantMap{{"type", static_cast<int>(PowerUpId::Magnet)}, {"name", "Magnet"}},
    QVariantMap{{"type", static_cast<int>(PowerUpId::Shield)}, {"name", "Shield"}},
    QVariantMap{{"type", static_cast<int>(PowerUpId::Gold)}, {"name", "Gold"}},
  };

  QCOMPARE(nenoserpent::adapter::bot::pickChoiceIndex(choices), 1);
}

void BotControllerAdapterTest::picksMiniAsTopPriorityChoiceByDefault() {
  const QVariantList choices = {
    QVariantMap{{"type", static_cast<int>(PowerUpId::Shield)}, {"name", "Shield"}},
    QVariantMap{{"type", static_cast<int>(PowerUpId::Mini)}, {"name", "Mini"}},
    QVariantMap{{"type", static_cast<int>(PowerUpId::Freeze)}, {"name", "Freeze"}},
  };

  QCOMPARE(nenoserpent::adapter::bot::pickChoiceIndex(choices), 1);
}

void BotControllerAdapterTest::respectsCustomChoicePriorityFromStrategy() {
  const QVariantList choices = {
    QVariantMap{{"type", static_cast<int>(PowerUpId::Shield)}, {"name", "Shield"}},
    QVariantMap{{"type", static_cast<int>(PowerUpId::Gold)}, {"name", "Gold"}},
  };
  auto strategy = nenoserpent::adapter::bot::defaultStrategyConfig();
  strategy.powerPriorityByType.insert(static_cast<int>(PowerUpId::Shield), 5);
  strategy.powerPriorityByType.insert(static_cast<int>(PowerUpId::Gold), 80);

  QCOMPARE(nenoserpent::adapter::bot::pickChoiceIndex(choices, strategy), 1);
}

QTEST_MAIN(BotControllerAdapterTest)
#include "test_bot_controller_adapter.moc"
