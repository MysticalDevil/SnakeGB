import QtQuick

Column {
    id: hud
    property bool active: false
    property var gameLogic
    property color ink: "white"
    property string gameFont: ""
    property int highScoreOverride: -1
    property int scoreOverride: -1
    readonly property int displayHighScore: highScoreOverride >= 0
                                             ? highScoreOverride
                                             : (gameLogic ? gameLogic.highScore : 0)
    readonly property int displayScore: scoreOverride >= 0
                                        ? scoreOverride
                                        : (gameLogic ? gameLogic.score : 0)

    anchors.top: parent.top
    anchors.right: parent.right
    anchors.margins: 10
    visible: active
    spacing: 1

    Text { text: `HI ${displayHighScore}`; color: ink; font.family: gameFont; font.pixelSize: 9; font.bold: true; anchors.right: parent.right }
    Text { text: `SC ${displayScore}`; color: ink; font.family: gameFont; font.pixelSize: 13; font.bold: true; anchors.right: parent.right }
}
