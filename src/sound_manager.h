#pragma once

#include <QAudioFormat>
#include <QAudioSink>
#include <QBuffer>
#include <QMediaDevices>
#include <QObject>
#include <QTimer>
#include <vector>
#include <memory>

/**
 * @class SoundManager
 * @brief 多通道 8-bit 音频管理器，支持 BGM 和 SFX 同时播放。
 */
class SoundManager final : public QObject {
    Q_OBJECT
public:
    explicit SoundManager(QObject *parent = nullptr);
    ~SoundManager() override;

    Q_INVOKABLE void playBeep(int frequencyHz, int durationMs);
    Q_INVOKABLE void playCrash(int durationMs);
    Q_INVOKABLE void startMusic();
    Q_INVOKABLE void stopMusic();

private:
    void generateSquareWave(int frequencyHz, int durationMs, QByteArray &buffer);
    void generateNoise(int durationMs, QByteArray &buffer);
    void playNextNote();

    QAudioFormat m_format;
    
    // SFX Channel
    QAudioSink *m_sfxSink = nullptr;
    QBuffer m_sfxBuffer;

    // BGM Channel
    QAudioSink *m_bgmSink = nullptr;
    QBuffer m_bgmBuffer;
    
    QTimer m_musicTimer;
    int m_noteIndex = 0;
    const std::vector<std::pair<int, int>> m_melody = {
        {440, 200}, {0, 50}, {440, 200}, {0, 50}, {523, 200}, {0, 50}, {659, 400}, {0, 100},
        {587, 200}, {0, 50}, {523, 200}, {0, 50}, {493, 400}, {0, 100}
    };
};
