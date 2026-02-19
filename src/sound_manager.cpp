#include "sound_manager.h"
#include <QAudioDevice>
#include <QRandomGenerator>
#include <QtMath>
#include <QDebug>

SoundManager::SoundManager(QObject *parent) : QObject(parent) {
    m_format.setSampleRate(44100);
    m_format.setChannelCount(1);
    m_format.setSampleFormat(QAudioFormat::UInt8);

    auto device = QMediaDevices::defaultAudioOutput();
    m_audioSink = new QAudioSink(device, m_format, this);
    m_audioSink->setBufferSize(44100); 
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
    
    // 优化：更柔和的振幅和 25% 占空比
    // 128 为中位（静音），振幅设为 32（最大 128）
    const int amplitude = 32; 
    const double dutyCycle = 0.25;

    for (int i = 0; i < sampleCount; ++i) {
        double phase = fmod(i, cycleLength) / cycleLength;
        
        // 增加简单的线性包络（淡出）以减少“刺耳”感
        double envelope = 1.0 - (static_cast<double>(i) / sampleCount);
        int val = (phase < dutyCycle) ? (128 + amplitude) : (128 - amplitude);
        
        // 应用包络并将结果放回 0-255 范围
        buffer[i] = static_cast<char>(128 + (val - 128) * envelope);
    }
}

void SoundManager::generateNoise(int duration, QByteArray &buffer) {
    int sampleRate = m_format.sampleRate();
    int sampleCount = (sampleRate * duration) / 1000;
    buffer.resize(sampleCount);

    const int noiseAmplitude = 24;

    for (int i = 0; i < sampleCount; ++i) {
        double envelope = 1.0 - (static_cast<double>(i) / sampleCount);
        int randVal = QRandomGenerator::global()->bounded(noiseAmplitude * 2) - noiseAmplitude;
        buffer[i] = static_cast<char>(128 + randVal * envelope);
    }
}
