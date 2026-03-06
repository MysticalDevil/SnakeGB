import QtQuick
import "AchievementPainter.js" as AchievementPainter

Canvas {
    id: achievementGlyph

    property string achievementId: ""
    property color glyphColor: "white"

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        AchievementPainter.draw(ctx, width, height, achievementId, glyphColor)
    }

    Component.onCompleted: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onVisibleChanged: if (visible) requestPaint()
    onAchievementIdChanged: requestPaint()
    onGlyphColorChanged: requestPaint()
}
