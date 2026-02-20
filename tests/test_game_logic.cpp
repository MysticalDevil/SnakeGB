#include <QtTest>
#include <QCoreApplication>
#include "game_logic.h"

class TestGameLogic : public QObject {
    Q_OBJECT
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

    void testHeadWrapsAtBoundary() {
        GameLogic game;
        game.requestStateChange(GameLogic::StartMenu);
        game.deleteSave();
        game.handleStart();

        game.snakeModelPtr()->reset({QPoint(19, 10), QPoint(18, 10), QPoint(17, 10)});
        game.direction() = QPoint(1, 0);

        game.forceUpdate();
        const QPoint head = game.snakeModelPtr()->body().front();
        QCOMPARE(head, QPoint(0, 10));
    }

    
};

QTEST_MAIN(TestGameLogic)
#include "test_game_logic.moc"
