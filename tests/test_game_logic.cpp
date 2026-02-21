#include <QtTest>
#include <QCoreApplication>
#include <QSet>
#include "game_logic.h"

class TestGameLogic : public QObject {
    Q_OBJECT
private:
    static auto pickBuff(GameLogic &game, int buffType) -> bool {
        for (int attempt = 0; attempt < 80; ++attempt) {
            game.generateChoices();
            const auto currentChoices = game.choices();
            for (int i = 0; i < currentChoices.size(); ++i) {
                const auto map = currentChoices[i].toMap();
                if (map.value("type").toInt() == buffType) {
                    game.selectChoice(i);
                    return true;
                }
            }
        }
        return false;
    }

private slots:
    void testInitialState() {
        GameLogic game;
        QVERIFY(game.state() == GameLogic::Splash || game.state() == GameLogic::StartMenu);
    }

    void testGameCycle() {
        GameLogic game;
        game.startGame(); 
        
        // Push logic far enough to ensure it hits boundary or completes splash
        for(int i=0; i<100; ++i) game.forceUpdate();

        // After 100 forced steps, it MUST have transitioned out of Playing or hit boundary
        QVERIFY(game.state() != GameLogic::Splash);
        QVERIFY(game.state() == GameLogic::Playing || game.state() == GameLogic::GameOver);
    }

    void testSnakeMovesAfterStart() {
        GameLogic game;
        game.startGame();
        const QPoint before = game.snakeModelPtr()->body().front();
        game.forceUpdate();
        const QPoint after = game.snakeModelPtr()->body().front();
        QVERIFY(before != after);
    }

    void testSplashTransitionRequest() {
        GameLogic game;
        game.requestStateChange(GameLogic::StartMenu);
        QVERIFY(game.state() == GameLogic::StartMenu);
        game.requestStateChange(GameLogic::Splash);
        QVERIFY(game.state() == GameLogic::Splash);
    }

    void testNextLevelChangesName() {
        GameLogic game;
        const QString before = game.currentLevelName();
        game.nextLevel();
        const QString after = game.currentLevelName();
        QVERIFY(before != after);
    }

    void testHandleSelectInMenuChangesLevel() {
        GameLogic game;
        game.requestStateChange(GameLogic::StartMenu);
        const QString before = game.currentLevelName();
        game.handleSelect();
        const QString after = game.currentLevelName();
        QVERIFY(before != after);
    }

    void testTheCageAppliesObstaclesOnNewRun() {
        GameLogic game;
        game.requestStateChange(GameLogic::StartMenu);
        game.deleteSave();
        QVERIFY2(!game.hasSave(), "Save session should be cleared before starting The Cage");

        // Classic -> The Cage
        game.handleSelect();
        QCOMPARE(game.currentLevelName(), QString("The Cage"));

        game.handleStart();
        QVERIFY(game.state() == GameLogic::Playing || game.state() == GameLogic::Paused);
        QVERIFY2(game.obstacles().size() > 0, "The Cage should spawn wall obstacles in-game");
    }

    void testDynamicPulseHasObstaclesOnStart() {
        GameLogic game;
        game.requestStateChange(GameLogic::StartMenu);
        game.deleteSave();

        // Classic -> The Cage -> Dynamic Pulse
        game.handleSelect();
        game.handleSelect();
        QCOMPARE(game.currentLevelName(), QString("Dynamic Pulse"));

        game.handleStart();
        QVERIFY(game.state() == GameLogic::Playing || game.state() == GameLogic::Paused);
        QVERIFY2(game.obstacles().size() > 0, "Dynamic Pulse should produce dynamic obstacles");
    }

    void testDynamicPulseObstaclesMoveOverTime() {
        GameLogic game;
        game.requestStateChange(GameLogic::StartMenu);
        game.deleteSave();

        game.handleSelect();
        game.handleSelect();
        QCOMPARE(game.currentLevelName(), QString("Dynamic Pulse"));

        game.handleStart();
        const QVariantList before = game.obstacles();
        for (int i = 0; i < 6; ++i) {
            game.forceUpdate();
        }
        const QVariantList after = game.obstacles();
        QVERIFY2(before != after, "Dynamic Pulse obstacles should change over time");
    }

    void testDeleteSaveResetsLevelToClassicAndNewRunUsesClassic() {
        GameLogic game;
        game.requestStateChange(GameLogic::StartMenu);
        game.deleteSave();

        // Move away from Classic and create a save by returning to menu.
        game.handleSelect();
        game.handleSelect();
        QCOMPARE(game.currentLevelName(), QString("Dynamic Pulse"));
        game.handleStart();
        QVERIFY(game.state() == GameLogic::Playing || game.state() == GameLogic::Paused);
        game.quitToMenu();
        QVERIFY2(game.hasSave(), "Session save should exist after quitting from an active run");

        // Clear save and start without selecting level again.
        game.deleteSave();
        QVERIFY2(!game.hasSave(), "Session save should be cleared");
        QCOMPARE(game.currentLevelName(), QString("Classic"));

        game.handleStart();
        QVERIFY2(game.state() == GameLogic::Playing || game.state() == GameLogic::Paused,
                 "Start should begin a new run, not reload old session");
        QCOMPARE(game.obstacles().size(), 0);
    }

    void testDeleteSaveThenSelectStartsChosenLevel() {
        GameLogic game;
        game.requestStateChange(GameLogic::StartMenu);
        game.deleteSave();
        QCOMPARE(game.currentLevelName(), QString("Classic"));

        // After reset to Classic, one select should choose The Cage.
        game.handleSelect();
        QCOMPARE(game.currentLevelName(), QString("The Cage"));

        game.handleStart();
        QVERIFY2(game.state() == GameLogic::Playing || game.state() == GameLogic::Paused,
                 "Start should begin a new run");
        QVERIFY2(game.obstacles().size() > 0,
                 "The Cage run should use The Cage obstacles");
    }

    void testTunnelRunInitialSpawnAvoidsObstacles() {
        GameLogic game;
        game.requestStateChange(GameLogic::StartMenu);
        game.deleteSave();

        // Classic -> The Cage -> Dynamic Pulse -> Tunnel Run
        game.handleSelect();
        game.handleSelect();
        game.handleSelect();
        QCOMPARE(game.currentLevelName(), QString("Tunnel Run"));

        game.handleStart();
        QVERIFY(game.state() == GameLogic::Playing || game.state() == GameLogic::Paused);

        QSet<QPoint> obstacleSet;
        for (const QVariant &item : game.obstacles()) {
            const QVariantMap map = item.toMap();
            obstacleSet.insert(QPoint(map.value("x").toInt(), map.value("y").toInt()));
        }
        for (const QPoint &segment : game.snakeModelPtr()->body()) {
            QVERIFY2(!obstacleSet.contains(segment),
                     "Tunnel Run initial snake body must not overlap obstacles");
        }
    }

    void testHeadWrapsAtBoundary() {
        GameLogic game;
        game.requestStateChange(GameLogic::StartMenu);
        game.deleteSave();
        game.handleStart();

        game.snakeModelPtr()->reset({QPoint(19, 10), QPoint(18, 10), QPoint(17, 10)});
        game.setDirection(QPoint(1, 0));

        game.forceUpdate();
        const QPoint head = game.snakeModelPtr()->body().front();
        QCOMPARE(head, QPoint(0, 10));
    }

    void testDoubleBuffCrossesTenThresholdKeepsValidState() {
        GameLogic game;
        game.startGame();

        for (int i = 0; i < 9; ++i) {
            game.handleFoodConsumption(game.food());
        }
        QCOMPARE(game.score(), 9);

        QVERIFY2(pickBuff(game, GameLogic::Double), "Failed to pick Double buff from generated choices");
        QCOMPARE(game.activeBuff(), static_cast<int>(GameLogic::Double));

        game.handleFoodConsumption(game.food());
        QCOMPARE(game.score(), 11);
        QVERIFY2(game.state() == GameLogic::Playing || game.state() == GameLogic::ChoiceSelection,
                 "Dynamic roguelike trigger should keep state valid without forcing a fixed threshold popup");
    }

    void testQuitToMenuFromGameOverDoesNotCreateSave() {
        GameLogic game;
        game.requestStateChange(GameLogic::StartMenu);
        game.deleteSave();
        QVERIFY(!game.hasSave());

        game.handleStart();
        QVERIFY(game.state() == GameLogic::Playing || game.state() == GameLogic::Paused);

        game.snakeModelPtr()->reset({QPoint(10, 10), QPoint(11, 10), QPoint(12, 10)});
        game.setDirection(QPoint(1, 0));
        game.forceUpdate();
        QCOMPARE(game.state(), GameLogic::GameOver);
        QVERIFY(!game.hasSave());

        game.quitToMenu();
        QCOMPARE(game.state(), GameLogic::StartMenu);
        QVERIFY2(!game.hasSave(), "GameOver back-to-menu should not generate a continue save");
    }

    void testLatestBuffSelectionOverridesPreviousBuff() {
        GameLogic game;
        game.startGame();

        QVERIFY2(pickBuff(game, GameLogic::Ghost), "Failed to pick Ghost buff");
        QCOMPARE(game.activeBuff(), static_cast<int>(GameLogic::Ghost));

        QVERIFY2(pickBuff(game, GameLogic::Slow), "Failed to pick Slow buff");
        QCOMPARE(game.activeBuff(), static_cast<int>(GameLogic::Slow));
    }

    void testReplayAppliesRecordedInputOnMatchingFrame() {
        GameLogic game;
        game.startGame();

        game.move(1, 0);
        game.forceUpdate();

        game.handleFoodConsumption(game.food());
        QVERIFY(game.score() > 0);

        game.snakeModelPtr()->reset({QPoint(10, 10), QPoint(11, 10), QPoint(12, 10)});
        game.setDirection(QPoint(1, 0));
        game.forceUpdate();
        QCOMPARE(game.state(), GameLogic::GameOver);
        QVERIFY2(game.hasReplay(), "Replay should be available after a new high score run");

        game.requestStateChange(GameLogic::StartMenu);
        game.startReplay();
        QCOMPARE(game.state(), GameLogic::Replaying);

        game.forceUpdate();
        QCOMPARE(game.snakeModelPtr()->body().front(), QPoint(11, 10));
    }
};

QTEST_MAIN(TestGameLogic)
#include "test_game_logic.moc"
