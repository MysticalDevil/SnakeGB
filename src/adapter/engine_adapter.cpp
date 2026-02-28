#include "adapter/game_logic.h"

#include <QDebug>

#include "fsm/game_state.h"
#include "fsm/state_factory.h"
#include "profile_manager.h"
#ifdef SNAKEGB_HAS_SENSORS
#include <QAccelerometer>
#endif
#ifdef Q_OS_ANDROID
#include <QJniObject>
#include <QtCore/qnativeinterface.h>
#endif

#include <algorithm>

namespace
{
auto stateName(const int state) -> const char *
{
    switch (state) {
    case GameLogic::Splash:
        return "Splash";
    case GameLogic::StartMenu:
        return "StartMenu";
    case GameLogic::Playing:
        return "Playing";
    case GameLogic::Paused:
        return "Paused";
    case GameLogic::GameOver:
        return "GameOver";
    case GameLogic::Replaying:
        return "Replaying";
    case GameLogic::ChoiceSelection:
        return "ChoiceSelection";
    case GameLogic::Library:
        return "Library";
    case GameLogic::MedalRoom:
        return "MedalRoom";
    default:
        return "Unknown";
    }
}
} // namespace

GameLogic::GameLogic(QObject *parent)
    : QObject(parent), m_rng(QRandomGenerator::securelySeeded()), m_session(m_sessionCore.state()),
      m_timer(std::make_unique<QTimer>()),
#ifdef SNAKEGB_HAS_SENSORS
      m_accelerometer(std::make_unique<QAccelerometer>()),
#endif
      m_profileManager(std::make_unique<ProfileManager>()),
      m_inputQueue(m_sessionCore.inputQueue()), m_fsmState(nullptr)
{
    m_audioBus.setCallbacks({
        .startMusic = [this]() -> void { emit audioStartMusic(); },
        .stopMusic = [this]() -> void { emit audioStopMusic(); },
        .setPaused = [this](const bool paused) -> void { emit audioSetPaused(paused); },
        .setMusicEnabled = [this](const bool enabled) -> void {
            emit audioSetMusicEnabled(enabled);
        },
        .setVolume = [this](const float volume) -> void { emit audioSetVolume(volume); },
        .setScore = [this](const int score) -> void { emit audioSetScore(score); },
        .playBeep = [this](const int frequencyHz, const int durationMs, const float pan) -> void {
            emit audioPlayBeep(frequencyHz, durationMs, pan);
        },
        .playCrash = [this](const int durationMs) -> void { emit audioPlayCrash(durationMs); },
    });

    connect(m_timer.get(), &QTimer::timeout, this, &GameLogic::update);
    setupAudioSignals();
    setupSensorRuntime();
    m_snakeModel.setBodyChangedCallback(
        [this](const std::deque<QPoint> &body) { m_sessionCore.setBody(body); });

    m_sessionCore.setBody({{10, 10}, {10, 11}, {10, 12}});
    syncSnakeModelFromCore();
}

GameLogic::~GameLogic()
{
#ifdef SNAKEGB_HAS_SENSORS
    if (m_accelerometer) {
        m_accelerometer->stop();
    }
#endif
    if (m_timer) {
        m_timer->stop();
    }
    m_fsmState.reset();
}

void GameLogic::syncSnakeModelFromCore()
{
    m_snakeModel.reset(m_sessionCore.body());
}

void GameLogic::setupAudioSignals()
{
    connect(this, &GameLogic::foodEaten, this, [this](const float pan) -> void {
        m_audioBus.playFood({.score = m_session.score, .pan = pan});
        triggerHaptic(3);
    });

    connect(this, &GameLogic::powerUpEaten, this, [this]() -> void {
        m_audioBus.playPowerUp();
        triggerHaptic(6);
    });

    connect(this, &GameLogic::playerCrashed, this, [this]() -> void {
        m_audioBus.playCrash();
        triggerHaptic(12);
    });

    connect(this, &GameLogic::uiInteractTriggered, this, [this]() -> void {
        m_audioBus.playUiInteract();
        triggerHaptic(2);
    });

    connect(this, &GameLogic::stateChanged, this, [this]() -> void {
        qInfo().noquote() << "[AudioFlow][GameLogic] stateChanged ->" << stateName(m_state)
                          << "(musicEnabled=" << m_musicEnabled << ")";
        const int token = m_audioStateToken;
        m_audioBus.handleStateChanged(
            static_cast<int>(m_state), m_musicEnabled,
            [this, token](const int delayMs, const std::function<void()> &callback) -> void {
                QTimer::singleShot(delayMs, this, [this, token, callback]() -> void {
                    if (token != m_audioStateToken) {
                        qInfo().noquote()
                            << "[AudioFlow][GameLogic] menu BGM deferred start canceled by token";
                        return;
                    }
                    if (callback) {
                        callback();
                    }
                });
            });
    });
}

void GameLogic::setupSensorRuntime()
{
#ifdef SNAKEGB_HAS_SENSORS
    if (!m_accelerometer) {
        return;
    }

    m_accelerometer->setDataRate(30);
    connect(m_accelerometer.get(), &QAccelerometer::readingChanged, this, [this]() -> void {
        if (!m_accelerometer || !m_accelerometer->reading()) {
            return;
        }
        constexpr qreal maxTilt = 6.0;
        const qreal nx = std::clamp(m_accelerometer->reading()->y() / maxTilt, -1.0, 1.0);
        const qreal ny = std::clamp(m_accelerometer->reading()->x() / maxTilt, -1.0, 1.0);
        m_reflectionOffset = QPointF(nx * 0.02, -ny * 0.02);
        m_hasAccelerometerReading = true;
        emit reflectionOffsetChanged();
    });
    m_accelerometer->start();
    QTimer::singleShot(200, this, [this]() -> void {
        if (!m_accelerometer) {
            return;
        }
        qInfo().noquote() << "[SensorFlow][GameLogic] accelerometer connected="
                          << m_accelerometer->isConnectedToBackend()
                          << "active=" << m_accelerometer->isActive();
    });
#else
    m_hasAccelerometerReading = false;
#endif
}

void GameLogic::setInternalState(const int s)
{
    const auto next = static_cast<State>(s);
    if (m_state != next) {
        qInfo().noquote() << "[StateFlow][GameLogic] setInternalState:" << stateName(m_state)
                          << "->" << stateName(next);
        m_state = next;
        m_audioStateToken++;
        m_audioBus.syncPausedState(static_cast<int>(m_state));
        emit stateChanged();
    }
}

void GameLogic::requestStateChange(const int newState)
{
    if (m_stateCallbackInProgress) {
        qInfo().noquote() << "[StateFlow][GameLogic] defer requestStateChange to"
                          << stateName(newState) << "(inside callback)";
        m_pendingStateChange = newState;
        return;
    }
    qInfo().noquote() << "[StateFlow][GameLogic] requestStateChange ->" << stateName(newState);

    if (auto nextState = snakegb::fsm::createStateFor(*this, newState); nextState) {
        changeState(std::move(nextState));
    }
}

void GameLogic::startEngineTimer(const int intervalMs)
{
    if (intervalMs > 0) {
        m_timer->setInterval(intervalMs);
    }
    m_timer->start();
}

void GameLogic::stopEngineTimer()
{
    m_timer->stop();
}

void GameLogic::triggerHaptic(const int magnitude)
{
    emit requestFeedback(magnitude);
#ifdef Q_OS_ANDROID
    QJniObject context = QNativeInterface::QAndroidApplication::context();
    if (context.isValid()) {
        QJniObject vibrator =
            context.callObjectMethod("getSystemService", "(Ljava/lang/String;)Ljava/lang/Object;",
                                     QJniObject::fromString("vibrator").object<jstring>());
        if (vibrator.isValid()) {
            const jlong duration = static_cast<jlong>(magnitude * 12);
            vibrator.callMethod<void>("vibrate", "(J)V", duration);
        }
    }
#endif
}

void GameLogic::playEventSound(const int type, const float pan)
{
    qInfo().noquote() << "[AudioFlow][GameLogic] playEventSound type=" << type << " pan=" << pan;
    if (type == 0) {
        emit foodEaten(pan);
    } else if (type == 1) {
        emit playerCrashed();
    } else if (type == 2) {
        emit uiInteractTriggered();
    } else if (type == 3) {
        m_audioBus.playConfirm();
    }
}

void GameLogic::applyPendingStateChangeIfNeeded()
{
    if (!m_pendingStateChange.has_value()) {
        return;
    }
    const int pendingState = *m_pendingStateChange;
    m_pendingStateChange.reset();
    requestStateChange(pendingState);
}

void GameLogic::dispatchStateCallback(const std::function<void(GameState &)> &callback)
{
    if (!m_fsmState) {
        return;
    }
    // Defer state replacement while executing a state callback to avoid invalidating the state
    // object mid-function.
    m_stateCallbackInProgress = true;
    callback(*m_fsmState);
    m_stateCallbackInProgress = false;
    applyPendingStateChangeIfNeeded();
}

void GameLogic::changeState(std::unique_ptr<GameState> newState)
{
    if (m_fsmState) {
        m_fsmState->exit();
    }
    m_fsmState = std::move(newState);
    if (m_fsmState) {
        m_fsmState->enter();
    }
}
