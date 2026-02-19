#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "game_logic.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    GameLogic gameLogic;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("gameLogic", &gameLogic);

    using namespace Qt::StringLiterals;
    const QUrl url(u"qrc:/main.qml"_s);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
