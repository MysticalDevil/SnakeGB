#pragma once

#include <QObject>

class EngineAdapter;

class AudioSettingsViewModel final : public QObject {
  Q_OBJECT
  Q_PROPERTY(float volume READ volume WRITE setVolume NOTIFY volumeChanged)

public:
  explicit AudioSettingsViewModel(EngineAdapter* engineAdapter, QObject* parent = nullptr);

  [[nodiscard]] auto volume() const -> float;
  void setVolume(float value);

signals:
  void volumeChanged();

private:
  EngineAdapter* m_engineAdapter = nullptr;
};
