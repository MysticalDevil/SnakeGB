#include "adapter/haptics/controller.h"

#include <QDateTime>

#ifdef Q_OS_ANDROID
#include <algorithm>

#include <QJniObject>

namespace {

auto hapticDurationMs(const int magnitude) -> jlong {
  const int clamped = std::clamp(magnitude, 1, 12);
  if (clamped <= 2) {
    return 8;
  }
  if (clamped <= 4) {
    return 12;
  }
  if (clamped <= 7) {
    return 16;
  }
  if (clamped <= 10) {
    return 22;
  }
  return 28;
}

auto hapticAmplitude(const int magnitude) -> jint {
  const int clamped = std::clamp(magnitude, 1, 12);
  return std::clamp(28 + clamped * 17, 40, 255);
}

auto minHapticIntervalMs(const int magnitude) -> qint64 {
  if (magnitude <= 2) {
    return 28;
  }
  if (magnitude <= 5) {
    return 22;
  }
  return 14;
}

} // namespace
#endif

namespace nenoserpent::adapter::haptics {

void Controller::trigger(const int magnitude) {
#ifdef Q_OS_ANDROID
  const qint64 nowMs = QDateTime::currentMSecsSinceEpoch();
  if (const qint64 elapsedMs = nowMs - m_lastHapticMs;
      elapsedMs >= 0 && elapsedMs < minHapticIntervalMs(magnitude)) {
    return;
  }
  m_lastHapticMs = nowMs;

  QJniObject context = QJniObject::callStaticObjectMethod(
    "org/qtproject/qt/android/QtNative", "activity", "()Landroid/app/Activity;");
  if (!context.isValid()) {
    context = QJniObject::callStaticObjectMethod(
      "org/qtproject/qt/android/QtNative", "context", "()Landroid/content/Context;");
  }
  if (!context.isValid()) {
    return;
  }

  QJniObject vibrator =
    context.callObjectMethod("getSystemService",
                             "(Ljava/lang/String;)Ljava/lang/Object;",
                             QJniObject::fromString("vibrator").object<jstring>());
  if (!vibrator.isValid()) {
    return;
  }

  const auto hasVibrator = vibrator.callMethod<jboolean>("hasVibrator", "()Z");
  if (!hasVibrator) {
    return;
  }

  const jlong duration = hapticDurationMs(magnitude);
  const jint amplitude = hapticAmplitude(magnitude);
  QJniObject effect = QJniObject::callStaticObjectMethod("android/os/VibrationEffect",
                                                         "createOneShot",
                                                         "(JI)Landroid/os/VibrationEffect;",
                                                         duration,
                                                         amplitude);
  if (effect.isValid()) {
    vibrator.callMethod<void>("vibrate", "(Landroid/os/VibrationEffect;)V", effect.object());
    return;
  }
  vibrator.callMethod<void>("vibrate", "(J)V", duration);
#else
  Q_UNUSED(magnitude);
#endif
}

} // namespace nenoserpent::adapter::haptics
