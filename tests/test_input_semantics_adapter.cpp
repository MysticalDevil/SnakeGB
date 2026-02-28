#include "adapter/input_semantics.h"
#include "game_engine_interface.h"

#include <QtTest/QtTest>

class TestInputSemanticsAdapter : public QObject {
    Q_OBJECT

private slots:
    void testBackActionByState();
};

void TestInputSemanticsAdapter::testBackActionByState() {
    using snakegb::adapter::BackAction;

    QCOMPARE(snakegb::adapter::resolveBackActionForState(AppState::StartMenu), BackAction::QuitApplication);
    QCOMPARE(snakegb::adapter::resolveBackActionForState(AppState::Paused), BackAction::QuitToMenu);
    QCOMPARE(snakegb::adapter::resolveBackActionForState(AppState::GameOver), BackAction::QuitToMenu);
    QCOMPARE(snakegb::adapter::resolveBackActionForState(AppState::Replaying), BackAction::QuitToMenu);
    QCOMPARE(snakegb::adapter::resolveBackActionForState(AppState::ChoiceSelection), BackAction::QuitToMenu);
    QCOMPARE(snakegb::adapter::resolveBackActionForState(AppState::Library), BackAction::QuitToMenu);
    QCOMPARE(snakegb::adapter::resolveBackActionForState(AppState::MedalRoom), BackAction::QuitToMenu);

    QCOMPARE(snakegb::adapter::resolveBackActionForState(AppState::Splash), BackAction::None);
    QCOMPARE(snakegb::adapter::resolveBackActionForState(AppState::Playing), BackAction::None);
    QCOMPARE(snakegb::adapter::resolveBackActionForState(-1), BackAction::None);
}

QTEST_MAIN(TestInputSemanticsAdapter)
#include "test_input_semantics_adapter.moc"
