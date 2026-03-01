#pragma once

#include "core/level/runtime.h"

#include <optional>
#include <QString>

namespace snakegb::services
{

class LevelRepository
{
public:
    explicit LevelRepository(QString resourcePath = QStringLiteral("qrc:/src/levels/levels.json"),
                             int fallbackCount = 6);

    [[nodiscard]] auto loadResolvedLevel(int levelIndex) const
        -> std::optional<snakegb::core::ResolvedLevelData>;
    [[nodiscard]] auto levelCount() const -> int;

private:
    QString m_resourcePath;
    int m_fallbackCount = 6;
};

} // namespace snakegb::services
