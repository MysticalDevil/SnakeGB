#include "sound_manager.h"
#include <QAudioDevice>
#include <QRandomGenerator>
#include <QtMath>
#include <QDebug>

SoundManager::SoundManager(QObject *parent) : QObject(parent) {
    // 8-bit Audio Format: Mono, 8-bit Unsigned, 44100 Hz
    m_format.setSampleRate(44100);
    m_format.setChannelCount(1);
    m_format.setSampleFormat(QAudioFormat::UInt8);

    auto device = QMediaDevices::defaultAudioOutput();
    if (!device.isFormatSupported(m_format)) {
        qWarning() << "Default format not supported - trying to use nearest";
        // Attempt to find a supported format if the exact one fails
    }

    m_audioSink = new QAudioSink(device, m_format, this);
    m_audioSink->setBufferSize(44100 * 2); // 2 seconds buffer
    m_buffer.open(QIODevice::ReadWrite);
}

SoundManager::~SoundManager() {
    if (m_audioSink) {
        m_audioSink->stop();
    }
}

void SoundManager::playBeep(int frequency, int duration) {
    if (!m_audioSink) return;

    QByteArray data;
    generateSquareWave(frequency, duration, data);

    m_audioSink->stop();
    m_buffer.close();
    m_buffer.setData(data);
    m_buffer.open(QIODevice::ReadOnly);
    m_audioSink->start(&m_buffer);
}

void SoundManager::playCrash(int duration) {
    if (!m_audioSink) return;

    QByteArray data;
    generateNoise(duration, data);

    m_audioSink->stop();
    m_buffer.close();
    m_buffer.setData(data);
    m_buffer.open(QIODevice::ReadOnly);
    m_audioSink->start(&m_buffer);
}

void SoundManager::generateSquareWave(int frequency, int duration, QByteArray &buffer) {
    int sampleRate = m_format.sampleRate();
    int sampleCount = (sampleRate * duration) / 1000;
    buffer.resize(sampleCount);

    double cycleLength = static_cast<double>(sampleRate) / frequency;
    
    // Simple 50% duty cycle square wave
    for (int i = 0; i < sampleCount; ++i) {
        double phase = fmod(i, cycleLength) / cycleLength;
        // 8-bit unsigned PCM: 128 is silence, 0-255 range.
        // Square wave: high (200), low (56)
        buffer[i] = (phase < 0.5) ? static_cast<char>(200) : static_cast<char>(56);
    }
}

void SoundManager::generateNoise(int duration, QByteArray &buffer) {
    int sampleRate = m_format.sampleRate();
    int sampleCount = (sampleRate * duration) / 1000;
    buffer.resize(sampleCount);

    // Simple white noise
    for (int i = 0; i < sampleCount; ++i) {
        // Random value between 0 and 255
        buffer[i] = static_cast<char>(QRandomGenerator::global()->bounded(256));
    }
}
