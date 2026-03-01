#pragma once

#include <QObject>
#include <QVariantList>

class EngineAdapter;

class SelectionViewModel final : public QObject {
  Q_OBJECT
  Q_PROPERTY(QVariantList choices READ choices NOTIFY choicesChanged)
  Q_PROPERTY(bool choicePending READ choicePending NOTIFY choicePendingChanged)
  Q_PROPERTY(int choiceIndex READ choiceIndex NOTIFY choiceIndexChanged)
  Q_PROPERTY(QVariantList fruitLibrary READ fruitLibrary CONSTANT)
  Q_PROPERTY(int libraryIndex READ libraryIndex NOTIFY libraryIndexChanged)
  Q_PROPERTY(QVariantList medalLibrary READ medalLibrary CONSTANT)
  Q_PROPERTY(int medalIndex READ medalIndex NOTIFY medalIndexChanged)
  Q_PROPERTY(QVariantList achievements READ achievements NOTIFY achievementsChanged)

public:
  explicit SelectionViewModel(EngineAdapter* engineAdapter, QObject* parent = nullptr);

  [[nodiscard]] auto choices() const -> QVariantList;
  [[nodiscard]] auto choicePending() const -> bool;
  [[nodiscard]] auto choiceIndex() const -> int;
  [[nodiscard]] auto fruitLibrary() const -> QVariantList;
  [[nodiscard]] auto libraryIndex() const -> int;
  [[nodiscard]] auto medalLibrary() const -> QVariantList;
  [[nodiscard]] auto medalIndex() const -> int;
  [[nodiscard]] auto achievements() const -> QVariantList;

signals:
  void choicesChanged();
  void choicePendingChanged();
  void choiceIndexChanged();
  void libraryIndexChanged();
  void medalIndexChanged();
  void achievementsChanged();

private:
  EngineAdapter* m_engineAdapter = nullptr;
};
