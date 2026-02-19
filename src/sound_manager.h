#pragma once

#include <QAudioFormat>
#include <QAudioSink>
#include <QBuffer>
#include <QMediaDevices>
#include <QObject>
#include <QTimer>
#include <vector>
#include <memory>

class SoundManager final : public QObject {
    Q_OBJECT
public:
    explicit SoundManager(QObject *parent = nullptr);
    ~SoundManager() override;

    Q_INVOKABLE void playBeep(int frequencyHz, int durationMs);
    Q_INVOKABLE void playCrash(int durationMs);
    Q_INVOKABLE void startMusic();
    Q_INVOKABLE void stopMusic();
    
    // 音乐开关
    void setMusicEnabled(bool enabled);
    [[nodiscard]] bool musicEnabled() const { return m_musicEnabled; }

private:
    void generateSquareWave(int frequencyHz, int durationMs, QByteArray &buffer, int amplitude = 32);
    void generateNoise(int durationMs, QByteArray &buffer);
    void playNextNote();

    QAudioFormat m_format;
    QAudioSink *m_sfxSink = nullptr;
    QBuffer m_sfxBuffer;
    QAudioSink *m_bgmSink = nullptr;
    QBuffer m_bgmBuffer;
    
    QTimer m_musicTimer;
    int m_noteIndex = 0;
    bool m_musicEnabled = true;

    // 优化：更长、更柔和的旋律
    const std::vector<std::pair<int, int>> m_melody = {
        {440, 200}, {0, 50}, {440, 200}, {0, 50}, {523, 200}, {0, 50}, {659, 400}, {0, 100},
        {587, 200}, {0, 50}, {523, 200}, {0, 50}, {493, 400}, {0, 100},
        {392, 200}, {0, 50}, {392, 200}, {0, 50}, {440, 200}, {0, 50}, {523, 400}, {0, 100},
        {493, 200}, {0, 50}, {440, 200}, {0, 50}, {392, 400}, {0, 100}
    };
};
