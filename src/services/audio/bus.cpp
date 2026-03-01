#include "services/audio/bus.h"

#include <algorithm>

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

template <typename T, typename U>
void emitIfSet(const std::function<void(T, U)>& callback, T first, U second) {
  if (callback) {
    callback(first, second);
  }
}

using Clock = std::chrono::steady_clock;
using Ms = std::chrono::milliseconds;

} // namespace

AudioBus::AudioBus(AudioCallbacks callbacks) // NOLINT(performance-unnecessary-value-param)
    : m_callbacks(std::move(callbacks)) {
}

void AudioBus::setCallbacks(
  AudioCallbacks callbacks) { // NOLINT(performance-unnecessary-value-param)
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

auto AudioBus::musicTrackForState(const int state, const int bgmVariant)
  -> snakegb::audio::ScoreTrackId {
  const bool useAlt = (bgmVariant % 2) != 0;
  if (state == 1) {
    return useAlt ? snakegb::audio::ScoreTrackId::MenuAlt : snakegb::audio::ScoreTrackId::Menu;
  }
  if (state == 5) {
    return useAlt ? snakegb::audio::ScoreTrackId::ReplayAlt
                  : snakegb::audio::ScoreTrackId::Replay;
  }
  return useAlt ? snakegb::audio::ScoreTrackId::GameplayAlt
                : snakegb::audio::ScoreTrackId::Gameplay;
}

auto AudioBus::eventGroup(const snakegb::audio::Event event) -> AudioGroup {
  switch (event) {
  case snakegb::audio::Event::UiInteract:
  case snakegb::audio::Event::Confirm:
    return AudioGroup::Ui;
  case snakegb::audio::Event::Food:
  case snakegb::audio::Event::PowerUp:
  case snakegb::audio::Event::Crash:
    return AudioGroup::Sfx;
  }
  return AudioGroup::Sfx;
}

auto AudioBus::eventCooldownMs(const snakegb::audio::Event event) -> int {
  switch (event) {
  case snakegb::audio::Event::UiInteract:
    return 75;
  case snakegb::audio::Event::Confirm:
    return 90;
  case snakegb::audio::Event::Food:
  case snakegb::audio::Event::PowerUp:
  case snakegb::audio::Event::Crash:
    return 0;
  }
  return 0;
}

auto AudioBus::eventPriority(const snakegb::audio::Event event) -> int {
  switch (event) {
  case snakegb::audio::Event::Confirm:
    return 2;
  case snakegb::audio::Event::UiInteract:
    return 1;
  case snakegb::audio::Event::Food:
  case snakegb::audio::Event::PowerUp:
  case snakegb::audio::Event::Crash:
    return 0;
  }
  return 0;
}

auto AudioBus::duckingForEvent(const snakegb::audio::Event event)
  -> std::optional<std::pair<float, int>> {
  switch (event) {
  case snakegb::audio::Event::UiInteract:
    return std::pair{0.82F, 70};
  case snakegb::audio::Event::Confirm:
    return std::pair{0.68F, 110};
  case snakegb::audio::Event::PowerUp:
    return std::pair{0.72F, 130};
  case snakegb::audio::Event::Crash:
    return std::pair{0.35F, 240};
  case snakegb::audio::Event::Food:
    return std::nullopt;
  }
  return std::nullopt;
}

auto AudioBus::lastEventTime(const snakegb::audio::Event event) -> Clock::time_point& {
  switch (event) {
  case snakegb::audio::Event::Food:
    return m_lastEventTimes[0];
  case snakegb::audio::Event::PowerUp:
    return m_lastEventTimes[1];
  case snakegb::audio::Event::Crash:
    return m_lastEventTimes[2];
  case snakegb::audio::Event::UiInteract:
    return m_lastEventTimes[3];
  case snakegb::audio::Event::Confirm:
    return m_lastEventTimes[4];
  }
  return m_lastEventTimes[0];
}

auto AudioBus::lastEventTime(const snakegb::audio::Event event) const -> const Clock::time_point& {
  switch (event) {
  case snakegb::audio::Event::Food:
    return m_lastEventTimes[0];
  case snakegb::audio::Event::PowerUp:
    return m_lastEventTimes[1];
  case snakegb::audio::Event::Crash:
    return m_lastEventTimes[2];
  case snakegb::audio::Event::UiInteract:
    return m_lastEventTimes[3];
  case snakegb::audio::Event::Confirm:
    return m_lastEventTimes[4];
  }
  return m_lastEventTimes[0];
}

auto AudioBus::shouldDispatchEvent(const snakegb::audio::Event event, const Clock::time_point now)
  -> bool {
  const auto cooldown = eventCooldownMs(event);
  if (cooldown > 0) {
    const auto& eventTime = lastEventTime(event);
    if (eventTime.time_since_epoch().count() != 0 && now - eventTime < Ms(cooldown)) {
      return false;
    }
  }

  if (eventGroup(event) == AudioGroup::Ui && m_recentUiEvent.has_value()) {
    const auto recentWindow = Ms(std::max(eventCooldownMs(event), 90));
    const auto& recent = *m_recentUiEvent;
    if (now - recent.timestamp < recentWindow && recent.priority > eventPriority(event)) {
      return false;
    }
  }

  return true;
}

void AudioBus::rememberDispatch(const snakegb::audio::Event event, const Clock::time_point now) {
  lastEventTime(event) = now;
  if (eventGroup(event) == AudioGroup::Ui) {
    m_recentUiEvent =
      RecentUiEvent{.event = event, .timestamp = now, .priority = eventPriority(event)};
  }
}

void AudioBus::syncPausedState(const int state) const {
  emitIfSet(m_callbacks.setPaused, pausedForState(state));
}

void AudioBus::handleStateChanged(
  const int state,
  const bool musicEnabled,
  const int bgmVariant,
  const std::function<void(int delayMs, const std::function<void()>& callback)>& deferStart) const {
  const auto trackId = musicTrackForState(state, bgmVariant);
  switch (musicCommandForState(state, musicEnabled)) {
  case MusicCommand::StartNow:
    emitIfSet(m_callbacks.startMusic, trackId);
    break;
  case MusicCommand::StopNow:
    emitIfSet(m_callbacks.stopMusic);
    break;
  case MusicCommand::DeferMenuStart:
    if (deferStart && m_callbacks.startMusic) {
      const auto startMusic = m_callbacks.startMusic;
      deferStart(650, [startMusic, trackId]() -> void {
        if (startMusic) {
          startMusic(trackId);
        }
      });
    }
    break;
  case MusicCommand::None:
    break;
  }
}

void AudioBus::handleMusicToggle(const bool musicEnabled, const int state, const int bgmVariant) const {
  emitIfSet(m_callbacks.setMusicEnabled, musicEnabled);

  if (musicEnabled && state != 0) {
    emitIfSet(m_callbacks.startMusic, musicTrackForState(state, bgmVariant));
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
                             const snakegb::audio::EventPayload& payload) {
  const auto now = Clock::now();
  if (!shouldDispatchEvent(event, now)) {
    return;
  }
  rememberDispatch(event, now);

  if (const auto ducking = duckingForEvent(event); ducking.has_value()) {
    emitIfSet(m_callbacks.duckMusic, ducking->first, ducking->second);
  }

  const auto cue = snakegb::audio::cueForEvent(event);
  if (!cue.has_value()) {
    return;
  }

  if (cue->updatesScore) {
    emitIfSet(m_callbacks.setScore, payload.score);
  }

  switch (cue->kind) {
  case snakegb::audio::CueKind::Beep:
    if (m_callbacks.playBeep) {
      const auto pan = event == snakegb::audio::Event::Food ? payload.pan : 0.0F;
      m_callbacks.playBeep(cue->frequencyHz, cue->durationMs, pan);
    }
    break;
  case snakegb::audio::CueKind::Crash:
    emitIfSet(m_callbacks.playCrash, cue->durationMs);
    break;
  case snakegb::audio::CueKind::Score:
    if (m_callbacks.playScoreCue) {
      m_callbacks.playScoreCue(cue->scoreCue, 0.0F);
    }
    break;
  }
}

} // namespace snakegb::services
