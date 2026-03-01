#pragma once

#include "core/replay/types.h"

#include <QList>
#include <QPoint>
#include <QString>
#include <QStringView>

namespace snakegb::adapter {

struct GhostSnapshot {
    QList<QPoint> recording;
    uint randomSeed = 0;
    QList<ReplayFrame> inputHistory;
    int levelIndex = 0;
    QList<ChoiceRecord> choiceHistory;
};

[[nodiscard]] auto ghostFilePathForDirectory(QStringView appDataDirectory) -> QString;
[[nodiscard]] auto loadGhostSnapshotFromFile(QStringView filePath, GhostSnapshot &snapshot) -> bool;
[[nodiscard]] auto saveGhostSnapshotToFile(QStringView filePath, const GhostSnapshot &snapshot) -> bool;
[[nodiscard]] auto loadGhostSnapshot(GhostSnapshot &snapshot) -> bool;
[[nodiscard]] auto saveGhostSnapshot(const GhostSnapshot &snapshot) -> bool;

} // namespace snakegb::adapter
