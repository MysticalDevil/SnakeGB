#pragma once

#include <QAudioFormat>
#include <QAudioSink>
#include <QBuffer>
#include <QMediaDevices>
#include <QObject>
#include <QThread>
#include <QTimer>
#include <vector>

/**
 * @class SoundManager
 * @brief 使用过程生成 PCM 数据管理 8-bit 音效和 BGM。
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
    QAudioSink *m_audioSink = nullptr;
    QBuffer m_buffer;
    
    // BGM
    QTimer m_musicTimer;
    int m_noteIndex = 0;
    // Simple melody: Freq, Duration
    const std::vector<std::pair<int, int>> m_melody = {
        {440, 200}, {0, 50}, {440, 200}, {0, 50}, {523, 200}, {0, 50}, {659, 400}, {0, 100},
        {587, 200}, {0, 50}, {523, 200}, {0, 50}, {493, 400}, {0, 100}
    };
};
