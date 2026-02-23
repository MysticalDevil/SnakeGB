#include <QtTest/QtTest>

#include "adapter/ui_action.h"

using snakegb::adapter::UiAction;
using snakegb::adapter::UiActionDispatchCallbacks;
using snakegb::adapter::UiActionKind;

class UiActionDispatchAdapterTest final : public QObject
{
    Q_OBJECT

private slots:
    void dispatchesDirectionalAndIndexActions()
    {
        int dx = 0;
        int dy = 0;
        int libraryIndex = -1;
        int medalIndex = -1;

        UiActionDispatchCallbacks callbacks;
        callbacks.onMove = [&](int x, int y) {
            dx = x;
            dy = y;
        };
        callbacks.onSetLibraryIndex = [&](int value) { libraryIndex = value; };
        callbacks.onSetMedalIndex = [&](int value) { medalIndex = value; };

        snakegb::adapter::dispatchUiAction(UiAction{UiActionKind::NavLeft, 0}, callbacks);
        QCOMPARE(dx, -1);
        QCOMPARE(dy, 0);

        snakegb::adapter::dispatchUiAction(UiAction{UiActionKind::SetLibraryIndex, 7}, callbacks);
        QCOMPARE(libraryIndex, 7);

        snakegb::adapter::dispatchUiAction(UiAction{UiActionKind::SetMedalIndex, 3}, callbacks);
        QCOMPARE(medalIndex, 3);
    }

    void dispatchesStartAndBackActions()
    {
        int startCalls = 0;
        int backCalls = 0;

        UiActionDispatchCallbacks callbacks;
        callbacks.onStart = [&]() { ++startCalls; };
        callbacks.onBack = [&]() { ++backCalls; };

        snakegb::adapter::dispatchUiAction(UiAction{UiActionKind::Primary, 0}, callbacks);
        snakegb::adapter::dispatchUiAction(UiAction{UiActionKind::Start, 0}, callbacks);
        snakegb::adapter::dispatchUiAction(UiAction{UiActionKind::Back, 0}, callbacks);

        QCOMPARE(startCalls, 2);
        QCOMPARE(backCalls, 1);
    }

    void ignoresUnknownAction()
    {
        int calls = 0;
        UiActionDispatchCallbacks callbacks;
        callbacks.onStart = [&]() { ++calls; };
        callbacks.onMove = [&](int, int) { ++calls; };
        callbacks.onBack = [&]() { ++calls; };

        snakegb::adapter::dispatchUiAction(UiAction{UiActionKind::Unknown, 0}, callbacks);
        QCOMPARE(calls, 0);
    }
};

QTEST_MAIN(UiActionDispatchAdapterTest)
#include "test_ui_action_dispatch_adapter.moc"
