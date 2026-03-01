#pragma once

#include <QObject>
#include <QString>

class RuntimeLogger : public QObject {
  Q_OBJECT

public:
  explicit RuntimeLogger(QObject* parent = nullptr);

  Q_INVOKABLE void inputSummary(const QString& message);
  Q_INVOKABLE void inputDebug(const QString& message);
  Q_INVOKABLE void routingSummary(const QString& message);
  Q_INVOKABLE void routingDebug(const QString& message);
  Q_INVOKABLE void injectWarning(const QString& message);
};
