#include "core/game_rules.h"
#include "core/level_runtime.h"

#include <QtTest/QtTest>

class TestCoreRules : public QObject {
    Q_OBJECT

private slots:
    void testCollectFreeSpotsRespectsPredicate();
    void testMagnetCandidateSpotsPrioritizesXAxisWhenDistanceIsGreater();
    void testProbeCollisionRespectsGhostFlag();
    void testDynamicLevelFallbackProducesObstacles();
};

void TestCoreRules::testCollectFreeSpotsRespectsPredicate() {
    const QList<QPoint> freeSpots = snakegb::core::collectFreeSpots(3, 2, [](const QPoint &point) -> bool {
        return point == QPoint(0, 0) || point == QPoint(2, 1);
    });

    QCOMPARE(freeSpots.size(), 4);
    QVERIFY(!freeSpots.contains(QPoint(0, 0)));
    QVERIFY(!freeSpots.contains(QPoint(2, 1)));
}

void TestCoreRules::testMagnetCandidateSpotsPrioritizesXAxisWhenDistanceIsGreater() {
    const QList<QPoint> candidates = snakegb::core::magnetCandidateSpots(QPoint(1, 1), QPoint(9, 2), 20, 20);
    QVERIFY(!candidates.isEmpty());
    QCOMPARE(candidates.first(), QPoint(2, 1));
}

void TestCoreRules::testProbeCollisionRespectsGhostFlag() {
    const QList<QPoint> obstacles{QPoint(3, 3)};
    const std::deque<QPoint> snakeBody{QPoint(5, 5), QPoint(4, 5)};

    const snakegb::core::CollisionProbe obstacleHit =
        snakegb::core::probeCollision(QPoint(3, 3), obstacles, snakeBody, false);
    QVERIFY(obstacleHit.hitsObstacle);
    QCOMPARE(obstacleHit.obstacleIndex, 0);
    QVERIFY(!obstacleHit.hitsBody);

    const snakegb::core::CollisionProbe ghostBodyProbe =
        snakegb::core::probeCollision(QPoint(4, 5), obstacles, snakeBody, true);
    QVERIFY(!ghostBodyProbe.hitsBody);
}

void TestCoreRules::testDynamicLevelFallbackProducesObstacles() {
    const auto dynamicPulse = snakegb::core::dynamicObstaclesForLevel(u"Dynamic Pulse", 10);
    QVERIFY(dynamicPulse.has_value());
    QVERIFY(!dynamicPulse->isEmpty());

    const auto unknown = snakegb::core::dynamicObstaclesForLevel(u"Classic", 10);
    QVERIFY(!unknown.has_value());
}

QTEST_MAIN(TestCoreRules)
#include "test_core_rules.moc"

