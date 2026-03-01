#include <QtTest/QtTest>

#include "services/audio/bus.h"

class TestAudioBusService : public QObject {
  Q_OBJECT

private slots:
  void testPausedStates();
  void testStateChangePolicy();
  void testMusicTogglePolicy();
};

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
  int stopCount = 0;
  int pausedState = -1;
  int deferredDelay = 0;
  int deferredStartCount = 0;

  snakegb::services::AudioBus audioBus({
    .startMusic = [&]() -> void {
      startCount++;
      deferredStartCount++;
    },
    .stopMusic = [&]() -> void { stopCount++; },
    .setPaused = [&](const bool paused) -> void { pausedState = paused ? 1 : 0; },
  });

  audioBus.syncPausedState(3);
  QCOMPARE(pausedState, 1);

  audioBus.handleStateChanged(
    1, true, [&](const int delayMs, const std::function<void()>& callback) -> void {
      deferredDelay = delayMs;
      callback();
    });
  QCOMPARE(deferredDelay, 650);
  QCOMPARE(startCount, 1);
  QCOMPARE(deferredStartCount, 1);

  audioBus.handleStateChanged(2, true, {});
  QCOMPARE(startCount, 2);

  audioBus.handleStateChanged(4, true, {});
  QCOMPARE(stopCount, 1);
}

void TestAudioBusService::testMusicTogglePolicy() {
  int startCount = 0;
  int stopCount = 0;
  int musicEnabled = -1;

  snakegb::services::AudioBus audioBus({
    .startMusic = [&]() -> void { startCount++; },
    .stopMusic = [&]() -> void { stopCount++; },
    .setMusicEnabled = [&](const bool enabled) -> void { musicEnabled = enabled ? 1 : 0; },
  });

  audioBus.handleMusicToggle(true, 2);
  QCOMPARE(musicEnabled, 1);
  QCOMPARE(startCount, 1);
  QCOMPARE(stopCount, 0);

  audioBus.handleMusicToggle(false, 2);
  QCOMPARE(musicEnabled, 0);
  QCOMPARE(stopCount, 1);
}

QTEST_MAIN(TestAudioBusService)
#include "test_audio_bus_service.moc"
