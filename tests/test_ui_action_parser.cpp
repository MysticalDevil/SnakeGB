#include <QtTest/QtTest>

#include "adapter/ui/action.h"

class TestUiActionParser : public QObject {
  Q_OBJECT

private slots:
  void testKnownActionsMapToExpectedKinds();
  void testIndexedActionsParsePayload();
  void testUnknownAndInvalidActionsFallbackToUnknown();
};

void TestUiActionParser::testKnownActionsMapToExpectedKinds() {
  using snakegb::adapter::FeedbackUiAction;
  using snakegb::adapter::NavAction;
  using snakegb::adapter::PrimaryAction;
  using snakegb::adapter::StartAction;
  using snakegb::adapter::ToggleMusicAction;

  QCOMPARE(std::get<NavAction>(snakegb::adapter::parseUiAction("nav_up")).dy, -1);
  QVERIFY(std::holds_alternative<PrimaryAction>(snakegb::adapter::parseUiAction("primary")));
  QVERIFY(std::holds_alternative<StartAction>(snakegb::adapter::parseUiAction("start")));
  QVERIFY(
    std::holds_alternative<ToggleMusicAction>(snakegb::adapter::parseUiAction("toggle_music")));
  QVERIFY(std::holds_alternative<FeedbackUiAction>(snakegb::adapter::parseUiAction("feedback_ui")));
}

void TestUiActionParser::testIndexedActionsParsePayload() {
  using snakegb::adapter::SetLibraryIndexAction;
  using snakegb::adapter::SetMedalIndexAction;

  const auto libraryAction = snakegb::adapter::parseUiAction("set_library_index:7");
  QCOMPARE(std::get<SetLibraryIndexAction>(libraryAction).value, 7);

  const auto medalAction = snakegb::adapter::parseUiAction("set_medal_index:3");
  QCOMPARE(std::get<SetMedalIndexAction>(medalAction).value, 3);
}

void TestUiActionParser::testUnknownAndInvalidActionsFallbackToUnknown() {
  using snakegb::adapter::UnknownAction;

  QVERIFY(
    std::holds_alternative<UnknownAction>(snakegb::adapter::parseUiAction("not_a_real_action")));
  QVERIFY(std::holds_alternative<UnknownAction>(
    snakegb::adapter::parseUiAction("set_library_index:abc")));
  QVERIFY(
    std::holds_alternative<UnknownAction>(snakegb::adapter::parseUiAction("set_medal_index:bad")));
}

QTEST_MAIN(TestUiActionParser)
#include "test_ui_action_parser.moc"
