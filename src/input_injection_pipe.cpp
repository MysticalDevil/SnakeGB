#include "input_injection_pipe.h"

#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QMetaObject>
#include <QThread>
#include <QtGlobal>

#include "logging/categories.h"

#if defined(Q_OS_UNIX)
#include <cerrno>
#include <cstring>
#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>
#endif

namespace {
#if defined(Q_OS_UNIX)
constexpr mode_t kPipeMode = 0600;
#endif
} // namespace

InputInjectionPipe::InputInjectionPipe(QObject* parent)
    : QObject(parent) {
#if !defined(Q_OS_UNIX)
  Q_UNUSED(parent);
  m_pipePath = qEnvironmentVariable("NENOSERPENT_INPUT_PIPE").trimmed();
  m_filePath = qEnvironmentVariable("NENOSERPENT_INPUT_FILE").trimmed();
  if (!m_pipePath.isEmpty() || !m_filePath.isEmpty()) {
    qCWarning(nenoserpentInjectLog).noquote()
      << "injection endpoints are not supported on this platform";
  }
  return;
#else
  m_filePath = qEnvironmentVariable("NENOSERPENT_INPUT_FILE").trimmed();
  m_pipePath = qEnvironmentVariable("NENOSERPENT_INPUT_PIPE").trimmed();

  if (!m_filePath.isEmpty()) {
    QFile file(m_filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
      qCWarning(nenoserpentInjectLog).noquote() << "open input file failed:" << m_filePath;
      return;
    }
    file.close();
    m_mode = Mode::File;
  } else if (!m_pipePath.isEmpty()) {
    const QFileInfo info(m_pipePath);
    if (info.exists() && !info.isWritable()) {
      qCWarning(nenoserpentInjectLog).noquote() << "pipe path exists but not writable:" << m_pipePath;
      return;
    }

    if (mkfifo(m_pipePath.toLocal8Bit().constData(), kPipeMode) == 0) {
      m_createdPipe = true;
    } else if (errno != EEXIST) {
      qCWarning(nenoserpentInjectLog).noquote()
        << "mkfifo failed:" << m_pipePath << "errno=" << errno << std::strerror(errno);
      return;
    }

    m_fd = open(m_pipePath.toLocal8Bit().constData(), O_RDONLY | O_NONBLOCK);
    if (m_fd < 0) {
      qCWarning(nenoserpentInjectLog).noquote()
        << "open fifo(read) failed:" << m_pipePath << "errno=" << errno << std::strerror(errno);
      if (m_createdPipe) {
        unlink(m_pipePath.toLocal8Bit().constData());
      }
      return;
    }

    m_keepAliveWriterFd = open(m_pipePath.toLocal8Bit().constData(), O_WRONLY | O_NONBLOCK);
    if (m_keepAliveWriterFd < 0) {
      qCWarning(nenoserpentInjectLog).noquote() << "open fifo(write keepalive) failed:" << m_pipePath
                                            << "errno=" << errno << std::strerror(errno);
      close(m_fd);
      m_fd = -1;
      if (m_createdPipe) {
        unlink(m_pipePath.toLocal8Bit().constData());
      }
      return;
    }
    m_mode = Mode::Pipe;
  } else {
    return;
  }

  m_enabled = true;
  m_running.store(true);
  m_readerThread = std::thread([this]() { readerLoop(); });
  qCInfo(nenoserpentInjectLog).noquote() << "enabled on" << activePath();
#endif
}

InputInjectionPipe::~InputInjectionPipe() {
#if !defined(Q_OS_UNIX)
  return;
#endif
  m_running.store(false);
  if (m_keepAliveWriterFd >= 0) {
    static constexpr char wakeByte = '\n';
    const auto wakeResult = write(m_keepAliveWriterFd, &wakeByte, 1);
    Q_UNUSED(wakeResult);
  }
  if (m_readerThread.joinable()) {
    m_readerThread.join();
  }
  if (m_fd >= 0) {
    close(m_fd);
    m_fd = -1;
  }
  if (m_keepAliveWriterFd >= 0) {
    close(m_keepAliveWriterFd);
    m_keepAliveWriterFd = -1;
  }
  if (m_createdPipe && !m_pipePath.isEmpty()) {
    unlink(m_pipePath.toLocal8Bit().constData());
  }
}

void InputInjectionPipe::readerLoop() {
#if !defined(Q_OS_UNIX)
  return;
#endif
  if (m_mode == Mode::None) {
    return;
  }

  if (m_mode == Mode::File) {
    while (m_running.load()) {
      QFile file(m_filePath);
      if (file.open(QIODevice::ReadOnly)) {
        if (m_fileReadOffset > file.size()) {
          m_fileReadOffset = 0;
        }
        if (file.size() > m_fileReadOffset) {
          file.seek(m_fileReadOffset);
          const QByteArray bytes = file.readAll();
          m_fileReadOffset = file.pos();
          if (!bytes.isEmpty()) {
            const QString chunk = QString::fromUtf8(bytes);
            QMetaObject::invokeMethod(
              this, [this, chunk]() { processChunk(chunk); }, Qt::QueuedConnection);
          }
        }
        file.close();
      }
      QThread::msleep(20);
    }
    return;
  }

  if (m_fd < 0) {
    return;
  }

  char buffer[512]{};
  while (m_running.load()) {
    const ssize_t n = read(m_fd, buffer, sizeof(buffer));
    if (n > 0) {
      const QString chunk = QString::fromUtf8(buffer, static_cast<int>(n));
      QMetaObject::invokeMethod(
        this, [this, chunk]() { processChunk(chunk); }, Qt::QueuedConnection);
    } else if (n == 0 || errno == EAGAIN || errno == EWOULDBLOCK) {
      QThread::msleep(20);
    } else {
      qCWarning(nenoserpentInjectLog).noquote() << "read error errno=" << errno << std::strerror(errno);
      break;
    }
  }
}

void InputInjectionPipe::processChunk(const QString& chunk) {
  m_pending += chunk;

  int split = m_pending.indexOf('\n');
  while (split >= 0) {
    const QString raw = m_pending.left(split).trimmed();
    m_pending.remove(0, split + 1);
    if (!raw.isEmpty()) {
      emit actionInjected(raw);
    }
    split = m_pending.indexOf('\n');
  }
}

auto InputInjectionPipe::activePath() const -> QString {
  if (m_mode == Mode::File) {
    return m_filePath;
  }
  if (m_mode == Mode::Pipe) {
    return m_pipePath;
  }
  return {};
}
