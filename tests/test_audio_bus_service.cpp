#include <QFile>
#include <QScopeGuard>
#include <QTemporaryDir>
#include <QtTest/QtTest>

#include "audio/cue.h"
#include "audio/score.h"
#include "services/audio/bus.h"

class TestAudioBusService : public QObject {
  Q_OBJECT

private slots:
  void testCueTableCoversAllEvents();
  void testPausedStates();
  void testStateChangePolicy();
  void testAlternateTrackSelectionPolicy();
  void testMusicTogglePolicy();
  void testDispatchEventRoutesCallbacks();
  void testUiEventsRespectCooldownPolicy();
  void testConfirmOverridesRecentUiInteract();
  void testExternalTrackOverrideLoadsFromEnvPath();
  void testTransientEventsTriggerMusicDucking();
};

void TestAudioBusService::testCueTableCoversAllEvents() {
  const auto foodCue = snakegb::audio::cueForEvent(snakegb::audio::Event::Food);
  QVERIFY(foodCue.has_value());
  QCOMPARE(foodCue->frequencyHz, 880);
  QVERIFY(foodCue->updatesScore);

  const auto uiInteractCue = snakegb::audio::cueForEvent(snakegb::audio::Event::UiInteract);
  QVERIFY(uiInteractCue.has_value());
  QCOMPARE(uiInteractCue->kind, snakegb::audio::CueKind::Score);
  QCOMPARE(uiInteractCue->scoreCue, snakegb::audio::ScoreCueId::UiInteract);

  const auto uiInteractSteps =
    snakegb::audio::scoreCueSteps(snakegb::audio::ScoreCueId::UiInteract);
  QCOMPARE(uiInteractSteps.size(), 2U);
  QCOMPARE(uiInteractSteps.front().frequencyHz, 262);

  const auto confirmCue = snakegb::audio::cueForEvent(snakegb::audio::Event::Confirm);
  QVERIFY(confirmCue.has_value());
  QCOMPARE(confirmCue->kind, snakegb::audio::CueKind::Score);
  QCOMPARE(confirmCue->scoreCue, snakegb::audio::ScoreCueId::Confirm);

  const auto confirmSteps = snakegb::audio::scoreCueSteps(snakegb::audio::ScoreCueId::Confirm);
  QCOMPARE(confirmSteps.size(), 3U);
  QCOMPARE(confirmSteps.front().frequencyHz, 1046);

  const auto crashCue = snakegb::audio::cueForEvent(snakegb::audio::Event::Crash);
  QVERIFY(crashCue.has_value());
  QCOMPARE(crashCue->kind, snakegb::audio::CueKind::Crash);
  QCOMPARE(crashCue->durationMs, 500);

  const auto menuTrack = snakegb::audio::scoreTrackSteps(snakegb::audio::ScoreTrackId::Menu);
  QCOMPARE(menuTrack.size(), 32U);
  QCOMPARE(menuTrack.front().leadPitch, snakegb::audio::Pitch::E5);
  QCOMPARE(menuTrack.back().bassPitch, snakegb::audio::Pitch::C3);
  QCOMPARE(menuTrack.front().leadDuty, snakegb::audio::PulseDuty::Quarter);

  const auto gameplayTrack =
    snakegb::audio::scoreTrackSteps(snakegb::audio::ScoreTrackId::Gameplay);
  QCOMPARE(gameplayTrack.front().leadPitch, snakegb::audio::Pitch::A4);
  QCOMPARE(gameplayTrack.front().leadDuty, snakegb::audio::PulseDuty::Half);

  const auto menuAltTrack = snakegb::audio::scoreTrackSteps(snakegb::audio::ScoreTrackId::MenuAlt);
  QCOMPARE(menuAltTrack.size(), 16U);
  QCOMPARE(menuAltTrack.front().leadPitch, snakegb::audio::Pitch::C5);
  QCOMPARE(menuAltTrack.front().leadDuty, snakegb::audio::PulseDuty::Narrow);

  const auto gameplayAltTrack =
    snakegb::audio::scoreTrackSteps(snakegb::audio::ScoreTrackId::GameplayAlt);
  QCOMPARE(gameplayAltTrack.front().leadPitch, snakegb::audio::Pitch::E4);
  QCOMPARE(gameplayAltTrack.front().bassDuty, snakegb::audio::PulseDuty::Wide);

  const auto replayTrack = snakegb::audio::scoreTrackSteps(snakegb::audio::ScoreTrackId::Replay);
  QCOMPARE(replayTrack.size(), 12U);
  QCOMPARE(replayTrack.front().leadPitch, snakegb::audio::Pitch::C5);
  QCOMPARE(replayTrack.front().bassPitch, snakegb::audio::Pitch::C3);

  const auto replayAltTrack =
    snakegb::audio::scoreTrackSteps(snakegb::audio::ScoreTrackId::ReplayAlt);
  QCOMPARE(replayAltTrack.size(), 8U);
  QCOMPARE(replayAltTrack.front().leadPitch, snakegb::audio::Pitch::A4);
  QCOMPARE(replayAltTrack.front().leadDuty, snakegb::audio::PulseDuty::Wide);
}

void TestAudioBusService::testPausedStates() {
  QVERIFY(!snakegb::services::AudioBus::pausedForState(0));
  QVERIFY(!snakegb::services::AudioBus::pausedForState(1));
  QVERIFY(!snakegb::services::AudioBus::pausedForState(2));
  QVERIFY(snakegb::services::AudioBus::pausedForState(3));
  QVERIFY(snakegb::services::AudioBus::pausedForState(6));
  QVERIFY(snakegb::services::AudioBus::pausedForState(7));
  QVERIFY(snakegb::services::AudioBus::pausedForState(8));
}

void TestAudioBusService::testStateChangePolicy() {
  int startCount = 0;
  int startedTrack = -1;
  int stopCount = 0;
  int pausedState = -1;
  int deferredDelay = 0;
  int deferredStartCount = 0;

  snakegb::services::AudioBus audioBus({
    .startMusic = [&](const snakegb::audio::ScoreTrackId trackId) -> void {
      startCount++;
      startedTrack = static_cast<int>(trackId);
      deferredStartCount++;
    },
    .stopMusic = [&]() -> void { stopCount++; },
    .setPaused = [&](const bool paused) -> void { pausedState = paused ? 1 : 0; },
  });

  audioBus.syncPausedState(3);
  QCOMPARE(pausedState, 1);

  audioBus.handleStateChanged(
    1, true, 0, [&](const int delayMs, const std::function<void()>& callback) -> void {
      deferredDelay = delayMs;
      callback();
    });
  QCOMPARE(deferredDelay, 650);
  QCOMPARE(startCount, 1);
  QCOMPARE(deferredStartCount, 1);
  QCOMPARE(startedTrack, static_cast<int>(snakegb::audio::ScoreTrackId::Menu));

  audioBus.handleStateChanged(2, true, 0, {});
  QCOMPARE(startCount, 2);
  QCOMPARE(startedTrack, static_cast<int>(snakegb::audio::ScoreTrackId::Gameplay));

  audioBus.handleStateChanged(5, true, 0, {});
  QCOMPARE(startCount, 3);
  QCOMPARE(startedTrack, static_cast<int>(snakegb::audio::ScoreTrackId::Replay));

  audioBus.handleStateChanged(4, true, 0, {});
  QCOMPARE(stopCount, 1);
}

void TestAudioBusService::testAlternateTrackSelectionPolicy() {
  QCOMPARE(snakegb::services::AudioBus::musicTrackForState(1, 0),
           snakegb::audio::ScoreTrackId::Menu);
  QCOMPARE(snakegb::services::AudioBus::musicTrackForState(1, 1),
           snakegb::audio::ScoreTrackId::MenuAlt);
  QCOMPARE(snakegb::services::AudioBus::musicTrackForState(2, 0),
           snakegb::audio::ScoreTrackId::Gameplay);
  QCOMPARE(snakegb::services::AudioBus::musicTrackForState(2, 1),
           snakegb::audio::ScoreTrackId::GameplayAlt);
  QCOMPARE(snakegb::services::AudioBus::musicTrackForState(5, 0),
           snakegb::audio::ScoreTrackId::Replay);
  QCOMPARE(snakegb::services::AudioBus::musicTrackForState(5, 1),
           snakegb::audio::ScoreTrackId::ReplayAlt);
}

void TestAudioBusService::testMusicTogglePolicy() {
  int startCount = 0;
  int stopCount = 0;
  int musicEnabled = -1;
  int startedTrack = -1;

  snakegb::services::AudioBus audioBus({
    .startMusic = [&](const snakegb::audio::ScoreTrackId trackId) -> void {
      startCount++;
      startedTrack = static_cast<int>(trackId);
    },
    .stopMusic = [&]() -> void { stopCount++; },
    .setMusicEnabled = [&](const bool enabled) -> void { musicEnabled = enabled ? 1 : 0; },
  });

  audioBus.handleMusicToggle(true, 2, 0);
  QCOMPARE(musicEnabled, 1);
  QCOMPARE(startCount, 1);
  QCOMPARE(startedTrack, static_cast<int>(snakegb::audio::ScoreTrackId::Gameplay));
  QCOMPARE(stopCount, 0);

  audioBus.handleMusicToggle(false, 2, 0);
  QCOMPARE(musicEnabled, 0);
  QCOMPARE(stopCount, 1);
}

void TestAudioBusService::testDispatchEventRoutesCallbacks() {
  int score = -1;
  int beepFrequency = 0;
  int beepDuration = 0;
  float beepPan = 0.0F;
  int crashDuration = 0;
  int scoreCueId = -1;
  int scoreCueCount = 0;

  snakegb::services::AudioBus audioBus({
    .setScore = [&](const int value) -> void { score = value; },
    .playBeep = [&](const int frequencyHz, const int durationMs, const float pan) -> void {
      beepFrequency = frequencyHz;
      beepDuration = durationMs;
      beepPan = pan;
    },
    .playScoreCue = [&](const snakegb::audio::ScoreCueId cueId, const float) -> void {
      scoreCueId = static_cast<int>(cueId);
      scoreCueCount++;
    },
    .playCrash = [&](const int durationMs) -> void { crashDuration = durationMs; },
  });

  audioBus.dispatchEvent(snakegb::audio::Event::Food, {.score = 42, .pan = -0.25F});
  QCOMPARE(score, 42);
  QCOMPARE(beepFrequency, 880);
  QCOMPARE(beepDuration, 100);
  QCOMPARE(beepPan, -0.25F);

  audioBus.dispatchEvent(snakegb::audio::Event::PowerUp);
  QCOMPARE(beepFrequency, 1200);
  QCOMPARE(beepDuration, 150);
  QCOMPARE(beepPan, 0.0F);

  audioBus.dispatchEvent(snakegb::audio::Event::UiInteract);
  QCOMPARE(scoreCueId, static_cast<int>(snakegb::audio::ScoreCueId::UiInteract));
  QCOMPARE(scoreCueCount, 1);

  audioBus.dispatchEvent(snakegb::audio::Event::Confirm);
  QCOMPARE(scoreCueId, static_cast<int>(snakegb::audio::ScoreCueId::Confirm));
  QCOMPARE(scoreCueCount, 2);

  audioBus.dispatchEvent(snakegb::audio::Event::Crash);
  QCOMPARE(crashDuration, 500);
}

void TestAudioBusService::testUiEventsRespectCooldownPolicy() {
  int scoreCueCount = 0;
  int lastScoreCueId = -1;

  snakegb::services::AudioBus audioBus({
    .playScoreCue = [&](const snakegb::audio::ScoreCueId cueId, const float) -> void {
      scoreCueCount++;
      lastScoreCueId = static_cast<int>(cueId);
    },
  });

  audioBus.dispatchEvent(snakegb::audio::Event::UiInteract);
  audioBus.dispatchEvent(snakegb::audio::Event::UiInteract);

  QCOMPARE(scoreCueCount, 1);
  QCOMPARE(lastScoreCueId, static_cast<int>(snakegb::audio::ScoreCueId::UiInteract));
}

void TestAudioBusService::testConfirmOverridesRecentUiInteract() {
  QList<int> scoreCueIds;

  snakegb::services::AudioBus audioBus({
    .playScoreCue = [&](const snakegb::audio::ScoreCueId cueId, const float) -> void {
      scoreCueIds.push_back(static_cast<int>(cueId));
    },
  });

  audioBus.dispatchEvent(snakegb::audio::Event::UiInteract);
  audioBus.dispatchEvent(snakegb::audio::Event::Confirm);
  audioBus.dispatchEvent(snakegb::audio::Event::UiInteract);

  QCOMPARE(scoreCueIds.size(), 2);
  QCOMPARE(scoreCueIds.at(0), static_cast<int>(snakegb::audio::ScoreCueId::UiInteract));
  QCOMPARE(scoreCueIds.at(1), static_cast<int>(snakegb::audio::ScoreCueId::Confirm));
}

void TestAudioBusService::testExternalTrackOverrideLoadsFromEnvPath() {
  QTemporaryDir tempDir;
  QVERIFY(tempDir.isValid());

  const auto overridePath = tempDir.filePath("custom_tracks.json");
  QFile overrideFile(overridePath);
  QVERIFY(overrideFile.open(QIODevice::WriteOnly | QIODevice::Truncate));
  overrideFile.write(R"json({
    "tracks": {
      "replay": [
        {
          "lead": "A5",
          "bass": "A3",
          "durationMs": 180,
          "leadDuty": "wide",
          "bassDuty": "quarter"
        }
      ],
      "menu_alt": [
        {
          "lead": "D5",
          "bass": "D3",
          "durationMs": 150,
          "leadDuty": "half",
          "bassDuty": "wide"
        }
      ]
    }
  })json");
  overrideFile.close();

  qputenv("SNAKEGB_SCORE_OVERRIDE_FILE", overridePath.toUtf8());
  const auto restoreEnv = qScopeGuard([]() { qunsetenv("SNAKEGB_SCORE_OVERRIDE_FILE"); });

  const auto replayTrack = snakegb::audio::scoreTrackSteps(snakegb::audio::ScoreTrackId::Replay);
  QCOMPARE(replayTrack.size(), 1U);
  QCOMPARE(replayTrack.front().leadPitch, snakegb::audio::Pitch::A5);
  QCOMPARE(replayTrack.front().bassPitch, snakegb::audio::Pitch::A3);
  QCOMPARE(replayTrack.front().leadDuty, snakegb::audio::PulseDuty::Wide);
  QCOMPARE(replayTrack.front().bassDuty, snakegb::audio::PulseDuty::Quarter);

  const auto menuAltTrack = snakegb::audio::scoreTrackSteps(snakegb::audio::ScoreTrackId::MenuAlt);
  QCOMPARE(menuAltTrack.size(), 1U);
  QCOMPARE(menuAltTrack.front().leadPitch, snakegb::audio::Pitch::D5);
  QCOMPARE(menuAltTrack.front().bassPitch, snakegb::audio::Pitch::D3);
}

void TestAudioBusService::testTransientEventsTriggerMusicDucking() {
  QList<QPair<float, int>> duckingCalls;

  snakegb::services::AudioBus audioBus({
    .duckMusic = [&](const float scale, const int durationMs) -> void {
      duckingCalls.push_back({scale, durationMs});
    },
  });

  audioBus.dispatchEvent(snakegb::audio::Event::UiInteract);
  audioBus.dispatchEvent(snakegb::audio::Event::Confirm);
  audioBus.dispatchEvent(snakegb::audio::Event::PowerUp);
  audioBus.dispatchEvent(snakegb::audio::Event::Crash);

  QCOMPARE(duckingCalls.size(), 4);
  QCOMPARE(duckingCalls.at(0).first, 0.82F);
  QCOMPARE(duckingCalls.at(0).second, 70);
  QCOMPARE(duckingCalls.at(1).first, 0.68F);
  QCOMPARE(duckingCalls.at(1).second, 110);
  QCOMPARE(duckingCalls.at(2).first, 0.72F);
  QCOMPARE(duckingCalls.at(2).second, 130);
  QCOMPARE(duckingCalls.at(3).first, 0.35F);
  QCOMPARE(duckingCalls.at(3).second, 240);
}

QTEST_MAIN(TestAudioBusService)
#include "test_audio_bus_service.moc"
