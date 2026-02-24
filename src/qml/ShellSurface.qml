import QtQuick

Item {
    id: surface
    property color shellColor: "#4aa3a8"
    property var shellTheme: ({})
    property real radius: 16

    Rectangle {
        anchors.fill: parent
        radius: surface.radius
        color: "transparent"
        border.color: Qt.lighter(surface.shellColor, 1.22)
        border.width: 1
        opacity: 0.5
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: surface.radius - 2
        gradient: Gradient {
            GradientStop { position: 0.0; color: surface.shellTheme.shellHighlight }
            GradientStop { position: 0.28; color: Qt.lighter(surface.shellColor, 1.06) }
            GradientStop { position: 1.0; color: surface.shellTheme.shellShade }
        }
        opacity: 0.42
    }

    Repeater {
        model: 48
        delegate: Rectangle {
            width: 2
            height: 2
            radius: 1
            x: 10 + (index % 12) * 28
            y: 14 + Math.floor(index / 12) * 72
            color: Qt.rgba(0, 0, 0, 0.06)
        }
    }
}
