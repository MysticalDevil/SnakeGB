#include <QtTest>
#include <QCoreApplication>
#include "game_logic.h"

class TestGameLogic : public QObject {
    Q_OBJECT
private slots:
    void testInitialState() {
        GameLogic game;
        int s = static_cast<int>(game.state());
        QVERIFY(s == 0 || s == 1);
        QCOMPARE(game.score(), 0);
    }

    void testMoveAndBoundary() {
        GameLogic game;
        // Skip Splash
        game.startGame(); 
        
        // Wait for lazyInit
        QTest::qWait(300);

        QCOMPARE(static_cast<int>(game.state()), static_cast<int>(GameLogic::Playing));

        // Initial head is at 10,10. Move Up (0, -1). 
        // Need ~11 steps to hit boundary y < 0.
        // Game interval is 150ms. Total wait must be > 11 * 150 = 1650ms.
        for (int i = 0; i < 30; ++i) {
            game.move(0, -1);
            QTest::qWait(100); // 30 * 100 = 3000ms total, enough for 20 steps
        }
        
        QCOMPARE(static_cast<int>(game.state()), static_cast<int>(GameLogic::GameOver));
    }
};

QTEST_MAIN(TestGameLogic)
#include "test_game_logic.moc"
