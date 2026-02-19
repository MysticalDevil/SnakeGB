#pragma once

#include <QObject>
#include <QAudioSink>
#include <QMediaDevices>
#include <QAudioFormat>
#include <QBuffer>
#include <QThread>

/**
 * @class SoundManager
 * @brief Manages 8-bit style sound effects using procedurally generated PCM data.
 */
class SoundManager : public QObject {
    Q_OBJECT
public:
    explicit SoundManager(QObject *parent = nullptr);
    ~SoundManager() override;

    /**
     * @brief Play a square wave beep.
     * @param frequency Frequency in Hz.
     * @param duration Duration in milliseconds.
     */
    Q_INVOKABLE void playBeep(int frequency, int duration);

    /**
     * @brief Play a noise sound (for crash/game over).
     * @param duration Duration in milliseconds.
     */
    Q_INVOKABLE void playCrash(int duration);

private:
    void generateSquareWave(int frequency, int duration, QByteArray &buffer);
    void generateNoise(int duration, QByteArray &buffer);

    QAudioFormat m_format;
    QAudioSink *m_audioSink = nullptr;
    QIODevice *m_audioIO = nullptr;
    QBuffer m_buffer;
};
