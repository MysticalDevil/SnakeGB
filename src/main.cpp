#include <QGuiApplication>
#include <QIcon>
#include <QLocale>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QTranslator>
#include <QTimer>

#include "game_logic.h"
#include "sound_manager.h"

auto main(int argc, char *argv[]) -> int {
    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationName("DevilOrg");
    QCoreApplication::setOrganizationDomain("org.devil");
    QCoreApplication::setApplicationName("SnakeGB");
    QGuiApplication::setApplicationDisplayName("Snake GameBoy Edition");
    QGuiApplication::setApplicationVersion("1.4.0");

    GameLogic gameLogic;
    SoundManager soundManager;
    soundManager.setVolume(gameLogic.volume());

    QObject::connect(&gameLogic, &GameLogic::audioPlayBeep, &soundManager, &SoundManager::playBeep);
    QObject::connect(&gameLogic, &GameLogic::audioPlayCrash, &soundManager, &SoundManager::playCrash);
    QObject::connect(&gameLogic, &GameLogic::audioStartMusic, &soundManager, &SoundManager::startMusic);
    QObject::connect(&gameLogic, &GameLogic::audioStopMusic, &soundManager, &SoundManager::stopMusic);
    QObject::connect(&gameLogic, &GameLogic::audioSetPaused, &soundManager, &SoundManager::setPaused);
    QObject::connect(&gameLogic, &GameLogic::audioSetMusicEnabled, &soundManager, &SoundManager::setMusicEnabled);
    QObject::connect(&gameLogic, &GameLogic::audioSetVolume, &soundManager, &SoundManager::setVolume);
    QObject::connect(&gameLogic, &GameLogic::audioSetScore, &soundManager, &SoundManager::setScore);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("gameLogic", &gameLogic);

    using namespace Qt::StringLiterals;
    const QUrl url(u"qrc:/src/qml/main.qml"_s);

    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, &app,
        [url](QObject *obj, const QUrl &objUrl) -> void {
            if (!obj && url == objUrl) {
                QCoreApplication::exit(-1);
            }
        },
        Qt::QueuedConnection);

    engine.load(url);
    
    // Safety delay for FSM to ensure QML engine is steady
    QTimer::singleShot(200, &gameLogic, &GameLogic::lazyInitState);

    return QGuiApplication::exec();
}
