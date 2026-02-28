import QtQuick

Item {
    id: root
    property var theme
    default property alias content: screenSlot.data

    width: 300
    height: 270

    Rectangle {
        anchors.fill: parent
        color: theme.bezelBase
        radius: 12
        border.color: theme.bezelEdge
        border.width: 2

        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            radius: parent.radius - 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.lighter(theme.bezelBase, 1.18) }
                GradientStop { position: 1.0; color: Qt.darker(theme.bezelBase, 1.12) }
            }
            opacity: 0.72
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 10
            radius: 8
            color: theme.bezelInner
            border.color: theme.bezelInnerBorder
            border.width: 1
        }

        Item {
            id: screenSlot
            anchors.centerIn: parent
            width: 240
            height: 216
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.top: parent.top
            anchors.topMargin: 11
            text: "DOT MATRIX WITH STEREO SOUND"
            color: theme.labelInk
            font.pixelSize: 8
            font.bold: false
            opacity: 0.9
        }
    }
}
