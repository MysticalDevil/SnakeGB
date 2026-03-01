#pragma once

#include <functional>

#include "audio/event.h"

namespace snakegb::services {

enum class MusicCommand {
  None,
  StartNow,
  StopNow,
  DeferMenuStart,
};

struct AudioCallbacks {
  std::function<void()> startMusic;
  std::function<void()> stopMusic;
  std::function<void(bool)> setPaused;
  std::function<void(bool)> setMusicEnabled;
  std::function<void(float)> setVolume;
  std::function<void(int)> setScore;
  std::function<void(int, int, float)> playBeep;
  std::function<void(int)> playCrash;
};

class AudioBus {
public:
  AudioBus() = default;
  explicit AudioBus(AudioCallbacks callbacks);

  void setCallbacks(AudioCallbacks callbacks);

  void syncPausedState(int state) const;
  void
  handleStateChanged(int state,
                     bool musicEnabled,
                     const std::function<void(int delayMs, const std::function<void()>& callback)>&
                       deferStart) const;
  void handleMusicToggle(bool musicEnabled, int state) const;
  void applyVolume(float value) const;

  void dispatchEvent(snakegb::audio::Event event,
                     const snakegb::audio::EventPayload& payload = {}) const;

  [[nodiscard]] static auto pausedForState(int state) -> bool;
  [[nodiscard]] static auto musicCommandForState(int state, bool musicEnabled) -> MusicCommand;

private:
  AudioCallbacks m_callbacks;
};

} // namespace snakegb::services
