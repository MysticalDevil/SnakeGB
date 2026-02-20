#include "sound_manager.h"
#include <QAudioDevice>
#include <QMediaDevices>
#include <QRandomGenerator>
#include <QtMath>
#include <QTimer>

namespace {
    constexpr int SampleRate = 44100;
    constexpr int DefaultAmplitude = 32;
    constexpr int Lead_Amplitude = 12;
    constexpr int Bass_Amplitude = 8;
    constexpr int Noise_Amplitude = 20;
    constexpr int AttackMs = 5;
    constexpr int CenterVal = 128;
    constexpr int DeferMs = 100;
}

SoundManager::SoundManager(QObject *parent) : QObject(parent) {
    m_format.setSampleRate(SampleRate);
    m_format.setChannelCount(1);
    m_format.setSampleFormat(QAudioFormat::UInt8);

    m_sfxBuffer.open(QIODevice::ReadWrite);
    m_bgmLeadBuffer.open(QIODevice::ReadWrite);
    m_bgmBassBuffer.open(QIODevice::ReadWrite);

    connect(&m_musicTimer, &QTimer::timeout, this, &SoundManager::playNextNote);
    QTimer::singleShot(DeferMs, this, &SoundManager::initAudioAsync);
}

void SoundManager::initAudioAsync() {
    const auto device = QMediaDevices::defaultAudioOutput();
    if (!device.isNull()) {
        m_sfxSink = new QAudioSink(device, m_format, this);
        m_bgmLeadSink = new QAudioSink(device, m_format, this);
        m_bgmBassSink = new QAudioSink(device, m_format, this);
        m_sfxSink->setVolume(m_volume);
        m_bgmLeadSink->setVolume(m_volume);
        m_bgmBassSink->setVolume(m_volume);
    }
}

SoundManager::~SoundManager() {
    if (m_sfxSink) m_sfxSink->stop();
    if (m_bgmLeadSink) m_bgmLeadSink->stop();
    if (m_bgmBassSink) m_bgmBassSink->stop();
}

void SoundManager::setScore(int score) { m_currentScore = score; }

void SoundManager::setVolume(float volume) {
    m_volume = std::clamp(volume, 0.0f, 1.0f);
    if (m_sfxSink) m_sfxSink->setVolume(m_volume);
    if (m_bgmLeadSink) m_bgmLeadSink->setVolume(m_volume);
    if (m_bgmBassSink) m_bgmBassSink->setVolume(m_volume);
}

auto SoundManager::setPaused(bool paused) -> void {
    m_isPaused = paused;
    // When resuming, restart timer immediately to avoid silence
    if (!m_isPaused && m_musicEnabled && !m_musicTimer.isActive()) {
        startMusic();
    }
}

auto SoundManager::setMusicEnabled(bool enabled) -> void {
    m_musicEnabled = enabled;
    if (!m_musicEnabled) stopMusic();
}

auto SoundManager::playBeep(const int frequencyHz, const int durationMs) -> void {
    if (!m_sfxSink) return;
    QByteArray data;
    generateSquareWave(frequencyHz, durationMs, data, DefaultAmplitude, 0.5);
    m_sfxSink->stop();
    m_sfxBuffer.close();
    m_sfxBuffer.setData(data);
    if (m_sfxBuffer.open(QIODevice::ReadOnly)) m_sfxSink->start(&m_sfxBuffer);
}

auto SoundManager::playCrash(const int durationMs) -> void {
    if (!m_sfxSink) return;
    QByteArray data;
    generateNoise(durationMs, data);
    m_sfxSink->stop();
    m_sfxBuffer.close();
    m_sfxBuffer.setData(data);
    if (m_sfxBuffer.open(QIODevice::ReadOnly)) m_sfxSink->start(&m_sfxBuffer);
}

auto SoundManager::startMusic() -> void {
    if (!m_musicEnabled) return;
    m_noteIndex = 0;
    playNextNote();
}

auto SoundManager::stopMusic() -> void {
    m_musicTimer.stop();
    if (m_bgmLeadSink) m_bgmLeadSink->stop();
    if (m_bgmBassSink) m_bgmBassSink->stop();
}

auto SoundManager::playNextNote() -> void {
    if (!m_bgmLeadSink || !m_musicEnabled) return;
    if (m_noteIndex >= static_cast<int>(m_richMelody.size())) m_noteIndex = 0;

    const auto [leadFreq, bassFreq, duration] = m_richMelody[m_noteIndex];
    m_noteIndex++;

    double tempoScale = std::max(0.6, 1.0 - (m_currentScore / 5) * 0.05);
    int scaledDuration = static_cast<int>(duration * tempoScale);

    if (leadFreq > 0) {
        QByteArray leadData;
        generateSquareWave(leadFreq, scaledDuration - 5, leadData, Lead_Amplitude, 0.25);
        if (m_isPaused) applyLowPassFilter(leadData); // Apply Muffle effect
        m_bgmLeadSink->stop();
        m_bgmLeadBuffer.close();
        m_bgmLeadBuffer.setData(leadData);
        if (m_bgmLeadBuffer.open(QIODevice::ReadOnly)) m_bgmLeadSink->start(&m_bgmLeadBuffer);
    }

    if (bassFreq > 0) {
        QByteArray bassData;
        generateSquareWave(bassFreq, scaledDuration - 5, bassData, Bass_Amplitude, 0.5);
        if (m_isPaused) applyLowPassFilter(bassData);
        m_bgmBassSink->stop();
        m_bgmBassBuffer.close();
        m_bgmBassBuffer.setData(bassData);
        if (m_bgmBassBuffer.open(QIODevice::ReadOnly)) m_bgmBassSink->start(&m_bgmBassBuffer);
    }

    m_musicTimer.start(scaledDuration);
}

auto SoundManager::generateSquareWave(const int frequencyHz, const int durationMs, QByteArray &buffer, int amplitude, double duty) -> void {
    const int sampleRate = m_format.sampleRate();
    if (sampleRate <= 0) return;
    const int sampleCount = (sampleRate * durationMs) / 1000;
    if (sampleCount <= 0) return;
    buffer.resize(sampleCount);
    const double cycleLength = static_cast<double>(sampleRate) / frequencyHz;
    const int attackSamples = (sampleRate * AttackMs) / 1000;
    for (int i = 0; i < sampleCount; ++i) {
        const double phase = fmod(i, cycleLength) / cycleLength;
        double envelope = (i < attackSamples) ? (static_cast<double>(i) / attackSamples) : (1.0 - (static_cast<double>(i - attackSamples) / (sampleCount - attackSamples)));
        const int val = (phase < duty) ? (CenterVal + amplitude) : (CenterVal - amplitude);
        buffer[i] = static_cast<char>(CenterVal + (val - CenterVal) * envelope);
    }
}

// Simple Single-pole IIR Low-Pass Filter
void SoundManager::applyLowPassFilter(QByteArray &buffer) {
    double lastVal = 128.0;
    for (int i = 0; i < buffer.size(); ++i) {
        double current = static_cast<unsigned char>(buffer[i]);
        // y[i] = y[i-1] + alpha * (x[i] - y[i-1])
        double filtered = lastVal + m_lpfAlpha * (current - lastVal);
        buffer[i] = static_cast<char>(static_cast<unsigned char>(filtered));
        lastVal = filtered;
    }
}

void SoundManager::generateNoise(const int durationMs, QByteArray &buffer) {
    const int sampleRate = m_format.sampleRate();
    if (sampleRate <= 0) return;
    const int sampleCount = (sampleRate * durationMs) / 1000;
    if (sampleCount <= 0) return;
    buffer.resize(sampleCount);
    for (int i = 0; i < sampleCount; ++i) {
        const double envelope = 1.0 - (static_cast<double>(i) / sampleCount);
        const int randVal = QRandomGenerator::global()->bounded(Noise_Amplitude * 2) - Noise_Amplitude;
        buffer[i] = static_cast<char>(CenterVal + randVal * envelope);
    }
}
