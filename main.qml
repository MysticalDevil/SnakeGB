import QtQuick
import QtQuick.Controls

Window {
    id: window
    width: 350
    height: 550
    minimumWidth: width
    maximumWidth: width
    minimumHeight: height
    maximumHeight: height
    visible: true
    title: "GB Snake"
    color: "#c0c0c0"

    Rectangle {
        id: gameBoyBody
        anchors.fill: parent
        color: "#c0c0c0"
        radius: 10
        border.color: "#a0a0a0"
        border.width: 2

        // Screen area
        Rectangle {
            id: screenBorder
            anchors.top: parent.top
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            width: 300
            height: 270
            color: "#404040"
            radius: 10

            Rectangle {
                id: gameScreen
                anchors.centerIn: parent
                width: 240
                height: 216
                color: "#9bbc0f"
                clip: true

                // Snake and food logic same as before, simplified for module
                Grid {
                    anchors.fill: parent
                    columns: gameLogic.boardWidth
                    rows: gameLogic.boardHeight
                    Repeater {
                        model: gameLogic.boardWidth * gameLogic.boardHeight
                        Rectangle {
                            width: gameScreen.width / gameLogic.boardWidth
                            height: gameScreen.height / gameLogic.boardHeight
                            color: "transparent"
                            border.color: "#8bac0f"
                            border.width: 0.2
                        }
                    }
                }

                Rectangle { // Food
                    x: gameLogic.food.x * (gameScreen.width / gameLogic.boardWidth)
                    y: gameLogic.food.y * (gameScreen.height / gameLogic.boardHeight)
                    width: gameScreen.width / gameLogic.boardWidth
                    height: gameScreen.height / gameLogic.boardHeight
                    color: "#0f380f"
                    radius: width / 2
                }

                Repeater { // Snake
                    model: gameLogic.snake
                    Rectangle {
                        x: modelData.x * (gameScreen.width / gameLogic.boardWidth)
                        y: modelData.y * (gameScreen.height / gameLogic.boardHeight)
                        width: gameScreen.width / gameLogic.boardWidth
                        height: gameScreen.height / gameLogic.boardHeight
                        color: index === 0 ? "#0f380f" : "#306230"
                        radius: 1
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#A0000000"
                    visible: gameLogic.gameOver
                    Text {
                        anchors.centerIn: parent
                        text: "GAME OVER\nScore: " + gameLogic.score + "\nPress A to Restart"
                        color: "#9bbc0f"
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Text {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 4
                    text: "Score: " + gameLogic.score
                    color: "#0f380f"
                    font.family: "Courier"
                    font.pixelSize: 14
                    font.bold: true
                }
            }
        }

        DPad {
            id: dpad
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 100
            anchors.left: parent.left
            anchors.leftMargin: 20
            onUpClicked: gameLogic.move(0, -1)
            onDownClicked: gameLogic.move(0, 1)
            onLeftClicked: gameLogic.move(-1, 0)
            onRightClicked: gameLogic.move(1, 0)
        }

        Row {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 130
            anchors.right: parent.right
            anchors.rightMargin: 30
            spacing: 15
            rotation: -15

            GBButton {
                text: "B"
                width: 45; height: 45
            }
            GBButton {
                text: "A"
                width: 45; height: 45
                onClicked: if (gameLogic.gameOver) gameLogic.restart()
            }
        }
    }

    Item {
        focus: true
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Up) gameLogic.move(0, -1);
            else if (event.key === Qt.Key_Down) gameLogic.move(0, 1);
            else if (event.key === Qt.Key_Left) gameLogic.move(-1, 0);
            else if (event.key === Qt.Key_Right) gameLogic.move(1, 0);
            else if (event.key === Qt.Key_A || event.key === Qt.Key_Z) {
                if (gameLogic.gameOver) gameLogic.restart();
            }
        }
    }
}
