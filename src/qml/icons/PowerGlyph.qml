import QtQuick
import "PowerPainter.js" as PowerPainter

Canvas {
    id: powerGlyph

    property int powerType: 0
    property color glyphColor: "white"

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        PowerPainter.draw(ctx, width, height, powerType, glyphColor)
    }

    Component.onCompleted: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onVisibleChanged: if (visible) requestPaint()
    onPowerTypeChanged: requestPaint()
    onGlyphColorChanged: requestPaint()
}
