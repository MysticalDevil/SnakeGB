import QtQuick

Column {
    id: hud
    property bool active: false
    property var gameLogic
    property color ink: "white"
    property string gameFont: ""

    anchors.top: parent.top
    anchors.right: parent.right
    anchors.margins: 10
    z: 500
    visible: active

    Text { text: `HI ${gameLogic.highScore}`; color: ink; font.family: gameFont; font.pixelSize: 8; anchors.right: parent.right }
    Text { text: `SC ${gameLogic.score}`; color: ink; font.family: gameFont; font.pixelSize: 12; font.bold: true; anchors.right: parent.right }
}
