#include "input_injection_pipe.h"

#include <QDebug>
#include <QFileInfo>
#include <QSocketNotifier>
#include <QtGlobal>

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
}

InputInjectionPipe::InputInjectionPipe(QObject *parent)
    : QObject(parent) {
#if !defined(Q_OS_UNIX)
    Q_UNUSED(parent);
    m_pipePath = qEnvironmentVariable("SNAKEGB_INPUT_PIPE").trimmed();
    if (!m_pipePath.isEmpty()) {
        qWarning().noquote() << "[InputInject] SNAKEGB_INPUT_PIPE is not supported on this platform";
    }
    return;
#else
    m_pipePath = qEnvironmentVariable("SNAKEGB_INPUT_PIPE").trimmed();
    if (m_pipePath.isEmpty()) {
        return;
    }

    const QFileInfo info(m_pipePath);
    if (info.exists() && !info.isWritable()) {
        qWarning().noquote() << "[InputInject] pipe path exists but not writable:" << m_pipePath;
        return;
    }

    if (mkfifo(m_pipePath.toLocal8Bit().constData(), kPipeMode) == 0) {
        m_createdPipe = true;
    } else if (errno != EEXIST) {
        qWarning().noquote() << "[InputInject] mkfifo failed:" << m_pipePath
                             << "errno=" << errno << std::strerror(errno);
        return;
    }

    m_fd = open(m_pipePath.toLocal8Bit().constData(), O_RDWR | O_NONBLOCK);
    if (m_fd < 0) {
        qWarning().noquote() << "[InputInject] open fifo failed:" << m_pipePath
                             << "errno=" << errno << std::strerror(errno);
        if (m_createdPipe) {
            unlink(m_pipePath.toLocal8Bit().constData());
        }
        return;
    }

    m_notifier = new QSocketNotifier(m_fd, QSocketNotifier::Read, this);
    connect(m_notifier, &QSocketNotifier::activated, this, &InputInjectionPipe::handleReadable);

    m_enabled = true;
    qInfo().noquote() << "[InputInject] enabled on pipe:" << m_pipePath;
#endif
}

InputInjectionPipe::~InputInjectionPipe() {
#if !defined(Q_OS_UNIX)
    return;
#endif
    if (m_notifier != nullptr) {
        m_notifier->setEnabled(false);
    }
    if (m_fd >= 0) {
        close(m_fd);
        m_fd = -1;
    }
    if (m_createdPipe && !m_pipePath.isEmpty()) {
        unlink(m_pipePath.toLocal8Bit().constData());
    }
}

void InputInjectionPipe::handleReadable() {
#if !defined(Q_OS_UNIX)
    return;
#endif
    if (m_fd < 0) {
        return;
    }

    char buffer[512]{};
    while (true) {
        const ssize_t n = read(m_fd, buffer, sizeof(buffer));
        if (n <= 0) {
            break;
        }
        m_pending += QString::fromUtf8(buffer, static_cast<int>(n));
    }

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
