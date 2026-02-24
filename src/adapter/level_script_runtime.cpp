#include "level_script_runtime.h"

#include "core/level_runtime.h"

using namespace Qt::StringLiterals;

namespace snakegb::adapter {

auto tryApplyOnTickScript(QJSEngine &engine, const int gameTickCounter, QList<QPoint> &obstacles) -> bool {
    const QJSValue onTick = engine.globalObject().property(u"onTick"_s);
    if (!onTick.isCallable()) {
        return false;
    }
    QJSValueList args;
    args << gameTickCounter;
    const QJSValue result = onTick.call(args);
    if (!result.isArray()) {
        return false;
    }

    QList<QPoint> parsedObstacles;
    const int len = result.property(u"length"_s).toInt();
    parsedObstacles.reserve(len);
    for (int i = 0; i < len; ++i) {
        const QJSValue item = result.property(i);
        parsedObstacles.append(QPoint(item.property(u"x"_s).toInt(), item.property(u"y"_s).toInt()));
    }
    obstacles = parsedObstacles;
    return true;
}

auto applyDynamicLevelFallback(const QStringView levelName, const int gameTickCounter, QList<QPoint> &obstacles)
    -> bool {
    const auto dynamicObstacles = snakegb::core::dynamicObstaclesForLevel(levelName, gameTickCounter);
    if (!dynamicObstacles.has_value()) {
        return false;
    }
    obstacles = dynamicObstacles.value();
    return true;
}

auto applyLevelScriptStep(QJSEngine &engine, const QStringView levelName, const int gameTickCounter,
                          QList<QPoint> &obstacles) -> bool
{
    if (snakegb::adapter::tryApplyOnTickScript(engine, gameTickCounter, obstacles)) {
        return true;
    }
    return snakegb::adapter::applyDynamicLevelFallback(levelName, gameTickCounter, obstacles);
}

} // namespace snakegb::adapter
