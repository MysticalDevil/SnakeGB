#include "core/game_rules.h"
#include "core/replay_timeline.h"
#include "core/buff_runtime.h"
#include "core/level_runtime.h"
#include "game_engine_interface.h"

#include <QtTest/QtTest>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <deque>

class TestCoreRules : public QObject {
    Q_OBJECT

private slots:
    void testCollectFreeSpotsRespectsPredicate();
    void testPickRandomFreeSpotUsesProvidedIndexAndHandlesEdgeCases();
    void testMagnetCandidateSpotsPrioritizesXAxisWhenDistanceIsGreater();
    void testProbeCollisionRespectsGhostFlag();
    void testDynamicLevelFallbackProducesObstacles();
    void testWallsFromJsonArrayParsesCoordinates();
    void testResolvedLevelDataFromJsonMapsIndexAndFields();
    void testResolvedLevelDataFromJsonBytesParsesDocumentEnvelope();
    void testBuffRuntimeRules();
    void testReplayTimelineAppliesOnlyOnMatchingTicks();
};

class FakeReplayEngine final : public IGameEngine {
public:
    struct InputFrame {
        int frame;
        int dx;
        int dy;
    };
    struct ChoiceFrame {
        int frame;
        int index;
    };

    int tick = 0;
    QPoint lastDirection{0, 0};
    int setDirectionCalls = 0;
    QList<int> selectedChoices;
    QList<InputFrame> inputFrames;
    QList<ChoiceFrame> choiceFrames;

    void setInternalState(int) override {}
    void requestStateChange(int) override {}
    [[nodiscard]] auto snakeModel() const -> const SnakeModel * override { return nullptr; }
    [[nodiscard]] auto headPosition() const -> QPoint override { return {}; }
    [[nodiscard]] auto currentDirection() const -> QPoint override { return lastDirection; }
    void setDirection(const QPoint &direction) override {
        lastDirection = direction;
        ++setDirectionCalls;
    }
    [[nodiscard]] auto currentTick() const -> int override { return tick; }
    auto consumeQueuedInput(QPoint &) -> bool override { return false; }
    void recordInputAtCurrentTick(const QPoint &) override {}
    [[nodiscard]] auto bestInputHistorySize() const -> int override { return inputFrames.size(); }
    auto bestInputFrameAt(int index, int &frame, int &dx, int &dy) const -> bool override {
        if (index < 0 || index >= inputFrames.size()) {
            return false;
        }
        const auto &sample = inputFrames[index];
        frame = sample.frame;
        dx = sample.dx;
        dy = sample.dy;
        return true;
    }
    [[nodiscard]] auto bestChoiceHistorySize() const -> int override { return choiceFrames.size(); }
    auto bestChoiceAt(int index, int &frame, int &choiceIndex) const -> bool override {
        if (index < 0 || index >= choiceFrames.size()) {
            return false;
        }
        const auto &sample = choiceFrames[index];
        frame = sample.frame;
        choiceIndex = sample.index;
        return true;
    }
    [[nodiscard]] auto foodPos() const -> QPoint override { return {}; }
    [[nodiscard]] auto currentState() const -> int override { return 0; }
    [[nodiscard]] auto hasPendingStateChange() const -> bool override { return false; }
    [[nodiscard]] auto hasSave() const -> bool override { return false; }
    [[nodiscard]] auto hasReplay() const -> bool override { return !inputFrames.isEmpty(); }
    auto checkCollision(const QPoint &) -> bool override { return false; }
    void handleFoodConsumption(const QPoint &) override {}
    void handlePowerUpConsumption(const QPoint &) override {}
    void applyMovement(const QPoint &, bool) override {}
    void restart() override {}
    void startReplay() override {}
    void loadLastSession() override {}
    void togglePause() override {}
    void nextLevel() override {}
    void nextPalette() override {}
    void startEngineTimer(int) override {}
    void stopEngineTimer() override {}
    void triggerHaptic(int) override {}
    void playEventSound(int, float) override {}
    void updatePersistence() override {}
    void lazyInit() override {}
    void lazyInitState() override {}
    void forceUpdate() override {}
    [[nodiscard]] auto choiceIndex() const -> int override { return -1; }
    void setChoiceIndex(int) override {}
    [[nodiscard]] auto libraryIndex() const -> int override { return 0; }
    [[nodiscard]] auto fruitLibrarySize() const -> int override { return 0; }
    void setLibraryIndex(int) override {}
    [[nodiscard]] auto medalIndex() const -> int override { return 0; }
    [[nodiscard]] auto medalLibrarySize() const -> int override { return 0; }
    void setMedalIndex(int) override {}
    void generateChoices() override {}
    void selectChoice(int index) override { selectedChoices.append(index); }
};

void TestCoreRules::testCollectFreeSpotsRespectsPredicate() {
    const QList<QPoint> freeSpots = snakegb::core::collectFreeSpots(3, 2, [](const QPoint &point) -> bool {
        return point == QPoint(0, 0) || point == QPoint(2, 1);
    });

    QCOMPARE(freeSpots.size(), 4);
    QVERIFY(!freeSpots.contains(QPoint(0, 0)));
    QVERIFY(!freeSpots.contains(QPoint(2, 1)));
}

void TestCoreRules::testPickRandomFreeSpotUsesProvidedIndexAndHandlesEdgeCases() {
    QPoint picked;
    const bool ok = snakegb::core::pickRandomFreeSpot(
        3,
        2,
        [](const QPoint &point) -> bool { return point == QPoint(0, 0) || point == QPoint(2, 1); },
        [](int size) -> int {
            if (size != 4) {
                return -1;
            }
            return 2;
        },
        picked);
    QVERIFY(ok);
    QCOMPARE(picked, QPoint(1, 1));

    const bool badIndex = snakegb::core::pickRandomFreeSpot(
        2,
        1,
        [](const QPoint &) -> bool { return false; },
        [](int) -> int { return 99; },
        picked);
    QVERIFY(!badIndex);

    const bool noFreeSpot = snakegb::core::pickRandomFreeSpot(
        2,
        2,
        [](const QPoint &) -> bool { return true; },
        [](int) -> int { return 0; },
        picked);
    QVERIFY(!noFreeSpot);
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

void TestCoreRules::testWallsFromJsonArrayParsesCoordinates() {
    QJsonArray wallsJson;
    wallsJson.append(QJsonObject{{"x", 1}, {"y", 2}});
    wallsJson.append(QJsonObject{{"x", 8}, {"y", 9}});

    const QList<QPoint> walls = snakegb::core::wallsFromJsonArray(wallsJson);
    QCOMPARE(walls.size(), 2);
    QCOMPARE(walls[0], QPoint(1, 2));
    QCOMPARE(walls[1], QPoint(8, 9));
}

void TestCoreRules::testResolvedLevelDataFromJsonMapsIndexAndFields() {
    QJsonArray levels;
    levels.append(QJsonObject{{"name", "L0"}, {"script", "function onTick(t){return [];}"}});
    levels.append(QJsonObject{
        {"name", "L1"},
        {"script", ""},
        {"walls", QJsonArray{QJsonObject{{"x", 3}, {"y", 4}}, QJsonObject{{"x", 5}, {"y", 6}}}}
    });

    const auto resolvedScript = snakegb::core::resolvedLevelDataFromJson(levels, 0);
    QVERIFY(resolvedScript.has_value());
    QCOMPARE(resolvedScript->name, QString("L0"));
    QVERIFY(!resolvedScript->script.isEmpty());
    QVERIFY(resolvedScript->walls.isEmpty());

    const auto resolvedWalls = snakegb::core::resolvedLevelDataFromJson(levels, 3);
    QVERIFY(resolvedWalls.has_value());
    QCOMPARE(resolvedWalls->name, QString("L1"));
    QVERIFY(resolvedWalls->script.isEmpty());
    QCOMPARE(resolvedWalls->walls.size(), 2);
    QCOMPARE(resolvedWalls->walls[0], QPoint(3, 4));
    QCOMPARE(resolvedWalls->walls[1], QPoint(5, 6));

    const auto empty = snakegb::core::resolvedLevelDataFromJson(QJsonArray{}, 0);
    QVERIFY(!empty.has_value());
}

void TestCoreRules::testResolvedLevelDataFromJsonBytesParsesDocumentEnvelope() {
    const QJsonObject level{
        {"name", "BytesLevel"},
        {"script", ""},
        {"walls", QJsonArray{QJsonObject{{"x", 11}, {"y", 12}}}}
    };
    const QJsonDocument document(QJsonObject{{"levels", QJsonArray{level}}});
    const auto resolved = snakegb::core::resolvedLevelDataFromJsonBytes(document.toJson(), 0);
    QVERIFY(resolved.has_value());
    QCOMPARE(resolved->name, QString("BytesLevel"));
    QCOMPARE(resolved->walls.size(), 1);
    QCOMPARE(resolved->walls.first(), QPoint(11, 12));

    const auto invalid = snakegb::core::resolvedLevelDataFromJsonBytes(QByteArrayLiteral("not-json"), 0);
    QVERIFY(!invalid.has_value());
}

void TestCoreRules::testBuffRuntimeRules() {
    QCOMPARE(snakegb::core::foodPointsForBuff(snakegb::core::BuffId::None), 1);
    QCOMPARE(snakegb::core::foodPointsForBuff(snakegb::core::BuffId::Double), 2);
    QCOMPARE(snakegb::core::foodPointsForBuff(snakegb::core::BuffId::Rich), 3);

    QCOMPARE(snakegb::core::buffDurationTicks(snakegb::core::BuffId::Rich, 40), 20);
    QCOMPARE(snakegb::core::buffDurationTicks(snakegb::core::BuffId::Ghost, 40), 40);

    QCOMPARE(snakegb::core::miniShrinkTargetLength(10), 5);
    QCOMPARE(snakegb::core::miniShrinkTargetLength(5), 3);
    QCOMPARE(snakegb::core::miniShrinkTargetLength(2), 3);
}

void TestCoreRules::testReplayTimelineAppliesOnlyOnMatchingTicks() {
    FakeReplayEngine engine;
    engine.inputFrames = {{1, 1, 0}, {3, 0, -1}, {3, -1, 0}, {6, 0, 1}};
    engine.choiceFrames = {{2, 4}, {2, 5}, {4, 1}};

    int inputIndex = 0;
    int choiceIndex = 0;

    engine.tick = 0;
    snakegb::core::applyReplayInputsForCurrentTick(engine, inputIndex);
    QCOMPARE(engine.setDirectionCalls, 0);
    QCOMPARE(inputIndex, 0);

    engine.tick = 1;
    snakegb::core::applyReplayInputsForCurrentTick(engine, inputIndex);
    QCOMPARE(engine.setDirectionCalls, 1);
    QCOMPARE(engine.lastDirection, QPoint(1, 0));
    QCOMPARE(inputIndex, 1);

    engine.tick = 3;
    snakegb::core::applyReplayInputsForCurrentTick(engine, inputIndex);
    QCOMPARE(engine.setDirectionCalls, 3);
    QCOMPARE(engine.lastDirection, QPoint(-1, 0));
    QCOMPARE(inputIndex, 3);

    engine.tick = 7;
    snakegb::core::applyReplayInputsForCurrentTick(engine, inputIndex);
    QCOMPARE(engine.setDirectionCalls, 3);
    QCOMPARE(inputIndex, 4);

    engine.tick = 2;
    snakegb::core::applyReplayChoicesForCurrentTick(engine, choiceIndex);
    QCOMPARE(engine.selectedChoices.size(), 1);
    QCOMPARE(engine.selectedChoices.first(), 4);
    QCOMPARE(choiceIndex, 1);

    snakegb::core::applyReplayChoicesForCurrentTick(engine, choiceIndex);
    QCOMPARE(engine.selectedChoices.size(), 2);
    QCOMPARE(engine.selectedChoices.last(), 5);
    QCOMPARE(choiceIndex, 2);

    engine.tick = 4;
    snakegb::core::applyReplayChoicesForCurrentTick(engine, choiceIndex);
    QCOMPARE(engine.selectedChoices.size(), 3);
    QCOMPARE(engine.selectedChoices.last(), 1);
    QCOMPARE(choiceIndex, 3);
}

QTEST_MAIN(TestCoreRules)
#include "test_core_rules.moc"
