#include <QtTest>

#include "core/session_core.h"

class TestSessionCore : public QObject
{
    Q_OBJECT

private slots:
    void testEnqueueDirectionRejectsReverseAndConsumesInOrder()
    {
        snakegb::core::SessionCore core;
        core.setDirection(QPoint(0, -1));

        QVERIFY(core.enqueueDirection(QPoint(1, 0)));
        QVERIFY(!core.enqueueDirection(QPoint(-1, 0)));
        QVERIFY(core.enqueueDirection(QPoint(0, -1)));
        QVERIFY(!core.enqueueDirection(QPoint(0, 1)));
        QVERIFY(!core.enqueueDirection(QPoint(1, 0)));

        QPoint next;
        QVERIFY(core.consumeQueuedInput(next));
        QCOMPARE(next, QPoint(1, 0));
        QVERIFY(core.consumeQueuedInput(next));
        QCOMPARE(next, QPoint(0, -1));
        QVERIFY(!core.consumeQueuedInput(next));
    }

    void testResetMethodsClearTransientAndReplayRuntime()
    {
        snakegb::core::SessionCore core;
        auto &state = core.state();
        state.direction = {1, 0};
        state.activeBuff = 4;
        state.buffTicksRemaining = 12;
        state.buffTicksTotal = 24;
        state.shieldActive = true;
        state.powerUpPos = {5, 6};
        state.tickCounter = 33;
        state.lastRoguelikeChoiceScore = 99;
        QVERIFY(core.enqueueDirection(QPoint(0, 1)));

        core.resetTransientRuntimeState();
        QCOMPARE(state.direction, QPoint(0, -1));
        QCOMPARE(state.activeBuff, 0);
        QCOMPARE(state.buffTicksRemaining, 0);
        QCOMPARE(state.buffTicksTotal, 0);
        QCOMPARE(state.powerUpPos, QPoint(-1, -1));
        QVERIFY(!state.shieldActive);
        QVERIFY(core.inputQueue().empty());

        core.resetReplayRuntimeState();
        QCOMPARE(state.tickCounter, 0);
        QCOMPARE(state.lastRoguelikeChoiceScore, -1000);
    }

    void testSnapshotRoundTripRestoresStateAndBody()
    {
        snakegb::core::SessionCore core;
        auto &state = core.state();
        state.food = {7, 8};
        state.direction = {1, 0};
        state.score = 14;
        state.obstacles = {QPoint(2, 2), QPoint(3, 2)};
        QVERIFY(core.enqueueDirection(QPoint(1, 0)));

        const std::deque<QPoint> body = {QPoint(5, 5), QPoint(4, 5), QPoint(3, 5)};
        const auto snapshot = core.snapshot(body);
        QCOMPARE(snapshot.body, body);

        snakegb::core::SessionCore restored;
        restored.restoreSnapshot(snapshot);

        QCOMPARE(restored.state().food, QPoint(7, 8));
        QCOMPARE(restored.state().direction, QPoint(1, 0));
        QCOMPARE(restored.state().score, 14);
        QCOMPARE(restored.state().obstacles, QList<QPoint>({QPoint(2, 2), QPoint(3, 2)}));
        QVERIFY(restored.inputQueue().empty());
    }

    void testBodyOwnershipAndMovement()
    {
        snakegb::core::SessionCore core;
        core.setBody({QPoint(10, 10), QPoint(10, 11), QPoint(10, 12)});

        QCOMPARE(core.headPosition(), QPoint(10, 10));

        core.applyMovement(QPoint(11, 10), false);
        QCOMPARE(core.body().front(), QPoint(11, 10));
        QCOMPARE(core.body().back(), QPoint(10, 11));
        QCOMPARE(core.body().size(), std::size_t(3));

        core.applyMovement(QPoint(12, 10), true);
        QCOMPARE(core.body().front(), QPoint(12, 10));
        QCOMPARE(core.body().size(), std::size_t(4));
    }
};

QTEST_MAIN(TestSessionCore)
#include "test_session_core.moc"
