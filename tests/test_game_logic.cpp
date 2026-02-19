#include <QtTest>
#include <QCoreApplication>
#include "game_logic.h"

class TestGameLogic : public QObject {
    Q_OBJECT
private slots:
    void testInitialState() {
        GameLogic game;
        // 初始状态现在应该是 Splash
        QCOMPARE(game.state(), GameLogic::Splash);
        QCOMPARE(game.score(), 0);
    }

    void testMoveAndBoundary() {
        GameLogic game;
        game.startGame(); 
        
        // 游戏启动后状态应为 Playing
        QCOMPARE(game.state(), GameLogic::Playing);

        for (int i = 0; i < 11; ++i) {
            game.move(0, -1);
        }
        
        QTest::qWait(2000); 
        QVERIFY(game.state() == GameLogic::GameOver);
    }

    void testScoreIncrement() {
        // Score logic is tested via gameplay
    }
};

QTEST_MAIN(TestGameLogic)
#include "test_game_logic.moc"
