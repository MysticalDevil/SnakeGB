#include "sound_manager.h"

#include <algorithm>

#ifdef NENOSERPENT_HAS_MULTIMEDIA

#include <utility>

#include <QAudioDevice>
#include <QDebug>
#include <QMediaDevices>
#include <QRandomGenerator>
#include <QTimer>
#include <QtMath>

#include "logging/categories.h"

namespace {
constexpr int SampleRate = 48000;
constexpr int DefaultAmplitude = 32;
constexpr int Lead_Amplitude = 12;
constexpr int Bass_Amplitude = 8;
constexpr int Noise_Amplitude = 20;
constexpr int AttackMs = 5;
constexpr int CenterVal = 128;
constexpr int DeferMs = 100;
constexpr int ReverbDelayMs = 150;
#ifdef Q_OS_ANDROID
constexpr bool LowLoadAudioMode = true;
#else
constexpr bool LowLoadAudioMode = false;
#endif
} // namespace

SoundManager::SoundManager(QObject* parent)
    : QObject(parent) {
  m_format.setSampleRate(SampleRate);
  m_format.setChannelCount(2);
  m_format.setSampleFormat(QAudioFormat::UInt8);

  m_sfxBuffer.open(QIODevice::ReadWrite);
  m_bgmLeadBuffer.open(QIODevice::ReadWrite);
  m_bgmBassBuffer.open(QIODevice::ReadWrite);

  const auto reverbFrames = ((static_cast<std::size_t>(SampleRate) * ReverbDelayMs) / 1000U) * 2U;
  m_reverbBuffer.resize(reverbFrames, 0.0);

  connect(&m_musicTimer, &QTimer::timeout, this, &SoundManager::playNextNote);
  m_musicDuckTimer.setSingleShot(true);
  connect(&m_musicDuckTimer, &QTimer::timeout, this, [this]() -> void {
    m_musicDuckScale = 1.0F;
    applyMusicVolumes();
  });
  QTimer::singleShot(DeferMs, this, &SoundManager::initAudioAsync);
}

void SoundManager::initAudioAsync() {
  auto device = QMediaDevices::defaultAudioOutput();
  if (!device.isNull()) {
    m_sfxSink = new QAudioSink(device, m_format, this); // NOLINT(cppcoreguidelines-owning-memory)
    // NOLINTNEXTLINE(cppcoreguidelines-owning-memory)
    m_bgmLeadSink = new QAudioSink(device, m_format, this);
    if (!LowLoadAudioMode) {
      // NOLINTNEXTLINE(cppcoreguidelines-owning-memory)
      m_bgmBassSink = new QAudioSink(device, m_format, this);
    }
    m_sfxSink->setVolume(m_volume);
    applyMusicVolumes();
  }
}

SoundManager::~SoundManager() {
  if (m_sfxSink != nullptr)
    m_sfxSink->stop();
  if (m_bgmLeadSink != nullptr)
    m_bgmLeadSink->stop();
  if (m_bgmBassSink != nullptr)
    m_bgmBassSink->stop();
}

void SoundManager::setScore(int score) {
  m_currentScore = score;
}

void SoundManager::setVolume(float volume) {
  m_volume = std::clamp(volume, 0.0f, 1.0f);
  if (m_sfxSink != nullptr)
    m_sfxSink->setVolume(m_volume);
  applyMusicVolumes();
}

void SoundManager::applyMusicVolumes() {
  const auto musicVolume = m_volume * m_musicDuckScale;
  if (m_bgmLeadSink != nullptr)
    m_bgmLeadSink->setVolume(musicVolume);
  if (m_bgmBassSink != nullptr)
    m_bgmBassSink->setVolume(musicVolume);
}

auto SoundManager::setPaused(bool paused) -> void {
  qCInfo(nenoserpentAudioLog).noquote() << "setPaused =" << paused;
  m_isPaused = paused;
  if (!m_isPaused && m_musicEnabled && !m_musicTimer.isActive())
    startMusic(static_cast<int>(m_currentTrackId));
}

auto SoundManager::setMusicEnabled(bool enabled) -> void {
  qCInfo(nenoserpentAudioLog).noquote() << "setMusicEnabled =" << enabled;
  m_musicEnabled = enabled;
  if (!m_musicEnabled)
    stopMusic();
}

auto SoundManager::playBeep(const int frequencyHz, const int durationMs, float pan) -> void {
  qCDebug(nenoserpentAudioLog).noquote()
    << "playBeep f=" << frequencyHz << "ms=" << durationMs << "pan=" << pan;
  if (m_sfxSink == nullptr)
    return;
  QByteArray data;
  generateSquareWave(frequencyHz, durationMs, data, DefaultAmplitude, 0.5, pan);
  m_sfxSink->stop();
  m_sfxBuffer.close();
  m_sfxBuffer.setData(data);
  if (m_sfxBuffer.open(QIODevice::ReadOnly))
    m_sfxSink->start(&m_sfxBuffer);
}

auto SoundManager::playScoreCue(const int cueId, const float pan) -> void {
  qCDebug(nenoserpentAudioLog).noquote() << "playScoreCue id=" << cueId << "pan=" << pan;
  if (m_sfxSink == nullptr) {
    return;
  }

  const auto steps = nenoserpent::audio::scoreCueSteps(static_cast<nenoserpent::audio::ScoreCueId>(cueId));
  if (steps.empty()) {
    return;
  }

  QByteArray data;
  for (const auto& step : steps) {
    appendSquareWave(step.frequencyHz, step.durationMs, data, step.amplitude, step.duty, pan);
  }

  m_sfxSink->stop();
  m_sfxBuffer.close();
  m_sfxBuffer.setData(data);
  if (m_sfxBuffer.open(QIODevice::ReadOnly)) {
    m_sfxSink->start(&m_sfxBuffer);
  }
}

auto SoundManager::playCrash(const int durationMs) -> void {
  qCDebug(nenoserpentAudioLog).noquote() << "playCrash ms=" << durationMs;
  if (m_sfxSink == nullptr)
    return;
  QByteArray data;
  generateNoise(durationMs, data);
  m_sfxSink->stop();
  m_sfxBuffer.close();
  m_sfxBuffer.setData(data);
  if (m_sfxBuffer.open(QIODevice::ReadOnly))
    m_sfxSink->start(&m_sfxBuffer);
}

auto SoundManager::startMusic(const int trackId) -> void {
  qCInfo(nenoserpentAudioLog).noquote()
    << "startMusic"
    << "(enabled=" << m_musicEnabled << ", paused=" << m_isPaused << ", track=" << trackId << ")";
  if (!m_musicEnabled || m_bgmLeadSink == nullptr)
    return;
  m_currentTrackId = static_cast<nenoserpent::audio::ScoreTrackId>(trackId);
  m_noteIndex = 0;
  playNextNote();
}

auto SoundManager::stopMusic() -> void {
  qCInfo(nenoserpentAudioLog).noquote() << "stopMusic";
  m_musicTimer.stop();
  if (m_bgmLeadSink != nullptr)
    m_bgmLeadSink->stop();
  if (m_bgmBassSink != nullptr)
    m_bgmBassSink->stop();
}

auto SoundManager::duckMusic(const float scale, const int durationMs) -> void {
  m_musicDuckScale = std::clamp(scale, 0.1F, 1.0F);
  applyMusicVolumes();
  if (durationMs > 0) {
    m_musicDuckTimer.start(durationMs);
  } else {
    m_musicDuckTimer.stop();
  }
}

auto SoundManager::playNextNote() -> void {
  if (m_bgmLeadSink == nullptr || !m_musicEnabled)
    return;
  const auto trackSteps = nenoserpent::audio::scoreTrackSteps(m_currentTrackId);
  if (trackSteps.empty())
    return;
  if (std::cmp_greater_equal(m_noteIndex, trackSteps.size()))
    m_noteIndex = 0;

  const auto [leadPitch, bassPitch, duration, leadDuty, bassDuty] =
    trackSteps[static_cast<std::size_t>(m_noteIndex)];
  m_noteIndex++;

  const auto leadFreq = nenoserpent::audio::pitchFrequencyHz(leadPitch);
  const auto bassFreq = nenoserpent::audio::pitchFrequencyHz(bassPitch);

  double tempoScale = std::max(0.6, 1.0 - ((m_currentScore / 5.0) * 0.05));
  if (LowLoadAudioMode) {
    tempoScale *= 1.35;
  }
  int scaledDuration = static_cast<int>(duration * tempoScale);

  if (leadFreq > 0 && m_bgmLeadSink != nullptr) {
    QByteArray leadData;
    generateSquareWave(leadFreq,
                       scaledDuration - 5,
                       leadData,
                       Lead_Amplitude,
                       nenoserpent::audio::dutyCycle(leadDuty),
                       0.2f);
    if (m_isPaused)
      applyLowPassFilter(leadData);
    else if (!LowLoadAudioMode)
      applyReverb(leadData);
    m_bgmLeadSink->stop();
    m_bgmLeadBuffer.close();
    m_bgmLeadBuffer.setData(leadData);
    if (m_bgmLeadBuffer.open(QIODevice::ReadOnly))
      m_bgmLeadSink->start(&m_bgmLeadBuffer);
  }

  if (!LowLoadAudioMode && bassFreq > 0 && m_bgmBassSink != nullptr) {
    QByteArray bassData;
    generateSquareWave(bassFreq,
                       scaledDuration - 5,
                       bassData,
                       Bass_Amplitude,
                       nenoserpent::audio::dutyCycle(bassDuty),
                       -0.2f);
    if (m_isPaused)
      applyLowPassFilter(bassData);
    m_bgmBassSink->stop();
    m_bgmBassBuffer.close();
    m_bgmBassBuffer.setData(bassData);
    if (m_bgmBassBuffer.open(QIODevice::ReadOnly))
      m_bgmBassSink->start(&m_bgmBassBuffer);
  }

  m_musicTimer.start(scaledDuration);
}

auto SoundManager::generateSquareWave(const int frequencyHz,
                                      const int durationMs,
                                      QByteArray& buffer,
                                      int amplitude,
                                      double duty,
                                      float pan) -> void {
  const int sampleRate = m_format.sampleRate();
  if (sampleRate <= 0)
    return;
  const int frames = (sampleRate * durationMs) / 1000;
  if (frames <= 0)
    return;
  buffer.resize(static_cast<qsizetype>(frames) * 2);
  const double cycleLength = static_cast<double>(sampleRate) / frequencyHz;
  const int attackSamples = (sampleRate * AttackMs) / 1000;
  float leftGain = 1.0f;
  float rightGain = 1.0f;
  if (pan < 0)
    rightGain = 1.0f + pan;
  else
    leftGain = 1.0f - pan;
  for (int i = 0; i < frames; ++i) {
    const double phase = fmod(i, cycleLength) / cycleLength;
    double envelope =
      (i < attackSamples)
        ? (static_cast<double>(i) / attackSamples)
        : (1.0 - (static_cast<double>(i - attackSamples) / (frames - attackSamples)));
    const int rawVal = (phase < duty) ? amplitude : -amplitude;
    buffer[static_cast<qsizetype>(i) * 2] =
      static_cast<char>(CenterVal + (rawVal * envelope * leftGain));
    buffer[(static_cast<qsizetype>(i) * 2) + 1] =
      static_cast<char>(CenterVal + (rawVal * envelope * rightGain));
  }
}

void SoundManager::appendSquareWave(const int frequencyHz,
                                    const int durationMs,
                                    QByteArray& buffer,
                                    const int amplitude,
                                    const double duty,
                                    const float pan) {
  QByteArray segment;
  generateSquareWave(frequencyHz, durationMs, segment, amplitude, duty, pan);
  buffer.append(segment);
}

void SoundManager::applyLowPassFilter(QByteArray& buffer) {
  double lastValL = 128.0;
  double lastValR = 128.0;
  for (int i = 0; i < buffer.size(); i += 2) {
    double currentL = static_cast<unsigned char>(buffer[i]);
    double filteredL = lastValL + (m_lpfAlpha * (currentL - lastValL));
    buffer[i] = static_cast<char>(static_cast<unsigned char>(filteredL));
    lastValL = filteredL;
    if (i + 1 < buffer.size()) {
      double currentR = static_cast<unsigned char>(buffer[i + 1]);
      double filteredR = lastValR + (m_lpfAlpha * (currentR - lastValR));
      buffer[i + 1] = static_cast<char>(static_cast<unsigned char>(filteredR));
      lastValR = filteredR;
    }
  }
}

void SoundManager::applyReverb(QByteArray& buffer) {
  double wet = std::min(0.4, m_currentScore * 0.02);
  if (wet <= 0.01)
    return;
  for (char& i : buffer) {
    int sample = static_cast<unsigned char>(i) - CenterVal;
    double delayed = m_reverbBuffer[m_reverbWriteHead];
    m_reverbBuffer[m_reverbWriteHead] = sample + (delayed * 0.3);
    m_reverbWriteHead++;
    if (std::cmp_greater_equal(m_reverbWriteHead, m_reverbBuffer.size()))
      m_reverbWriteHead = 0;
    int mixed = std::clamp(static_cast<int>(sample + (delayed * wet)), -127, 127);
    i = static_cast<char>(CenterVal + mixed);
  }
}

void SoundManager::generateNoise(const int durationMs, QByteArray& buffer) {
  const int sampleRate = m_format.sampleRate();
  const int frames = (sampleRate * durationMs) / 1000;
  if (frames <= 0)
    return;
  buffer.resize(static_cast<qsizetype>(frames) * 2);
  for (int i = 0; i < frames; ++i) {
    const double envelope = 1.0 - (static_cast<double>(i) / frames);
    const int randVal = QRandomGenerator::global()->bounded(Noise_Amplitude * 2) - Noise_Amplitude;
    char val = static_cast<char>(CenterVal + (randVal * envelope));
    buffer[static_cast<qsizetype>(i) * 2] = val;
    buffer[(static_cast<qsizetype>(i) * 2) + 1] = val;
  }
}

#else

#include <QDebug>

SoundManager::SoundManager(QObject* parent)
    : QObject(parent) {
}

SoundManager::~SoundManager() = default;

void SoundManager::initAudioAsync() {
}

void SoundManager::setScore(int score) {
  m_currentScore = score;
}

void SoundManager::setVolume(float volume) {
  m_volume = std::clamp(volume, 0.0F, 1.0F);
}

void SoundManager::applyMusicVolumes() {
}

auto SoundManager::setPaused(bool paused) -> void {
  m_isPaused = paused;
}

auto SoundManager::setMusicEnabled(bool enabled) -> void {
  m_musicEnabled = enabled;
}

auto SoundManager::playBeep(int, int, float) -> void {
}

auto SoundManager::playScoreCue(int, float) -> void {
}

auto SoundManager::playCrash(int) -> void {
}

auto SoundManager::startMusic(int) -> void {
}

auto SoundManager::stopMusic() -> void {
}

auto SoundManager::duckMusic(float, int) -> void {
}

auto SoundManager::playNextNote() -> void {
}

#endif
