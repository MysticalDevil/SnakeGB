import QtQuick
import QtQuick.Controls

Window {
    id: window
    width: 350; height: 550
    minimumWidth: 350; maximumWidth: 350
    minimumHeight: 550; maximumHeight: 550
    visible: true; title: "Snake GB Edition"
    color: "#c0c0c0"

    // 屏幕震动逻辑
    Connections {
        target: gameLogic
        function onRequestFeedback() {
            screenShake.start()
        }
    }

    SequentialAnimation {
        id: screenShake
        NumberAnimation { target: gameBoyBody; property: "x"; from: 0; to: 2; duration: 50 }
        NumberAnimation { target: gameBoyBody; property: "x"; from: 2; to: -2; duration: 50 }
        NumberAnimation { target: gameBoyBody; property: "x"; from: -2; to: 0; duration: 50 }
    }

    Rectangle {
        id: gameBoyBody
        anchors.fill: parent
        color: "#c0c0c0"
        radius: 10; border.color: "#a0a0a0"; border.width: 2

        Rectangle {
            id: screenBorder
            anchors.top: parent.top; anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            width: 300; height: 270; color: "#404040"; radius: 10

            Rectangle {
                id: gameScreen
                anchors.centerIn: parent
                width: 240; height: 216; color: "#9bbc0f"; clip: true

                // 背景网格 (优化：使用单张画布减少节点)
                Canvas {
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.strokeStyle = "#8bac0f";
                        ctx.lineWidth = 1;
                        for(var i=0; i<=gameLogic.boardWidth; i++) {
                            var x = i * (width / gameLogic.boardWidth);
                            ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, height); ctx.stroke();
                        }
                        for(var j=0; j<=gameLogic.boardHeight; j++) {
                            var y = j * (height / gameLogic.boardHeight);
                            ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke();
                        }
                    }
                }

                // 食物
                Rectangle {
                    visible: gameLogic.state !== 0
                    x: gameLogic.food.x * (gameScreen.width / gameLogic.boardWidth)
                    y: gameLogic.food.y * (gameScreen.height / gameLogic.boardHeight)
                    width: gameScreen.width / gameLogic.boardWidth
                    height: gameScreen.height / gameLogic.boardHeight
                    color: "#0f380f"; radius: width / 2
                }

                // 蛇 (优化：使用 Model，避免全量刷新抖动)
                Repeater {
                    model: gameLogic.snakeModel
                    delegate: Rectangle {
                        x: model.pos.x * (gameScreen.width / gameLogic.boardWidth)
                        y: model.pos.y * (gameScreen.height / gameLogic.boardHeight)
                        width: gameScreen.width / gameLogic.boardWidth
                        height: gameScreen.height / gameLogic.boardHeight
                        color: index === 0 ? "#0f380f" : "#306230"
                        radius: 1
                    }
                }

                // --- 菜单与状态 ---
                Rectangle {
                    anchors.fill: parent; color: "#9bbc0f"
                    visible: gameLogic.state === 0
                    Column {
                        anchors.centerIn: parent; spacing: 20
                        Text { text: "S N A K E"; font.pixelSize: 32; font.bold: true; color: "#0f380f" }
                        Text { 
                            text: "Press A to Start"; font.pixelSize: 14; color: "#0f380f"
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { from: 1; to: 0; duration: 800 }
                                NumberAnimation { from: 0; to: 1; duration: 800 }
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent; color: "#A0000000"
                    visible: gameLogic.state === 2
                    Text {
                        anchors.centerIn: parent; color: "#9bbc0f"; font.pixelSize: 18
                        text: "GAME OVER\nScore: " + gameLogic.score + "\nPress A to Restart"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Text {
                    anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 4
                    visible: gameLogic.state !== 0; color: "#0f380f"; font.bold: true
                    text: "Score: " + gameLogic.score
                }
            }
        }

        DPad {
            anchors.bottom: parent.bottom; anchors.bottomMargin: 100
            anchors.left: parent.left; anchors.leftMargin: 20
            onUpClicked: gameLogic.move(0, -1)
            onDownClicked: gameLogic.move(0, 1)
            onLeftClicked: gameLogic.move(-1, 0)
            onRightClicked: gameLogic.move(1, 0)
        }

        Row {
            anchors.bottom: parent.bottom; anchors.bottomMargin: 130
            anchors.right: parent.right; anchors.rightMargin: 30; spacing: 15; rotation: -15
            GBButton { text: "B" }
            GBButton { 
                text: "A"
                onClicked: {
                    if (gameLogic.state === 0) gameLogic.startGame();
                    else if (gameLogic.state === 2) gameLogic.restart();
                }
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
            else if (event.key === Qt.Key_A || event.key === Qt.Key_Return || event.key === Qt.Key_Z) {
                if (gameLogic.state === 0) gameLogic.startGame();
                else if (gameLogic.state === 2) gameLogic.restart();
            }
        }
    }
}
