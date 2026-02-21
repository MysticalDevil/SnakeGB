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

    QCOMPARE(snakegb::adapter::resolveBackActionForState(IGameEngine::StartMenu), BackAction::QuitApplication);
    QCOMPARE(snakegb::adapter::resolveBackActionForState(IGameEngine::Paused), BackAction::QuitToMenu);
    QCOMPARE(snakegb::adapter::resolveBackActionForState(IGameEngine::GameOver), BackAction::QuitToMenu);
    QCOMPARE(snakegb::adapter::resolveBackActionForState(IGameEngine::Replaying), BackAction::QuitToMenu);
    QCOMPARE(snakegb::adapter::resolveBackActionForState(IGameEngine::ChoiceSelection), BackAction::QuitToMenu);
    QCOMPARE(snakegb::adapter::resolveBackActionForState(IGameEngine::Library), BackAction::QuitToMenu);
    QCOMPARE(snakegb::adapter::resolveBackActionForState(IGameEngine::MedalRoom), BackAction::QuitToMenu);

    QCOMPARE(snakegb::adapter::resolveBackActionForState(IGameEngine::Splash), BackAction::None);
    QCOMPARE(snakegb::adapter::resolveBackActionForState(IGameEngine::Playing), BackAction::None);
    QCOMPARE(snakegb::adapter::resolveBackActionForState(-1), BackAction::None);
}

QTEST_MAIN(TestInputSemanticsAdapter)
#include "test_input_semantics_adapter.moc"
