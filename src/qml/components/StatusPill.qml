import QtQuick

Rectangle {
    id: pill

    property string label: ""
    property string gameFont: ""
    property color textColor: "black"
    property color borderColor: "black"
    property int borderLineWidth: 1

    radius: 3
    border.color: pill.borderColor
    border.width: pill.borderLineWidth

    Text {
        anchors.centerIn: parent
        text: pill.label
        color: pill.textColor
        font.family: pill.gameFont
        font.pixelSize: 8
        font.bold: true
    }
}
