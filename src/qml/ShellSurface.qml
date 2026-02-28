import QtQuick
import QtQuick.Shapes

Item {
    id: surface
    property color shellColor: "#4aa3a8"
    property var shellTheme: ({})
    property real smallRadius: 13
    property real largeBottomRightRadius: 44

    readonly property real inset: 2
    readonly property real innerSmallRadius: Math.max(2, smallRadius - inset)
    readonly property real innerLargeRadius: Math.max(8, largeBottomRightRadius - inset)
    layer.enabled: true
    layer.smooth: true
    layer.samples: 4

    Shape {
        anchors.fill: parent
        antialiasing: true
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: surface.shellTheme.shellBorder
            strokeWidth: 2
            fillColor: surface.shellColor
            startX: surface.smallRadius
            startY: 0
            PathLine { x: surface.width - surface.smallRadius; y: 0 }
            PathArc {
                x: surface.width
                y: surface.smallRadius
                radiusX: surface.smallRadius
                radiusY: surface.smallRadius
            }
            PathLine {
                x: surface.width
                y: surface.height - surface.largeBottomRightRadius
            }
            PathArc {
                x: surface.width - surface.largeBottomRightRadius
                y: surface.height
                radiusX: surface.largeBottomRightRadius
                radiusY: surface.largeBottomRightRadius
            }
            PathLine { x: surface.smallRadius; y: surface.height }
            PathArc {
                x: 0
                y: surface.height - surface.smallRadius
                radiusX: surface.smallRadius
                radiusY: surface.smallRadius
            }
            PathLine { x: 0; y: surface.smallRadius }
            PathArc {
                x: surface.smallRadius
                y: 0
                radiusX: surface.smallRadius
                radiusY: surface.smallRadius
            }
        }
    }

    Shape {
        anchors.fill: parent
        anchors.margins: surface.inset
        antialiasing: true
        preferredRendererType: Shape.CurveRenderer
        opacity: 0.32

        ShapePath {
            strokeColor: Qt.rgba(1, 1, 1, 0.10)
            strokeWidth: 1
            fillColor: Qt.rgba(surface.shellTheme.shellHighlight.r,
                               surface.shellTheme.shellHighlight.g,
                               surface.shellTheme.shellHighlight.b,
                               0.34)
            startX: surface.innerSmallRadius
            startY: 0
            PathLine { x: surface.width - (surface.inset * 2) - surface.innerSmallRadius; y: 0 }
            PathArc {
                x: surface.width - (surface.inset * 2)
                y: surface.innerSmallRadius
                radiusX: surface.innerSmallRadius
                radiusY: surface.innerSmallRadius
            }
            PathLine {
                x: surface.width - (surface.inset * 2)
                y: surface.height - (surface.inset * 2) - surface.innerLargeRadius
            }
            PathArc {
                x: surface.width - (surface.inset * 2) - surface.innerLargeRadius
                y: surface.height - (surface.inset * 2)
                radiusX: surface.innerLargeRadius
                radiusY: surface.innerLargeRadius
            }
            PathLine { x: surface.innerSmallRadius; y: surface.height - (surface.inset * 2) }
            PathArc {
                x: 0
                y: surface.height - (surface.inset * 2) - surface.innerSmallRadius
                radiusX: surface.innerSmallRadius
                radiusY: surface.innerSmallRadius
            }
            PathLine { x: 0; y: surface.innerSmallRadius }
            PathArc {
                x: surface.innerSmallRadius
                y: 0
                radiusX: surface.innerSmallRadius
                radiusY: surface.innerSmallRadius
            }
        }
    }

    Item {
        anchors.fill: parent
        opacity: 0.08

        Repeater {
            model: 36
            delegate: Rectangle {
                width: 2
                height: 2
                radius: 1
                x: 12 + (index % 9) * 36
                y: 14 + Math.floor(index / 9) * 96
                color: "#000000"
            }
        }
    }
}
