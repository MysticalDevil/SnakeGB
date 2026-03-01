#pragma once

#include <QObject>
#include <QString>
#include <QVariantList>

class EngineAdapter;

class UiCommandController final : public QObject {
  Q_OBJECT

public:
  explicit UiCommandController(EngineAdapter* engineAdapter, QObject* parent = nullptr);

  Q_INVOKABLE void dispatch(const QString& action) const;
  Q_INVOKABLE void requestStateChange(int state) const;
  Q_INVOKABLE void seedChoicePreview(const QVariantList& types = QVariantList()) const;
  Q_INVOKABLE void seedReplayBuffPreview() const;

signals:
  void paletteChanged();
  void shellChanged();
  void achievementEarned(const QString& title);
  void eventPrompt(const QString& text);

private:
  EngineAdapter* m_engineAdapter = nullptr;
};
