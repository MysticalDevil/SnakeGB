#pragma once

#include <array>
#include <chrono>
#include <functional>
#include <optional>

#include "audio/cue.h"
#include "audio/event.h"

namespace nenoserpent::services {

enum class AudioGroup {
  Music,
  Ui,
  Sfx,
};

enum class MusicCommand {
  None,
  StartNow,
  StopNow,
  DeferMenuStart,
};

struct AudioCallbacks {
  std::function<void(nenoserpent::audio::ScoreTrackId)> startMusic;
  std::function<void()> stopMusic;
  std::function<void(bool)> setPaused;
  std::function<void(bool)> setMusicEnabled;
  std::function<void(float, int)> duckMusic;
  std::function<void(float)> setVolume;
  std::function<void(int)> setScore;
  std::function<void(int, int, float)> playBeep;
  std::function<void(nenoserpent::audio::ScoreCueId, float)> playScoreCue;
  std::function<void(int)> playCrash;
};

class AudioBus {
public:
  AudioBus() = default;
  explicit AudioBus(AudioCallbacks callbacks); // NOLINT(performance-unnecessary-value-param)

  void setCallbacks(AudioCallbacks callbacks); // NOLINT(performance-unnecessary-value-param)

  void syncPausedState(int state) const;
  void
  handleStateChanged(int state,
                     bool musicEnabled,
                     int bgmVariant,
                     const std::function<void(int delayMs, const std::function<void()>& callback)>&
                       deferStart) const;
  void handleMusicToggle(bool musicEnabled, int state, int bgmVariant) const;
  void applyVolume(float value) const;

  void dispatchEvent(nenoserpent::audio::Event event, const nenoserpent::audio::EventPayload& payload = {});

  [[nodiscard]] static auto pausedForState(int state) -> bool;
  [[nodiscard]] static auto musicCommandForState(int state, bool musicEnabled) -> MusicCommand;
  [[nodiscard]] static auto musicTrackForState(int state, int bgmVariant)
    -> nenoserpent::audio::ScoreTrackId;
  [[nodiscard]] static auto eventGroup(nenoserpent::audio::Event event) -> AudioGroup;
  [[nodiscard]] static auto eventCooldownMs(nenoserpent::audio::Event event) -> int;
  [[nodiscard]] static auto eventPriority(nenoserpent::audio::Event event) -> int;
  [[nodiscard]] static auto duckingForEvent(nenoserpent::audio::Event event)
    -> std::optional<std::pair<float, int>>;

private:
  struct RecentUiEvent {
    nenoserpent::audio::Event event;
    std::chrono::steady_clock::time_point timestamp;
    int priority = 0;
  };

  [[nodiscard]] auto shouldDispatchEvent(nenoserpent::audio::Event event,
                                         std::chrono::steady_clock::time_point now) -> bool;
  void rememberDispatch(nenoserpent::audio::Event event, std::chrono::steady_clock::time_point now);
  [[nodiscard]] auto lastEventTime(nenoserpent::audio::Event event)
    -> std::chrono::steady_clock::time_point&;
  [[nodiscard]] auto lastEventTime(nenoserpent::audio::Event event) const
    -> const std::chrono::steady_clock::time_point&;

  AudioCallbacks m_callbacks;
  std::array<std::chrono::steady_clock::time_point, 5> m_lastEventTimes{};
  std::optional<RecentUiEvent> m_recentUiEvent;
};

} // namespace nenoserpent::services
