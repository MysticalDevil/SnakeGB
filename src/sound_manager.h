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

    /** 优化后的 8-bit 动感旋律 (频率, 持续时间Ms) */
    const std::vector<std::pair<int, int>> m_melody = {
        // 第一小节：主动机
        {440, 150}, {0, 50}, {440, 150}, {659, 100}, {0, 50}, {587, 150}, {0, 50},
        // 第二小节：切分感
        {523, 100}, {587, 100}, {659, 200}, {440, 200}, {392, 200},
        // 第三小节：快速琶音模拟
        {440, 80}, {523, 80}, {659, 80}, {880, 160}, {0, 100},
        // 第四小节：回落
        {784, 150}, {659, 150}, {523, 150}, {493, 300}, {0, 200}
    };
};
