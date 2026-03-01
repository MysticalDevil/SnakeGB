#include "adapter/ui/action.h"

#include <QtTest/QtTest>

class TestUiActionParser : public QObject {
    Q_OBJECT

private slots:
    void testKnownActionsMapToExpectedKinds();
    void testIndexedActionsParsePayload();
    void testUnknownAndInvalidActionsFallbackToUnknown();
};

void TestUiActionParser::testKnownActionsMapToExpectedKinds() {
    using snakegb::adapter::UiActionKind;
    QCOMPARE(snakegb::adapter::parseUiAction("nav_up").kind, UiActionKind::NavUp);
    QCOMPARE(snakegb::adapter::parseUiAction("primary").kind, UiActionKind::Primary);
    QCOMPARE(snakegb::adapter::parseUiAction("start").kind, UiActionKind::Start);
    QCOMPARE(snakegb::adapter::parseUiAction("toggle_music").kind, UiActionKind::ToggleMusic);
    QCOMPARE(snakegb::adapter::parseUiAction("feedback_ui").kind, UiActionKind::FeedbackUi);
}

void TestUiActionParser::testIndexedActionsParsePayload() {
    using snakegb::adapter::UiActionKind;
    const auto libraryAction = snakegb::adapter::parseUiAction("set_library_index:7");
    QCOMPARE(libraryAction.kind, UiActionKind::SetLibraryIndex);
    QCOMPARE(libraryAction.value, 7);

    const auto medalAction = snakegb::adapter::parseUiAction("set_medal_index:3");
    QCOMPARE(medalAction.kind, UiActionKind::SetMedalIndex);
    QCOMPARE(medalAction.value, 3);
}

void TestUiActionParser::testUnknownAndInvalidActionsFallbackToUnknown() {
    using snakegb::adapter::UiActionKind;
    QCOMPARE(snakegb::adapter::parseUiAction("not_a_real_action").kind, UiActionKind::Unknown);
    QCOMPARE(snakegb::adapter::parseUiAction("set_library_index:abc").kind, UiActionKind::Unknown);
    QCOMPARE(snakegb::adapter::parseUiAction("set_medal_index:bad").kind, UiActionKind::Unknown);
}

QTEST_MAIN(TestUiActionParser)
#include "test_ui_action_parser.moc"
