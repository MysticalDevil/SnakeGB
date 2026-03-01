#pragma once

#include <QJSEngine>
#include <QList>
#include <QPoint>
#include <QStringView>

namespace snakegb::adapter {

[[nodiscard]] auto tryApplyOnTickScript(QJSEngine &engine, int gameTickCounter, QList<QPoint> &obstacles) -> bool;
[[nodiscard]] auto applyDynamicLevelFallback(QStringView levelName, int gameTickCounter,
                                             QList<QPoint> &obstacles) -> bool;
[[nodiscard]] auto applyLevelScriptStep(QJSEngine &engine, QStringView levelName, int gameTickCounter,
                                        QList<QPoint> &obstacles) -> bool;

} // namespace snakegb::adapter
