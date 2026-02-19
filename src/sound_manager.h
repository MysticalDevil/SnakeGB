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
    SoundManager &operator=(const SoundManager &) = delete;
    SoundManager(SoundManager &&) = delete;
    SoundManager &operator=(SoundManager &&) = delete;

    auto setMusicEnabled(bool enabled) -> void;
    Q_INVOKABLE void playBeep(int frequencyHz, int durationMs);
    Q_INVOKABLE void playCrash(int durationMs);
    Q_INVOKABLE void startMusic();
    Q_INVOKABLE void stopMusic();
    [[nodiscard]] bool musicEnabled() const { return m_musicEnabled; }

    void initAudioAsync();
    
    // Dynamic Tempo Control
    void setScore(int score);

private slots:
    void playNextNote();

private:
    void generateSquareWave(int frequencyHz, int durationMs, QByteArray &buffer, int amplitude = 32);
    void generateNoise(int durationMs, QByteArray &buffer);

    QAudioFormat m_format;
    QAudioSink *m_sfxSink = nullptr;
    QAudioSink *m_bgmSink = nullptr;
    QBuffer m_sfxBuffer;
    QBuffer m_bgmBuffer;
    QTimer m_musicTimer;
    bool m_musicEnabled = true;
    int m_noteIndex = 0;
    int m_currentScore = 0;

    const std::vector<std::pair<int, int>> m_melody = {
        {440, 300}, {494, 300}, {523, 300}, {587, 300}, {659, 600}, {587, 600},
        {523, 300}, {494, 300}, {440, 600}, {0, 300},
        {330, 300}, {392, 300}, {440, 600}, {392, 300}, {330, 300}, {293, 600},
        {440, 300}, {494, 300}, {523, 300}, {587, 300}, {659, 600}, {784, 600},
        {880, 600}, {784, 300}, {659, 300}, {587, 600}
    };
};
