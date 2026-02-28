import QtQuick

Item {
    id: root
    property var theme
    signal logoClicked()

    implicitWidth: 188
    implicitHeight: 24

    MouseArea {
        anchors.fill: parent
        onClicked: root.logoClicked()
    }

    Row {
        anchors.top: parent.top
        anchors.left: parent.left
        spacing: 2

        Text {
            anchors.baseline: snakeText.baseline
            text: "Nintendo"
            color: theme.brandInk
            font.family: "Trebuchet MS"
            font.pixelSize: 11
            font.bold: true
            opacity: 0.92
        }

        Text {
            id: snakeText
            text: "GAME"
            color: theme.brandInk
            font.family: "Trebuchet MS"
            font.pixelSize: 17
            font.bold: true
            opacity: 0.95
        }

        Text {
            anchors.baseline: snakeText.baseline
            text: "BOY"
            color: theme.logoAccent
            font.family: "Trebuchet MS"
            font.pixelSize: 22
            font.bold: true
            font.italic: true
            opacity: 0.98
        }
    }
}
