#include "adapter/ghost/store.h"

#include <QDataStream>
#include <QDir>
#include <QFile>
#include <QStandardPaths>

using namespace Qt::StringLiterals;

namespace snakegb::adapter {
namespace {
constexpr quint32 GhostFileMagicV2 = 0x534E4B02;
constexpr quint32 GhostFileMagicV4 = 0x534E4B04;
} // namespace

auto ghostFilePathForDirectory(const QStringView appDataDirectory) -> QString {
    QDir dir(appDataDirectory.toString());
    if (!dir.exists()) {
        dir.mkpath(u"."_s);
    }
    return dir.filePath(u"ghost.dat"_s);
}

auto loadGhostSnapshotFromFile(const QStringView filePath, GhostSnapshot &snapshot) -> bool {
    QFile file(filePath.toString());
    if (!file.open(QIODevice::ReadOnly)) {
        return false;
    }

    QDataStream in(&file);
    quint32 magic = 0;
    in >> magic;
    if (magic == GhostFileMagicV4) {
        in >> snapshot.recording >> snapshot.randomSeed >> snapshot.inputHistory >> snapshot.levelIndex >>
            snapshot.choiceHistory;
        return true;
    }
    if (magic >= GhostFileMagicV2) {
        in >> snapshot.recording >> snapshot.randomSeed >> snapshot.inputHistory >> snapshot.levelIndex;
        snapshot.choiceHistory.clear();
        return true;
    }
    return false;
}

auto saveGhostSnapshotToFile(const QStringView filePath, const GhostSnapshot &snapshot) -> bool {
    QFile file(filePath.toString());
    if (!file.open(QIODevice::WriteOnly)) {
        return false;
    }
    QDataStream out(&file);
    out << GhostFileMagicV4 << snapshot.recording << snapshot.randomSeed << snapshot.inputHistory
        << snapshot.levelIndex << snapshot.choiceHistory;
    return out.status() == QDataStream::Ok;
}

auto loadGhostSnapshot(GhostSnapshot &snapshot) -> bool {
    const QString appDataDirectory = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    return loadGhostSnapshotFromFile(ghostFilePathForDirectory(appDataDirectory), snapshot);
}

auto saveGhostSnapshot(const GhostSnapshot &snapshot) -> bool {
    const QString appDataDirectory = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    return saveGhostSnapshotToFile(ghostFilePathForDirectory(appDataDirectory), snapshot);
}

} // namespace snakegb::adapter
