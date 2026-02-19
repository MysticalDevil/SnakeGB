import QtQuick
import QtQuick.Controls

Window {
    width: 400
    height: 600
    visible: true
    title: "GameBoy Snake"
    color: "#c0c0c0" // GB shell gray

    Rectangle {
        id: gameBoyBody
        anchors.centerIn: parent
        width: 350
        height: 550
        color: "#c0c0c0"
        radius: 10
        border.color: "#a0a0a0"
        border.width: 2

        // Screen area
        Rectangle {
            id: screenBorder
            anchors.top: parent.top
            anchors.topMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter
            width: 300
            height: 270
            color: "#404040" // Dark gray screen bezel
            radius: 10

            Rectangle {
                id: gameScreen
                anchors.centerIn: parent
                width: 240
                height: 216 // GB original aspect ratio
                color: "#9bbc0f" // Classic green

                // Grid for snake
                Grid {
                    id: grid
                    anchors.fill: parent
                    columns: gameLogic.boardWidth
                    rows: gameLogic.boardHeight
                    spacing: 0

                    Repeater {
                        model: gameLogic.boardWidth * gameLogic.boardHeight
                        Rectangle {
                            width: gameScreen.width / gameLogic.boardWidth
                            height: gameScreen.height / gameLogic.boardHeight
                            color: "transparent"
                            border.color: "#8bac0f"
                            border.width: 0.5
                        }
                    }
                }

                // Food
                Rectangle {
                    x: gameLogic.food.x * (gameScreen.width / gameLogic.boardWidth)
                    y: gameLogic.food.y * (gameScreen.height / gameLogic.boardHeight)
                    width: gameScreen.width / gameLogic.boardWidth
                    height: gameScreen.height / gameLogic.boardHeight
                    color: "#0f380f"
                    radius: width / 2
                }

                // Snake
                Repeater {
                    model: gameLogic.snake
                    Rectangle {
                        x: modelData.x * (gameScreen.width / gameLogic.boardWidth)
                        y: modelData.y * (gameScreen.height / gameLogic.boardHeight)
                        width: gameScreen.width / gameLogic.boardWidth
                        height: gameScreen.height / gameLogic.boardHeight
                        color: index === 0 ? "#0f380f" : "#306230"
                        radius: 2
                    }
                }

                // Game Over Overlay
                Rectangle {
                    anchors.fill: parent
                    color: "#80000000"
                    visible: gameLogic.gameOver
                    Text {
                        anchors.centerIn: parent
                        text: "GAME OVER
Score: " + gameLogic.score + "
Press A to Restart"
                        color: "#9bbc0f"
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                // Score Display
                Text {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 5
                    text: "Score: " + gameLogic.score
                    color: "#0f380f"
                    font.family: "Courier"
                    font.bold: true
                }
            }
        }

        // D-Pad
        Item {
            id: dpad
            width: 100
            height: 100
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 80
            anchors.left: parent.left
            anchors.leftMargin: 30

            // Horizontal
            Rectangle {
                width: 90; height: 30; color: "#333"; anchors.centerIn: parent; radius: 5
            }
            // Vertical
            Rectangle {
                width: 30; height: 90; color: "#333"; anchors.centerIn: parent; radius: 5
            }

            // Buttons for touch/mouse
            MouseArea { anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter; width: 30; height: 30; onClicked: gameLogic.move(0, -1) }
            MouseArea { anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter; width: 30; height: 30; onClicked: gameLogic.move(0, 1) }
            MouseArea { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; width: 30; height: 30; onClicked: gameLogic.move(-1, 0) }
            MouseArea { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; width: 30; height: 30; onClicked: gameLogic.move(1, 0) }
        }

        // A/B Buttons
        Row {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 100
            anchors.right: parent.right
            anchors.rightMargin: 30
            spacing: 20
            rotation: -15

            // B Button
            Column {
                spacing: 5
                Rectangle { width: 45; height: 45; radius: 22.5; color: "#a01040"; border.color: "#333"; border.width: 2 }
                Text { text: "B"; anchors.horizontalCenter: parent.horizontalCenter; font.bold: true }
            }
            // A Button
            Column {
                spacing: 5
                Rectangle {
                    width: 45; height: 45; radius: 22.5; color: "#a01040"; border.color: "#333"; border.width: 2
                    MouseArea { anchors.fill: parent; onClicked: if (gameLogic.gameOver) gameLogic.restart() }
                }
                Text { text: "A"; anchors.horizontalCenter: parent.horizontalCenter; font.bold: true }
            }
        }
    }

    // Keyboard support
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
