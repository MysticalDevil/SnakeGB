#include "sound_manager.h"
#include <QAudioDevice>
#include <QDebug>
#include <QMediaDevices>
#include <QRandomGenerator>
#include <QtMath>

SoundManager::SoundManager(QObject *parent) : QObject(parent) {
    m_format.setSampleRate(44100);
    m_format.setChannelCount(1);
    m_format.setSampleFormat(QAudioFormat::UInt8);

    const auto device = QMediaDevices::defaultAudioOutput();
    if (device.isNull()) {
        qWarning() << "No default audio output device found.";
        return;
    }

    // Initialize SFX Channel
    m_sfxSink = new QAudioSink(device, m_format, this);
    m_sfxBuffer.open(QIODevice::ReadWrite);

    // Initialize BGM Channel
    m_bgmSink = new QAudioSink(device, m_format, this);
    m_bgmBuffer.open(QIODevice::ReadWrite);

    connect(&m_musicTimer, &QTimer::timeout, this, &SoundManager::playNextNote);
}

SoundManager::~SoundManager() {
    if (m_sfxSink) m_sfxSink->stop();
    if (m_bgmSink) m_bgmSink->stop();
}

void SoundManager::playBeep(const int frequencyHz, const int durationMs) {
    if (!m_sfxSink) return;

    QByteArray data;
    generateSquareWave(frequencyHz, durationMs, data);

    m_sfxSink->stop();
    m_sfxBuffer.close();
    m_sfxBuffer.setData(data);
    m_sfxBuffer.open(QIODevice::ReadOnly);
    m_sfxSink->start(&m_sfxBuffer);
}

void SoundManager::playCrash(const int durationMs) {
    if (!m_sfxSink) return;

    QByteArray data;
    generateNoise(durationMs, data);

    m_sfxSink->stop();
    m_sfxBuffer.close();
    m_sfxBuffer.setData(data);
    m_sfxBuffer.open(QIODevice::ReadOnly);
    m_sfxSink->start(&m_sfxBuffer);
}

void SoundManager::startMusic() {
    m_noteIndex = 0;
    playNextNote();
}

void SoundManager::stopMusic() {
    m_musicTimer.stop();
    if (m_bgmSink) m_bgmSink->stop();
}

void SoundManager::playNextNote() {
    if (!m_bgmSink) return;
    if (m_noteIndex >= m_melody.size()) m_noteIndex = 0;

    auto [freq, duration] = m_melody[m_noteIndex];
    m_noteIndex++;

    if (freq > 0) {
        QByteArray data;
        generateSquareWave(freq, duration, data);
        
        m_bgmSink->stop();
        m_bgmBuffer.close();
        m_bgmBuffer.setData(data);
        m_bgmBuffer.open(QIODevice::ReadOnly);
        m_bgmSink->start(&m_bgmBuffer);
    }

    m_musicTimer.start(duration + 50);
}

void SoundManager::generateSquareWave(const int frequencyHz, const int durationMs, QByteArray &buffer) {
    const int sampleRate = m_format.sampleRate();
    const int sampleCount = (sampleRate * durationMs) / 1000;
    if (sampleCount <= 0) return;
    buffer.resize(sampleCount);

    const double cycleLength = static_cast<double>(sampleRate) / frequencyHz;
    const int amplitude = 32;
    const double dutyCycle = 0.25;

    for (int i = 0; i < sampleCount; ++i) {
        const double phase = fmod(i, cycleLength) / cycleLength;
        const double envelope = 1.0 - (static_cast<double>(i) / sampleCount);
        const int val = (phase < dutyCycle) ? (128 + amplitude) : (128 - amplitude);
        buffer[i] = static_cast<char>(128 + (val - 128) * envelope);
    }
}

void SoundManager::generateNoise(const int durationMs, QByteArray &buffer) {
    const int sampleRate = m_format.sampleRate();
    const int sampleCount = (sampleRate * durationMs) / 1000;
    if (sampleCount <= 0) return;
    buffer.resize(sampleCount);

    const int noiseAmplitude = 24;
    for (int i = 0; i < sampleCount; ++i) {
        double envelope = 1.0 - (static_cast<double>(i) / sampleCount);
        int randVal = QRandomGenerator::global()->bounded(noiseAmplitude * 2) - noiseAmplitude;
        buffer[i] = static_cast<char>(128 + randVal * envelope);
    }
}
