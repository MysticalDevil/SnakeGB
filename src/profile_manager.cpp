#include "profile_manager.h"
#include <QVariant>

using namespace Qt::StringLiterals;

ProfileManager::ProfileManager(QObject *parent) : QObject(parent), m_settings() {
    m_paletteIndex = m_settings.value(u"paletteIndex"_s, 0).toInt();
    m_shellIndex = m_settings.value(u"shellIndex"_s, 0).toInt();
    m_levelIndex = m_settings.value(u"levelIndex"_s, 0).toInt();
    m_volume = m_settings.value(u"volume"_s, 1.0f).toFloat();
    m_highScore = m_settings.value(u"highScore"_s, 0).toInt();
    m_totalCrashes = m_settings.value(u"totalCrashes"_s, 0).toInt();
    m_totalFoodEaten = m_settings.value(u"totalFoodEaten"_s, 0).toInt();
    m_totalGhostTriggers = m_settings.value(u"totalGhostTriggers"_s, 0).toInt();
    m_unlockedMedals = m_settings.value(u"unlockedMedals"_s).toStringList();
}

void ProfileManager::setPaletteIndex(int index) { m_paletteIndex = index; m_settings.setValue(u"paletteIndex"_s, m_paletteIndex); }
void ProfileManager::setShellIndex(int index) { m_shellIndex = index; m_settings.setValue(u"shellIndex"_s, m_shellIndex); }
void ProfileManager::setLevelIndex(int index) { m_levelIndex = index; m_settings.setValue(u"levelIndex"_s, m_levelIndex); }
void ProfileManager::setVolume(float v) { m_volume = v; m_settings.setValue(u"volume"_s, m_volume); m_settings.sync(); }

void ProfileManager::updateHighScore(int score) {
    if (score > m_highScore) { m_highScore = score; m_settings.setValue(u"highScore"_s, m_highScore); m_settings.sync(); }
}

void ProfileManager::saveStats() {
    m_settings.setValue(u"totalCrashes"_s, m_totalCrashes);
    m_settings.setValue(u"totalFoodEaten"_s, m_totalFoodEaten);
    m_settings.setValue(u"totalGhostTriggers"_s, m_totalGhostTriggers);
    m_settings.setValue(u"unlockedMedals"_s, m_unlockedMedals);
    m_settings.sync();
}

bool ProfileManager::unlockMedal(const QString &title) {
    if (!m_unlockedMedals.contains(title)) { m_unlockedMedals.append(title); saveStats(); emit medalUnlocked(title); return true; }
    return false;
}

void ProfileManager::saveSession(int score, const std::deque<QPoint> &body, const QList<QPoint> &obstacles, QPoint food, QPoint dir) {
    QVariantList bodyVar; for (const auto &p : body) bodyVar.append(p);
    QVariantList obsVar; for (const auto &p : obstacles) obsVar.append(p);
    m_settings.setValue(u"saved_score"_s, score); m_settings.setValue(u"saved_body"_s, bodyVar);
    m_settings.setValue(u"saved_obstacles"_s, obsVar); m_settings.setValue(u"saved_food"_s, food);
    m_settings.setValue(u"saved_dir"_s, dir); m_settings.sync();
}

void ProfileManager::clearSession() { m_settings.remove(u"saved_body"_s); m_settings.remove(u"saved_obstacles"_s); m_settings.sync(); }
bool ProfileManager::hasSession() const { return m_settings.contains(u"saved_body"_s); }

QVariantMap ProfileManager::loadSession() {
    QVariantMap data; data.insert(u"score"_s, m_settings.value(u"saved_score"_s));
    data.insert(u"body"_s, m_settings.value(u"saved_body"_s)); data.insert(u"obstacles"_s, m_settings.value(u"saved_obstacles"_s));
    data.insert(u"food"_s, m_settings.value(u"saved_food"_s)); data.insert(u"dir"_s, m_settings.value(u"saved_dir"_s));
    return data;
}
