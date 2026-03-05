#include <QtTest/QtTest>

#include "audio/score.h"
#include "sound_manager.h"

class TestSoundManagerService : public QObject {
  Q_OBJECT

private slots:
  void setPausedResumeDoesNotImplicitlyStartMusic();
};

void TestSoundManagerService::setPausedResumeDoesNotImplicitlyStartMusic() {
  SoundManager manager;
  QSignalSpy startSpy(&manager, &SoundManager::musicStartRequested);

  manager.setMusicEnabled(true);
  manager.setPaused(true);
  manager.setPaused(false);
  QCOMPARE(startSpy.count(), 0);

  manager.startMusic(static_cast<int>(nenoserpent::audio::ScoreTrackId::GameplayEmeraldDawn));
  QCOMPARE(startSpy.count(), 1);
}

QTEST_MAIN(TestSoundManagerService)
#include "test_sound_manager_service.moc"
