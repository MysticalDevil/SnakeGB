#include "adapter/engine_adapter.h"
#include "adapter/ui/controller.h"
#include "app_state.h"
#include "power_up_id.h"

#include <QSignalSpy>
#include <QtTest/QtTest>

class TestUiCommandController : public QObject
{
    Q_OBJECT

private slots:
    static void testDispatchForwardsUiAction();
    static void testRequestStateChangeForwardsStateTransition();
    static void testSeedChoicePreviewForwardsDebugSeed();
};

void TestUiCommandController::testDispatchForwardsUiAction()
{
    EngineAdapter engineAdapter;
    UiCommandController controller(&engineAdapter);
    QSignalSpy paletteSpy(&controller, &UiCommandController::paletteChanged);

    controller.dispatch("next_palette");

    QCOMPARE(paletteSpy.count(), 1);
}

void TestUiCommandController::testRequestStateChangeForwardsStateTransition()
{
    EngineAdapter engineAdapter;
    UiCommandController controller(&engineAdapter);

    controller.requestStateChange(AppState::StartMenu);

    QCOMPARE(engineAdapter.state(), AppState::StartMenu);
}

void TestUiCommandController::testSeedChoicePreviewForwardsDebugSeed()
{
    EngineAdapter engineAdapter;
    UiCommandController controller(&engineAdapter);
    const QVariantList choiceTypes{PowerUpId::Rich, PowerUpId::Shield, PowerUpId::Ghost};

    controller.seedChoicePreview(choiceTypes);

    QCOMPARE(engineAdapter.state(), AppState::ChoiceSelection);
    QVERIFY(!engineAdapter.choices().isEmpty());
}

QTEST_MAIN(TestUiCommandController)
#include "test_ui_command_controller.moc"
