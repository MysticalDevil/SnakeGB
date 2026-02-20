#include "sound_manager.h"
#include <QAudioDevice>
#include <QMediaDevices>
#include <QRandomGenerator>
#include <QtMath>
#include <QTimer>

namespace {
    constexpr int SampleRate = 44100;
    constexpr int DefaultAmplitude = 32;
    constexpr int BGM_Amplitude = 10;
    constexpr int Noise_Amplitude = 20;
    constexpr double DutyCycle = 0.25;
    constexpr int AttackMs = 5;
    constexpr int CenterVal = 128;
    constexpr int DeferMs = 100;
}

SoundManager::SoundManager(QObject *parent) : QObject(parent) {
    m_format.setSampleRate(SampleRate);
    m_format.setChannelCount(1);
    m_format.setSampleFormat(QAudioFormat::UInt8);

    const bool openedSfx = m_sfxBuffer.open(QIODevice::ReadWrite);
    const bool openedBgm = m_bgmBuffer.open(QIODevice::ReadWrite);
    (void)openedSfx; (void)openedBgm;

    connect(&m_musicTimer, &QTimer::timeout, this, &SoundManager::playNextNote);
    QTimer::singleShot(DeferMs, this, &SoundManager::initAudioAsync);
}

void SoundManager::initAudioAsync() {
    const auto device = QMediaDevices::defaultAudioOutput();
    if (!device.isNull()) {
        m_sfxSink = new QAudioSink(device, m_format, this);
        m_bgmSink = new QAudioSink(device, m_format, this);
        m_sfxSink->setVolume(m_volume);
        m_bgmSink->setVolume(m_volume);
    }
}

SoundManager::~SoundManager() {
    if (m_sfxSink) { m_sfxSink->stop(); }
    if (m_bgmSink) { m_bgmSink->stop(); }
}

void SoundManager::setScore(int score) {
    m_currentScore = score;
}

void SoundManager::setVolume(float volume) {
    m_volume = std::clamp(volume, 0.0f, 1.0f);
    if (m_sfxSink) m_sfxSink->setVolume(static_cast<qreal>(m_volume));
    if (m_bgmSink) m_bgmSink->setVolume(static_cast<qreal>(m_volume));
}

auto SoundManager::setMusicEnabled(bool enabled) -> void {
    m_musicEnabled = enabled;
    if (!m_musicEnabled) {
        stopMusic();
    }
}

auto SoundManager::playBeep(const int frequencyHz, const int durationMs) -> void {
    if (!m_sfxSink) return;
    QByteArray data;
    generateSquareWave(frequencyHz, durationMs, data, DefaultAmplitude);
    m_sfxSink->stop();
    m_sfxBuffer.close();
    m_sfxBuffer.setData(data);
    if (m_sfxBuffer.open(QIODevice::ReadOnly)) {
        m_sfxSink->start(&m_sfxBuffer);
    }
}

auto SoundManager::playCrash(const int durationMs) -> void {
    if (!m_sfxSink) return;
    QByteArray data;
    generateNoise(durationMs, data);
    m_sfxSink->stop();
    m_sfxBuffer.close();
    m_sfxBuffer.setData(data);
    if (m_sfxBuffer.open(QIODevice::ReadOnly)) {
        m_sfxSink->start(&m_sfxBuffer);
    }
}

auto SoundManager::startMusic() -> void {
    if (!m_musicEnabled) return;
    m_noteIndex = 0;
    playNextNote();
}

auto SoundManager::stopMusic() -> void {
    m_musicTimer.stop();
    if (m_bgmSink) m_bgmSink->stop();
}

auto SoundManager::playNextNote() -> void {
    if (!m_bgmSink || !m_musicEnabled) return;
    if (m_noteIndex >= static_cast<int>(m_melody.size())) m_noteIndex = 0;

    const auto [freq, duration] = m_melody[m_noteIndex];
    m_noteIndex++;

    double tempoScale = std::max(0.6, 1.0 - (m_currentScore / 5) * 0.05);
    int scaledDuration = static_cast<int>(duration * tempoScale);

    if (freq > 0) {
        QByteArray data;
        generateSquareWave(freq, scaledDuration - 5, data, BGM_Amplitude); 
        m_bgmSink->stop();
        m_bgmBuffer.close();
        m_bgmBuffer.setData(data);
        if (m_bgmBuffer.open(QIODevice::ReadOnly)) {
            m_bgmSink->start(&m_bgmBuffer);
        }
    }
    m_musicTimer.start(scaledDuration);
}

auto SoundManager::generateSquareWave(const int frequencyHz, const int durationMs, QByteArray &buffer, int amplitude) -> void {
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
        const int val = (phase < DutyCycle) ? (CenterVal + amplitude) : (CenterVal - amplitude);
        buffer[i] = static_cast<char>(CenterVal + (val - CenterVal) * envelope);
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
