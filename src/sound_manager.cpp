#include "sound_manager.h"
#include <QAudioDevice>
#include <QDebug>
#include <QMediaDevices>
#include <QRandomGenerator>
#include <QtMath>

namespace {
    constexpr int SampleRate = 44100;
    constexpr int DefaultAmplitude = 32;
    constexpr int BGM_Amplitude = 10;
    constexpr int Noise_Amplitude = 20;
    constexpr double DutyCycle = 0.25;
    constexpr int AttackMs = 5;
}

SoundManager::SoundManager(QObject *parent) : QObject(parent) {
    m_format.setSampleRate(SampleRate);
    m_format.setChannelCount(1);
    m_format.setSampleFormat(QAudioFormat::UInt8);

    const auto device = QMediaDevices::defaultAudioOutput();
    if (!device.isNull()) {
        m_sfxSink = new QAudioSink(device, m_format, this);
        m_sfxBuffer.open(QIODevice::ReadWrite);
        m_bgmSink = new QAudioSink(device, m_format, this);
        m_bgmBuffer.open(QIODevice::ReadWrite);
    }

    connect(&m_musicTimer, &QTimer::timeout, this, &SoundManager::playNextNote);
}

SoundManager::~SoundManager() {
    if (m_sfxSink) { m_sfxSink->stop(); }
    if (m_bgmSink) { m_bgmSink->stop(); }
}

auto SoundManager::setMusicEnabled(bool enabled) -> void {
    m_musicEnabled = enabled;
    if (!m_musicEnabled) {
        stopMusic();
    }
}

auto SoundManager::playBeep(const int frequencyHz, const int durationMs) -> void {
    if (!m_sfxSink) {
        return;
    }
    QByteArray data;
    generateSquareWave(frequencyHz, durationMs, data, DefaultAmplitude);
    m_sfxSink->stop();
    m_sfxBuffer.close();
    m_sfxBuffer.setData(data);
    m_sfxBuffer.open(QIODevice::ReadOnly);
    m_sfxSink->start(&m_sfxBuffer);
}

auto SoundManager::playCrash(const int durationMs) -> void {
    if (!m_sfxSink) {
        return;
    }
    QByteArray data;
    generateNoise(durationMs, data);
    m_sfxSink->stop();
    m_sfxBuffer.close();
    m_sfxBuffer.setData(data);
    m_sfxBuffer.open(QIODevice::ReadOnly);
    m_sfxSink->start(&m_sfxBuffer);
}

auto SoundManager::startMusic() -> void {
    if (!m_musicEnabled) {
        return;
    }
    m_noteIndex = 0;
    playNextNote();
}

auto SoundManager::stopMusic() -> void {
    m_musicTimer.stop();
    if (m_bgmSink) {
        m_bgmSink->stop();
    }
}

auto SoundManager::playNextNote() -> void {
    if (!m_bgmSink || !m_musicEnabled) {
        return;
    }
    if (m_noteIndex >= static_cast<int>(m_melody.size())) {
        m_noteIndex = 0;
    }

    auto [freq, duration] = m_melody[m_noteIndex];
    m_noteIndex++;

    if (freq > 0) {
        QByteArray data;
        generateSquareWave(freq, duration - 10, data, BGM_Amplitude); 
        m_bgmSink->stop();
        m_bgmBuffer.close();
        m_bgmBuffer.setData(data);
        m_bgmBuffer.open(QIODevice::ReadOnly);
        m_bgmSink->start(&m_bgmBuffer);
    }
    m_musicTimer.start(duration);
}

auto SoundManager::generateSquareWave(const int frequencyHz, const int durationMs, QByteArray &buffer, int amplitude) -> void {
    const int sampleRate = m_format.sampleRate();
    const int sampleCount = (sampleRate * durationMs) / 1000;
    if (sampleCount <= 0) {
        return;
    }
    buffer.resize(sampleCount);

    const double cycleLength = static_cast<double>(sampleRate) / frequencyHz;
    const int attackSamples = (sampleRate * AttackMs) / 1000;

    for (int i = 0; i < sampleCount; ++i) {
        const double phase = fmod(i, cycleLength) / cycleLength;
        double envelope = 1.0;
        if (i < attackSamples) {
            envelope = static_cast<double>(i) / attackSamples;
        } else {
            envelope = 1.0 - (static_cast<double>(i - attackSamples) / (sampleCount - attackSamples));
        }
        
        const int val = (phase < DutyCycle) ? (128 + amplitude) : (128 - amplitude);
        buffer[i] = static_cast<char>(128 + (val - 128) * envelope);
    }
}

auto SoundManager::generateNoise(const int durationMs, QByteArray &buffer) -> void {
    const int sampleRate = m_format.sampleRate();
    const int sampleCount = (sampleRate * durationMs) / 1000;
    if (sampleCount <= 0) {
        return;
    }
    buffer.resize(sampleCount);
    for (int i = 0; i < sampleCount; ++i) {
        const double envelope = 1.0 - (static_cast<double>(i) / sampleCount);
        const int randVal = QRandomGenerator::global()->bounded(Noise_Amplitude * 2) - Noise_Amplitude;
        buffer[i] = static_cast<char>(128 + randVal * envelope);
    }
}
