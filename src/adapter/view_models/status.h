#pragma once

#include <QObject>
#include <QString>

class EngineAdapter;

class SessionStatusViewModel final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool hasSave READ hasSave NOTIFY hasSaveChanged)
    Q_PROPERTY(bool hasReplay READ hasReplay NOTIFY hasReplayChanged)
    Q_PROPERTY(int highScore READ highScore NOTIFY highScoreChanged)
    Q_PROPERTY(int level READ level NOTIFY levelChanged)
    Q_PROPERTY(QString currentLevelName READ currentLevelName NOTIFY levelChanged)

public:
    explicit SessionStatusViewModel(EngineAdapter *engineAdapter, QObject *parent = nullptr);

    [[nodiscard]] auto hasSave() const -> bool;
    [[nodiscard]] auto hasReplay() const -> bool;
    [[nodiscard]] auto highScore() const -> int;
    [[nodiscard]] auto level() const -> int;
    [[nodiscard]] auto currentLevelName() const -> QString;

signals:
    void hasSaveChanged();
    void hasReplayChanged();
    void highScoreChanged();
    void levelChanged();

private:
    EngineAdapter *m_engineAdapter = nullptr;
};
