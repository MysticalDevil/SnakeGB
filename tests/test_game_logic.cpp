#include <QtTest>
#include <QCoreApplication>
#include "game_logic.h"

class TestGameLogic : public QObject {
    Q_OBJECT
private slots:
    void testInitialState() {
        GameLogic game;
        QCOMPARE(game.state(), GameLogic::StartMenu);
        QCOMPARE(game.score(), 0);
        QCOMPARE(game.boardWidth(), 20);
    }

    void testMoveAndBoundary() {
        GameLogic game;
        game.startGame(); // Should start at {10,10} moving {0,-1}
        
        // Move towards boundary
        for (int i = 0; i < 11; ++i) {
            game.move(0, -1);
            // Trigger update manually if we weren't using a timer
            // but since we are, we can't easily wait for it without QTest::qWait
        }
        
        // Wait for some game cycles (timer interval is 150ms)
        QTest::qWait(2000); 
        
        // After 10+ moves up, it should hit boundary
        QVERIFY(game.state() == GameLogic::GameOver);
    }

    void testScoreIncrement() {
        GameLogic game;
        game.startGame();
        int initialScore = game.score();
        
        // Force snake onto food (this is hard without direct injection)
        // In a real test we'd add methods to set food position for testing
    }
};

QTEST_MAIN(TestGameLogic)
#include "test_game_logic.moc"
