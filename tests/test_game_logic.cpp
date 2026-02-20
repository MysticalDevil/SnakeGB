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
        game.startGame(); 
        
        // Wait for Splash to end and Playing to start
        QTest::qWait(500);

        QCOMPARE(static_cast<int>(game.state()), static_cast<int>(GameLogic::Playing));

        // Initial head is at 10,10. Move Up (0, -1). 
        // Need 11 steps to hit boundary y < 0.
        // Current interval is 200ms.
        for (int i = 0; i < 40; ++i) {
            game.move(0, -1);
            QTest::qWait(150); // Sufficient steps and time to reach boundary
        }
        
        // Use verify with timeout to be robust
        QTRY_COMPARE_WITH_TIMEOUT(static_cast<int>(game.state()), static_cast<int>(GameLogic::GameOver), 5000);
    }
};

QTEST_MAIN(TestGameLogic)
#include "test_game_logic.moc"
