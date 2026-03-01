#pragma once

#include <atomic>
#include <thread>

#include <QObject>
#include <QString>

class InputInjectionPipe final : public QObject {
  Q_OBJECT
  Q_PROPERTY(bool enabled READ enabled CONSTANT)
  Q_PROPERTY(QString pipePath READ pipePath CONSTANT)

public:
  explicit InputInjectionPipe(QObject* parent = nullptr);
  ~InputInjectionPipe() override;

  auto enabled() const noexcept -> bool {
    return m_enabled;
  }
  auto pipePath() const -> QString {
    return activePath();
  }

signals:
  void actionInjected(const QString& action);

private slots:
  void processChunk(const QString& chunk);

private:
  void readerLoop();
  auto activePath() const -> QString;

  enum class Mode { None, Pipe, File };

  QString m_pipePath{};
  QString m_filePath{};
  QString m_pending{};
  int m_fd{-1};
  int m_keepAliveWriterFd{-1};
  bool m_enabled{false};
  bool m_createdPipe{false};
  Mode m_mode{Mode::None};
  qint64 m_fileReadOffset{0};
  std::atomic_bool m_running{false};
  std::thread m_readerThread{};
};
