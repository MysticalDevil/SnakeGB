import QtQuick

Item {
    id: root
    property var theme
    signal logoClicked()

    implicitWidth: 200
    implicitHeight: 44

    Column {
        anchors.centerIn: parent
        width: parent.width
        spacing: 6

        Text {
            text: "SnakeGB"
            width: parent.width
            color: theme.brandInk
            font.family: "Monospace"
            font.pixelSize: 14
            font.bold: true
            font.letterSpacing: 2
            horizontalAlignment: Text.AlignHCenter
            opacity: 0.82

            MouseArea {
                anchors.fill: parent
                onClicked: root.logoClicked()
            }
        }

        Text {
            text: "Portable Entertainment System"
            width: parent.width
            color: theme.subtitleInk
            font.pixelSize: 8
            font.italic: true
            horizontalAlignment: Text.AlignHCenter
            opacity: 0.76
        }
    }
}
