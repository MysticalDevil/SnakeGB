#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "game_logic.h"

auto main(int argc, char *argv[]) -> int {
    QGuiApplication app(argc, argv);

    // 设置应用元数据
    app.setApplicationName("SnakeGB");
    app.setApplicationDisplayName("Snake GameBoy Edition");
    app.setApplicationVersion("1.0.0");
    app.setWindowIcon(QIcon(":/icon.svg"));

    GameLogic gameLogic;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("gameLogic", &gameLogic);

    using namespace Qt::StringLiterals;
    const QUrl url(u"qrc:/main.qml"_s);

    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, &app,
        [url](QObject *obj, const QUrl &objUrl) -> void {
            if (!obj && url == objUrl) {
                QCoreApplication::exit(-1);
            }
        },
        Qt::QueuedConnection);

    engine.load(url);

    return QGuiApplication::exec();
}
