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

    /** 标准化的 150ms 基准旋律 (频率, 持续时间) */
    const std::vector<std::pair<int, int>> m_melody = {
        {440, 150}, {440, 150}, {523, 150}, {440, 150}, // A - A - C - A
        {392, 150}, {392, 150}, {493, 150}, {392, 150}, // G - G - B - G
        {349, 150}, {349, 150}, {440, 150}, {349, 150}, // F - F - A - F
        {330, 150}, {392, 150}, {440, 150}, {0, 150}    // E - G - A - (Rest)
    };
};
