import QtQuick

Item {
    id: root
    property var theme
    signal logoClicked()

    implicitWidth: 200
    implicitHeight: 36

    Column {
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: "SnakeGB"
            color: theme.brandInk
            font.family: "Monospace"
            font.pixelSize: 14
            font.bold: true
            font.letterSpacing: 2
            opacity: 0.68

            MouseArea {
                anchors.fill: parent
                onClicked: root.logoClicked()
            }
        }

        Text {
            text: "Portable Entertainment System"
            color: theme.subtitleInk
            font.pixelSize: 8
            font.italic: true
            opacity: 0.6
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
