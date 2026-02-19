#pragma once

#include <QAudioFormat>
#include <QAudioSink>
#include <QBuffer>
#include <QMediaDevices>
#include <QObject>
#include <QThread>

/**
 * @class SoundManager
 * @brief 使用过程生成 PCM 数据管理 8-bit 音效。
 */
class SoundManager final : public QObject {
    Q_OBJECT
public:
    explicit SoundManager(QObject *parent = nullptr);
    ~SoundManager() override;

    /**
     * @brief 播放方波哔声。
     */
    Q_INVOKABLE void playBeep(int frequencyHz, int durationMs);

    /**
     * @brief 播放噪声（用于碰撞/游戏结束）。
     */
    Q_INVOKABLE void playCrash(int durationMs);

private:
    void generateSquareWave(int frequencyHz, int durationMs, QByteArray &buffer);
    void generateNoise(int durationMs, QByteArray &buffer);

    QAudioFormat m_format;
    QAudioSink *m_audioSink = nullptr;
    QBuffer m_buffer;
};
