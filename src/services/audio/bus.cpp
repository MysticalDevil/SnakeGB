#include "services/audio/bus.h"

namespace snakegb::services {
namespace {

void emitIfSet(const std::function<void()>& callback) {
  if (callback) {
    callback();
  }
}

template <typename T> void emitIfSet(const std::function<void(T)>& callback, T value) {
  if (callback) {
    callback(value);
  }
}

} // namespace

AudioBus::AudioBus(AudioCallbacks callbacks)
    : m_callbacks(std::move(callbacks)) {
}

void AudioBus::setCallbacks(AudioCallbacks callbacks) {
  m_callbacks = std::move(callbacks);
}

auto AudioBus::pausedForState(const int state) -> bool {
  return state == 3 || state == 6 || state == 7 || state == 8;
}

auto AudioBus::musicCommandForState(const int state, const bool musicEnabled) -> MusicCommand {
  if (state == 1) {
    return musicEnabled ? MusicCommand::DeferMenuStart : MusicCommand::None;
  }
  if (state == 2 || state == 5) {
    return musicEnabled ? MusicCommand::StartNow : MusicCommand::None;
  }
  if (state == 0 || state == 4) {
    return MusicCommand::StopNow;
  }
  return MusicCommand::None;
}

void AudioBus::syncPausedState(const int state) const {
  emitIfSet(m_callbacks.setPaused, pausedForState(state));
}

void AudioBus::handleStateChanged(
  const int state,
  const bool musicEnabled,
  const std::function<void(int delayMs, const std::function<void()>& callback)>& deferStart) const {
  switch (musicCommandForState(state, musicEnabled)) {
  case MusicCommand::StartNow:
    emitIfSet(m_callbacks.startMusic);
    break;
  case MusicCommand::StopNow:
    emitIfSet(m_callbacks.stopMusic);
    break;
  case MusicCommand::DeferMenuStart:
    if (deferStart && m_callbacks.startMusic) {
      deferStart(650, m_callbacks.startMusic);
    }
    break;
  case MusicCommand::None:
    break;
  }
}

void AudioBus::handleMusicToggle(const bool musicEnabled, const int state) const {
  emitIfSet(m_callbacks.setMusicEnabled, musicEnabled);

  if (musicEnabled && state != 0) {
    emitIfSet(m_callbacks.startMusic);
    return;
  }
  if (!musicEnabled) {
    emitIfSet(m_callbacks.stopMusic);
  }
}

void AudioBus::applyVolume(const float value) const {
  emitIfSet(m_callbacks.setVolume, value);
}

void AudioBus::dispatchEvent(const snakegb::audio::Event event,
                             const snakegb::audio::EventPayload& payload) const {
  switch (event) {
  case snakegb::audio::Event::Food:
    emitIfSet(m_callbacks.setScore, payload.score);
    if (m_callbacks.playBeep) {
      m_callbacks.playBeep(880, 100, payload.pan);
    }
    break;
  case snakegb::audio::Event::PowerUp:
    if (m_callbacks.playBeep) {
      m_callbacks.playBeep(1200, 150, 0.0F);
    }
    break;
  case snakegb::audio::Event::Crash:
    emitIfSet(m_callbacks.playCrash, 500);
    break;
  case snakegb::audio::Event::UiInteract:
    if (m_callbacks.playBeep) {
      m_callbacks.playBeep(200, 50, 0.0F);
    }
    break;
  case snakegb::audio::Event::Confirm:
    if (m_callbacks.playBeep) {
      m_callbacks.playBeep(1046, 140, 0.0F);
    }
    break;
  }
}

} // namespace snakegb::services
