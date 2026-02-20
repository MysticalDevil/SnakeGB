#pragma once

#include <QAudioFormat>
#include <QAudioSink>
#include <QByteArray>
#include <QBuffer>
#include <QObject>
#include <QTimer>
#include <vector>

class SoundManager final : public QObject {
    Q_OBJECT
public:
    explicit SoundManager(QObject *parent = nullptr);
    ~SoundManager() override;

    SoundManager(const SoundManager &) = delete;
    auto operator=(const SoundManager &) -> SoundManager & = delete;
    SoundManager(SoundManager &&) = delete;
    auto operator=(SoundManager &&) -> SoundManager & = delete;

    auto setMusicEnabled(bool enabled) -> void;
    auto setPaused(bool paused) -> void;
    // Updated: playBeep now accepts panning (-1.0 left to 1.0 right)
    Q_INVOKABLE void playBeep(int frequencyHz, int durationMs, float pan = 0.0f);
    Q_INVOKABLE void playCrash(int durationMs);
    Q_INVOKABLE void startMusic();
    Q_INVOKABLE void stopMusic();
    [[nodiscard]] auto musicEnabled() const -> bool { return m_musicEnabled; }

    void setVolume(float volume);
    [[nodiscard]] auto volume() const -> float { return m_volume; }

    void initAudioAsync();
    void setScore(int score);

private slots:
    void playNextNote();

private:
    // Updated: generate functions now output Stereo (L/R interleaved)
    void generateSquareWave(int frequencyHz, int durationMs, QByteArray &buffer, int amplitude = 32, double duty = 0.25, float pan = 0.0f);
    void applyLowPassFilter(QByteArray &buffer);
    void applyReverb(QByteArray &buffer); // New: Dynamic Reverb
    void generateNoise(int durationMs, QByteArray &buffer);

    QAudioFormat m_format;
    QAudioSink *m_sfxSink = nullptr;
    QAudioSink *m_bgmLeadSink = nullptr;
    QAudioSink *m_bgmBassSink = nullptr;
    
    QBuffer m_sfxBuffer;
    QBuffer m_bgmLeadBuffer;
    QBuffer m_bgmBassBuffer;
    
    QTimer m_musicTimer;
    bool m_musicEnabled = true;
    bool m_isPaused = false;
    float m_volume = 1.0f;
    int m_noteIndex = 0;
    int m_currentScore = 0;

    // Filter state
    double m_lpfAlpha = 0.15;
    double m_lastLeadSample = 128.0;
    double m_lastBassSample = 128.0;
    
    // Reverb state (Delay Line)
    std::vector<double> m_reverbBuffer;
    int m_reverbWriteHead = 0;

    struct NotePair {
        int leadFreq;
        int bassFreq;
        int duration;
    };

    const std::vector<NotePair> m_richMelody = {
        {440, 220, 300}, {494, 247, 300}, {523, 261, 300}, {587, 293, 300},
        {659, 329, 600}, {587, 293, 600}, {523, 261, 300}, {494, 247, 300},
        {440, 220, 600}, {0, 0, 300},
        {330, 165, 300}, {392, 196, 300}, {440, 220, 600}, {392, 196, 300},
        {330, 165, 300}, {293, 146, 600},
        {440, 220, 300}, {494, 247, 300}, {523, 261, 300}, {587, 293, 300},
        {659, 329, 600}, {784, 392, 600}, {880, 440, 600}, {784, 392, 300},
        {659, 329, 300}, {587, 293, 600}
    };
};
