#pragma once

#include <QObject>
#include <QSettings>
#include <QStringList>
#include <QVariantList>
#include <QPoint>
#include <deque>

class ProfileManager : public QObject {
    Q_OBJECT
public:
    explicit ProfileManager(QObject *parent = nullptr);

    // Settings & Preferences
    int paletteIndex() const { return m_paletteIndex; }
    void setPaletteIndex(int index);
    int shellIndex() const { return m_shellIndex; }
    void setShellIndex(int index);
    int highScore() const { return m_highScore; }
    void updateHighScore(int score);

    // Statistics
    void incrementCrashes() { m_totalCrashes++; saveStats(); }
    void logFoodEaten() { m_totalFoodEaten++; saveStats(); }
    void logGhostTrigger() { m_totalGhostTriggers++; saveStats(); }

    // Achievements
    QStringList unlockedMedals() const { return m_unlockedMedals; }
    bool unlockMedal(const QString &title);
    
    // Game Session Persistence
    void saveSession(int score, const std::deque<QPoint> &body, const QList<QPoint> &obstacles, QPoint food, QPoint dir);
    void clearSession();
    bool hasSession() const;
    QVariantMap loadSession();

    // Stats getters
    int totalCrashes() const { return m_totalCrashes; }
    int totalFoodEaten() const { return m_totalFoodEaten; }
    int totalGhostTriggers() const { return m_totalGhostTriggers; }

signals:
    void medalUnlocked(const QString &title);

private:
    void saveStats();
    QSettings m_settings;
    int m_paletteIndex = 0;
    int m_shellIndex = 0;
    int m_highScore = 0;
    int m_totalCrashes = 0;
    int m_totalFoodEaten = 0;
    int m_totalGhostTriggers = 0;
    QStringList m_unlockedMedals;
};
