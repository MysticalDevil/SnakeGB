#include "logging/runtime_logger.h"

#include <QDebug>

#include "logging/categories.h"

RuntimeLogger::RuntimeLogger(QObject* parent)
    : QObject(parent) {
}

void RuntimeLogger::inputSummary(const QString& message) {
  qCInfo(nenoserpentInputLog).noquote() << message;
}

void RuntimeLogger::inputDebug(const QString& message) {
  qCDebug(nenoserpentInputLog).noquote() << message;
}

void RuntimeLogger::routingSummary(const QString& message) {
  qCInfo(nenoserpentInputLog).noquote() << message;
}

void RuntimeLogger::routingDebug(const QString& message) {
  qCDebug(nenoserpentInputLog).noquote() << message;
}

void RuntimeLogger::injectWarning(const QString& message) {
  qCWarning(nenoserpentInjectLog).noquote() << message;
}
