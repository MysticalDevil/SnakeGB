#include "adapter/level_script_runtime.h"

#include <QtTest/QtTest>

class TestLevelScriptRuntimeAdapter : public QObject {
    Q_OBJECT

private slots:
    void testTryApplyOnTickScriptParsesObstacleArray();
    void testTryApplyOnTickScriptRejectsMissingOrInvalidOnTick();
    void testApplyDynamicLevelFallbackDelegatesToCoreDynamicLevels();
};

void TestLevelScriptRuntimeAdapter::testTryApplyOnTickScriptParsesObstacleArray() {
    QJSEngine engine;
    engine.evaluate(QStringLiteral("function onTick(t){ return [{x:t,y:1},{x:2,y:t+1}]; }"));

    QList<QPoint> obstacles;
    QVERIFY(snakegb::adapter::tryApplyOnTickScript(engine, 7, obstacles));
    QCOMPARE(obstacles.size(), 2);
    QCOMPARE(obstacles[0], QPoint(7, 1));
    QCOMPARE(obstacles[1], QPoint(2, 8));
}

void TestLevelScriptRuntimeAdapter::testTryApplyOnTickScriptRejectsMissingOrInvalidOnTick() {
    QJSEngine engineNoTick;
    QList<QPoint> obstacles;
    QVERIFY(!snakegb::adapter::tryApplyOnTickScript(engineNoTick, 1, obstacles));

    QJSEngine engineInvalid;
    engineInvalid.evaluate(QStringLiteral("function onTick(t){ return 42; }"));
    QVERIFY(!snakegb::adapter::tryApplyOnTickScript(engineInvalid, 1, obstacles));
}

void TestLevelScriptRuntimeAdapter::testApplyDynamicLevelFallbackDelegatesToCoreDynamicLevels() {
    QList<QPoint> obstacles;
    QVERIFY(snakegb::adapter::applyDynamicLevelFallback(QStringLiteral("Dynamic Pulse"), 10, obstacles));
    QVERIFY(!obstacles.isEmpty());

    obstacles.clear();
    QVERIFY(!snakegb::adapter::applyDynamicLevelFallback(QStringLiteral("Classic"), 10, obstacles));
    QVERIFY(obstacles.isEmpty());
}

QTEST_MAIN(TestLevelScriptRuntimeAdapter)
#include "test_level_script_runtime_adapter.moc"
