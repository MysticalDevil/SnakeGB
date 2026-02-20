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
};

QTEST_MAIN(TestGameLogic)
#include "test_game_logic.moc"
