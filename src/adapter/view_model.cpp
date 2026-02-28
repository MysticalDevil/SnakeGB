#include "adapter/game_logic.h"

#include "adapter/library_models.h"
#include "adapter/profile_bridge.h"

#include <algorithm>

using namespace Qt::StringLiterals;

auto GameLogic::highScore() const -> int
{
    return snakegb::adapter::highScore(m_profileManager.get());
}

auto GameLogic::palette() const -> QVariantList
{
    static const QList<QVariantList> sets = {
        {u"#213319"_s, u"#39582a"_s, u"#92b65a"_s, u"#f2f8e4"_s}, // Original DMG
        {u"#1d211b"_s, u"#4f5648"_s, u"#b8bead"_s, u"#edf1e8"_s}, // Pocket B&W
        {u"#2a1a06"_s, u"#6d4412"_s, u"#c89030"_s, u"#fff4c5"_s}, // Sunset Glow
        {u"#2b0a0a"_s, u"#6c2424"_s, u"#c53f3f"_s, u"#ffe7df"_s}, // Pixel Heat
        {u"#08272d"_s, u"#184c53"_s, u"#67c1c8"_s, u"#dcfbff"_s}  // Neon Ice
    };
    const qsizetype idx =
        static_cast<qsizetype>(snakegb::adapter::paletteIndex(m_profileManager.get())) %
        sets.size();
    return sets[idx];
}

auto GameLogic::paletteName() const -> QString
{
    static const QStringList names = {u"Original DMG"_s, u"Pocket B&W"_s, u"Sunset Glow"_s,
                                      u"Pixel Heat"_s, u"Neon Ice"_s};
    const qsizetype idx =
        static_cast<qsizetype>(snakegb::adapter::paletteIndex(m_profileManager.get())) %
        names.size();
    return names[idx];
}

auto GameLogic::obstacles() const -> QVariantList
{
    QVariantList list;
    for (const auto &point : m_session.obstacles) {
        list.append(point);
    }
    return list;
}

auto GameLogic::shellColor() const -> QColor
{
    static const QList<QColor> colors = {
        QColor(u"#0b8f92"_s), QColor(u"#c9cacc"_s), QColor(u"#9f8bc1"_s), QColor(u"#b84864"_s),
        QColor(u"#00837b"_s), QColor(u"#f59e0b"_s), QColor(u"#4b5563"_s)};
    const qsizetype idx =
        static_cast<qsizetype>(snakegb::adapter::shellIndex(m_profileManager.get())) %
        colors.size();
    return colors[idx];
}

auto GameLogic::shellName() const -> QString
{
    static const QStringList names = {u"Matte Silver"_s, u"Cloud White"_s, u"Lavender"_s,
                                      u"Crimson"_s,      u"Teal"_s,        u"Sunburst"_s,
                                      u"Graphite"_s};
    const qsizetype idx =
        static_cast<qsizetype>(snakegb::adapter::shellIndex(m_profileManager.get())) % names.size();
    return names[idx];
}

auto GameLogic::ghost() const -> QVariantList
{
    if (m_state == Replaying) {
        return {};
    }
    QVariantList list;
    const int len = m_snakeModel.rowCount();
    const int start = std::max(0, m_ghostFrameIndex - len + 1);
    for (int i = m_ghostFrameIndex; i >= start && i < m_bestRecording.size(); --i) {
        list.append(m_bestRecording[i]);
    }
    return list;
}

auto GameLogic::musicEnabled() const noexcept -> bool
{
    return m_musicEnabled;
}

auto GameLogic::achievements() const -> QVariantList
{
    QVariantList list;
    for (const auto &medal : snakegb::adapter::unlockedMedals(m_profileManager.get())) {
        list.append(medal);
    }
    return list;
}

// NOLINTNEXTLINE(readability-convert-member-functions-to-static)
auto GameLogic::medalLibrary() const -> QVariantList
{
    return snakegb::adapter::buildMedalLibraryModel();
}

auto GameLogic::coverage() const noexcept -> float
{
    return static_cast<float>(m_snakeModel.rowCount()) / (BOARD_WIDTH * BOARD_HEIGHT);
}

auto GameLogic::volume() const -> float
{
    return snakegb::adapter::volume(m_profileManager.get());
}

void GameLogic::setVolume(float value)
{
    snakegb::adapter::setVolume(m_profileManager.get(), value);
    m_audioBus.applyVolume(value);
    emit volumeChanged();
}

auto GameLogic::fruitLibrary() const -> QVariantList
{
    const QList<int> discovered = snakegb::adapter::discoveredFruits(m_profileManager.get());
    return snakegb::adapter::buildFruitLibraryModel(discovered);
}
