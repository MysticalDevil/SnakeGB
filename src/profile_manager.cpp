#include "profile_manager.h"
#include <QVariantList>

using namespace Qt::StringLiterals;

ProfileManager::ProfileManager(QObject *parent) : QObject(parent) {
    m_paletteIndex = m_settings.value(u"paletteIndex"_s, 0).toInt();
    m_shellIndex = m_settings.value(u"shellIndex"_s, 0).toInt();
    m_levelIndex = m_settings.value(u"levelIndex"_s, 0).toInt();
    m_highScore = m_settings.value(u"highScore"_s, 0).toInt();
    m_volume = m_settings.value(u"volume"_s, 1.0).toFloat();
    m_totalCrashes = m_settings.value(u"stats/crashes"_s, 0).toInt();
    m_totalFoodEaten = m_settings.value(u"stats/food"_s, 0).toInt();
    m_totalGhostTriggers = m_settings.value(u"stats/ghosts"_s, 0).toInt();
    m_unlockedMedals = m_settings.value(u"medals"_s).toStringList();
    
    QVariantList fruitList = m_settings.value(u"discoveredFruits"_s).toList();
    for (const auto &v : fruitList) m_discoveredFruits << v.toInt();
}

void ProfileManager::setPaletteIndex(int i) { m_paletteIndex = i; m_settings.setValue(u"paletteIndex"_s, i); }
void ProfileManager::setShellIndex(int i) { m_shellIndex = i; m_settings.setValue(u"shellIndex"_s, i); }
void ProfileManager::setLevelIndex(int i) { m_levelIndex = i; m_settings.setValue(u"levelIndex"_s, i); }
void ProfileManager::setVolume(float v) { m_volume = v; m_settings.setValue(u"volume"_s, v); }
void ProfileManager::updateHighScore(int s) { m_highScore = s; m_settings.setValue(u"highScore"_s, s); }

auto ProfileManager::unlockMedal(const QString &t) -> bool {
    if (m_unlockedMedals.contains(t)) return false;
    m_unlockedMedals << t;
    m_settings.setValue(u"medals"_s, m_unlockedMedals);
    emit medalUnlocked(t);
    return true;
}

void ProfileManager::discoverFruit(int t) {
    if (m_discoveredFruits.contains(t)) return;
    m_discoveredFruits << t;
    QVariantList list;
    for (int type : m_discoveredFruits) list << type;
    m_settings.setValue(u"discoveredFruits"_s, list);
}

void ProfileManager::saveStats() {
    m_settings.setValue(u"stats/crashes"_s, m_totalCrashes);
    m_settings.setValue(u"stats/food"_s, m_totalFoodEaten);
    m_settings.setValue(u"stats/ghosts"_s, m_totalGhostTriggers);
}

void ProfileManager::saveSession(int score, const std::deque<QPoint> &body, const QList<QPoint> &obstacles, QPoint food, QPoint dir) {
    m_settings.beginGroup(u"session"_s);
    m_settings.setValue(u"active"_s, true);
    m_settings.setValue(u"score"_s, score);
    m_settings.setValue(u"food"_s, food);
    m_settings.setValue(u"dir"_s, dir);
    QVariantList bodyList; for (const auto &p : body) bodyList << p;
    m_settings.setValue(u"body"_s, bodyList);
    QVariantList obsList; for (const auto &p : obstacles) obsList << p;
    m_settings.setValue(u"obstacles"_s, obsList);
    m_settings.endGroup();
}

void ProfileManager::clearSession() { m_settings.remove(u"session"_s); }
auto ProfileManager::hasSession() const -> bool { return m_settings.value(u"session/active"_s, false).toBool(); }
auto ProfileManager::loadSession() -> QVariantMap {
    QVariantMap d; m_settings.beginGroup(u"session"_s);
    d[u"score"_s] = m_settings.value(u"score"_s);
    d[u"food"_s] = m_settings.value(u"food"_s);
    d[u"dir"_s] = m_settings.value(u"dir"_s);
    d[u"body"_s] = m_settings.value(u"body"_s);
    d[u"obstacles"_s] = m_settings.value(u"obstacles"_s);
    m_settings.endGroup();
    return d;
}
