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
        qWarning() << "No default audio output device found. Sound will be disabled.";
        return;
    }

    m_audioSink = new QAudioSink(device, m_format, this);
    m_audioSink->setBufferSize(44100);
    m_buffer.open(QIODevice::ReadWrite);
}

SoundManager::~SoundManager() {
    if (m_audioSink) {
        m_audioSink->stop();
    }
}

void SoundManager::playBeep(const int frequencyHz, const int durationMs) {
    if (!m_audioSink) {
        return;
    }

    QByteArray data;
    generateSquareWave(frequencyHz, durationMs, data);

    m_audioSink->stop();
    m_buffer.close();
    m_buffer.setData(data);
    m_buffer.open(QIODevice::ReadOnly);
    m_audioSink->start(&m_buffer);
}

void SoundManager::playCrash(const int durationMs) {
    if (!m_audioSink) {
        return;
    }

    QByteArray data;
    generateNoise(durationMs, data);

    m_audioSink->stop();
    m_buffer.close();
    m_buffer.setData(data);
    m_buffer.open(QIODevice::ReadOnly);
    m_audioSink->start(&m_buffer);
}

void SoundManager::generateSquareWave(const int frequencyHz, const int durationMs,
                                      QByteArray &buffer) {
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
        const double envelope = 1.0 - (static_cast<double>(i) / sampleCount);
        const int randVal = QRandomGenerator::global()->bounded(noiseAmplitude * 2) - noiseAmplitude;
        buffer[i] = static_cast<char>(128 + randVal * envelope);
    }
}
