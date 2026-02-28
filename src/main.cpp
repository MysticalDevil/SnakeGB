#include <QGuiApplication>
#include <QIcon>
#include <QLocale>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <qqml.h>
#include <QQuickWindow>
#include <QDebug>
#include <QTranslator>
#include <QTimer>
#include <cstdio>
#include <cstdlib>

#include "app_state.h"
#include "adapter/engine_adapter.h"
#include "adapter/selection_view_model.h"
#include "adapter/session_status_view_model.h"
#include "adapter/theme_view_model.h"
#include "input_injection_pipe.h"
#include "power_up_id.h"
#include "sound_manager.h"

namespace {
auto releaseLogFilter(QtMsgType type, const QMessageLogContext &logContext, const QString &msg) -> void {
    Q_UNUSED(logContext);
    Q_UNUSED(msg);
    if (type == QtFatalMsg) {
        abort();
    }
}

void silenceStderrForRelease() {
#ifdef _WIN32
    if (freopen("NUL", "w", stderr) == nullptr) { // NOLINT(cppcoreguidelines-owning-memory)
        return;
    }
#else
    if (freopen("/dev/null", "w", stderr) == nullptr) { // NOLINT(cppcoreguidelines-owning-memory)
        return;
    }
#endif
}
}

auto main(int argc, char *argv[]) -> int {
#if defined(QT_NO_DEBUG_OUTPUT) && defined(QT_NO_INFO_OUTPUT) && defined(QT_NO_WARNING_OUTPUT)
    const bool keepStderr = qEnvironmentVariableIntValue("SNAKEGB_KEEP_STDERR") == 1;
    if (!keepStderr) {
        silenceStderrForRelease();
        qInstallMessageHandler(releaseLogFilter);
    }
#endif

    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationName("DevilOrg");
    QCoreApplication::setOrganizationDomain("org.devil");
    QCoreApplication::setApplicationName("SnakeGB");
    QGuiApplication::setApplicationDisplayName("Snake GameBoy Edition");
    QGuiApplication::setApplicationVersion("1.4.6");

#ifndef QT_NO_INFO_OUTPUT
    qInfo().noquote() << "[BuildMode] Debug logging enabled";
#endif

    EngineAdapter engineAdapter;
    SelectionViewModel selectionViewModel(&engineAdapter);
    SessionStatusViewModel sessionStatusViewModel(&engineAdapter);
    ThemeViewModel themeViewModel(&engineAdapter);
    SoundManager soundManager;
    InputInjectionPipe inputInjectionPipe;
    soundManager.setVolume(engineAdapter.volume());

    QObject::connect(&engineAdapter, &EngineAdapter::audioPlayBeep, &soundManager, &SoundManager::playBeep);
    QObject::connect(&engineAdapter, &EngineAdapter::audioPlayCrash, &soundManager, &SoundManager::playCrash);
    QObject::connect(&engineAdapter, &EngineAdapter::audioStartMusic, &soundManager, &SoundManager::startMusic);
    QObject::connect(&engineAdapter, &EngineAdapter::audioStopMusic, &soundManager, &SoundManager::stopMusic);
    QObject::connect(&engineAdapter, &EngineAdapter::audioSetPaused, &soundManager, &SoundManager::setPaused);
    QObject::connect(&engineAdapter, &EngineAdapter::audioSetMusicEnabled, &soundManager, &SoundManager::setMusicEnabled);
    QObject::connect(&engineAdapter, &EngineAdapter::audioSetVolume, &soundManager, &SoundManager::setVolume);
    QObject::connect(&engineAdapter, &EngineAdapter::audioSetScore, &soundManager, &SoundManager::setScore);

    QQmlApplicationEngine engine;
    qmlRegisterUncreatableType<AppState>("SnakeGB", 1, 0, "AppState",
                                         "AppState is an enum container and cannot be instantiated");
    qmlRegisterUncreatableType<PowerUpId>("SnakeGB", 1, 0, "PowerUpId",
                                          "PowerUpId is an enum container and cannot be instantiated");
    engine.rootContext()->setContextProperty("engineAdapter", &engineAdapter);
    engine.rootContext()->setContextProperty("selectionViewModel", &selectionViewModel);
    engine.rootContext()->setContextProperty("sessionStatusViewModel", &sessionStatusViewModel);
    engine.rootContext()->setContextProperty("themeViewModel", &themeViewModel);
    engine.rootContext()->setContextProperty("inputInjector", &inputInjectionPipe);

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
    QTimer::singleShot(200, &engineAdapter, &EngineAdapter::lazyInitState);

    return QGuiApplication::exec();
}
