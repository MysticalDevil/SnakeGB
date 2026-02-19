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
 * @brief Multi-channel 8-bit audio manager supporting simultaneous BGM and SFX.
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
    
    void setMusicEnabled(bool enabled);
    [[nodiscard]] bool musicEnabled() const { return m_musicEnabled; }

private:
    void generateSquareWave(int frequencyHz, int durationMs, QByteArray &buffer, int amplitude = 32);
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
    bool m_musicEnabled = true;

    /** 
     * Structured 8-bit melody (A-B sections)
     * Beat unit: 300ms
     */
    const std::vector<std::pair<int, int>> m_melody = {
        // --- Section A: Steady Theme (16 beats) ---
        {440, 300}, {0, 300},   {523, 300}, {0, 300},   // A ... C
        {493, 300}, {0, 300},   {440, 600},             // B ... A_
        {349, 300}, {392, 300}, {440, 300}, {330, 300}, // F . G . A . E
        {349, 300}, {330, 300}, {293, 600},             // F . E . D_

        // --- Section B: Energetic Variation (16 beats) ---
        {440, 150}, {523, 150}, {659, 300}, {0, 300},   // A-C E ...
        {587, 150}, {523, 150}, {493, 300}, {0, 300},   // D-C B ...
        {349, 300}, {440, 300}, {523, 300}, {659, 300}, // F . A . C . E
        {587, 300}, {493, 300}, {440, 600}              // D . B . A_
    };
};
