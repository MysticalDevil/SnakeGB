#pragma once

#include <QObject>
#include <QString>

class QSocketNotifier;

class InputInjectionPipe final : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool enabled READ enabled CONSTANT)
    Q_PROPERTY(QString pipePath READ pipePath CONSTANT)

public:
    explicit InputInjectionPipe(QObject *parent = nullptr);
    ~InputInjectionPipe() override;

    auto enabled() const noexcept -> bool { return m_enabled; }
    auto pipePath() const -> QString { return m_pipePath; }

signals:
    void actionInjected(const QString &action);

private slots:
    void handleReadable();

private:
    QString m_pipePath{};
    QString m_pending{};
    QSocketNotifier *m_notifier{nullptr};
    int m_fd{-1};
    bool m_enabled{false};
    bool m_createdPipe{false};
};

