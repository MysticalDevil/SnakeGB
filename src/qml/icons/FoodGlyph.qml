import QtQuick
import "FoodPainter.js" as FoodPainter

Canvas {
    id: foodGlyph

    property color strokeColor: "black"
    property color coreColor: "white"
    property color highlightColor: "white"
    property color stemColor: "black"
    property color sparkColor: "white"

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        FoodPainter.draw(ctx, width, height, {
                             stroke: strokeColor,
                             core: coreColor,
                             highlight: highlightColor,
                             stem: stemColor,
                             spark: sparkColor
                         })
    }

    Component.onCompleted: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onVisibleChanged: if (visible) requestPaint()
    onStrokeColorChanged: requestPaint()
    onCoreColorChanged: requestPaint()
    onHighlightColorChanged: requestPaint()
    onStemColorChanged: requestPaint()
    onSparkColorChanged: requestPaint()
}
