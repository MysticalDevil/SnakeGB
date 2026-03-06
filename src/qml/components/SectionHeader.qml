import QtQuick

Rectangle {
    id: sectionHeader

    property string titleText: ""
    property string subtitleText: ""
    property string gameFont: ""
    property color textColor: "white"
    property color subtitleColor: "white"

    radius: 3
    border.width: 1

    Column {
        anchors.centerIn: parent
        spacing: 0

        Text {
            text: sectionHeader.titleText
            color: sectionHeader.textColor
            font.family: sectionHeader.gameFont
            font.pixelSize: 12
            font.bold: true
        }

        Text {
            visible: sectionHeader.subtitleText.length > 0
            text: sectionHeader.subtitleText
            color: sectionHeader.subtitleColor
            font.family: sectionHeader.gameFont
            font.pixelSize: 7
            font.bold: true
        }
    }
}
