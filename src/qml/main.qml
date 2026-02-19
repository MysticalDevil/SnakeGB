import QtQuick
import QtQuick.Controls

Window {
    id: window
    width: 350; height: 550
    minimumWidth: 350; maximumWidth: 350; minimumHeight: 550; maximumHeight: 550
    visible: true; title: "Snake GB Edition"
    color: "#c0c0c0"

    Connections {
        target: gameLogic
        function onRequestFeedback() { screenShake.start() }
    }

    SequentialAnimation {
        id: screenShake
        NumberAnimation { target: gameBoyBody; property: "x"; from: 0; to: 2; duration: 40 }
        NumberAnimation { target: gameBoyBody; property: "x"; from: 2; to: -2; duration: 40 }
        NumberAnimation { target: gameBoyBody; property: "x"; from: -2; to: 0; duration: 40 }
    }

    Rectangle {
        id: gameBoyBody
        anchors.fill: parent; color: "#c0c0c0"; radius: 10
        border.color: "#a0a0a0"; border.width: 2

        // Screen
        Rectangle {
            id: screenBorder
            anchors.top: parent.top; anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            width: 300; height: 270; color: "#404040"; radius: 10

            Rectangle {
                id: gameScreen
                anchors.centerIn: parent
                width: 240; height: 216; color: "#9bbc0f"; clip: true

                Canvas {
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.strokeStyle = "#8bac0f";
                        ctx.lineWidth = 1;
                        for(var i=0; i<=gameLogic.boardWidth; i++) {
                            var x = i * (width / gameLogic.boardWidth);
                            ctx.beginPath();
                            ctx.moveTo(x, 0);
                            ctx.lineTo(x, height);
                            ctx.stroke();
                        }
                        for(var j=0; j<=gameLogic.boardHeight; j++) {
                            var y = j * (height / gameLogic.boardHeight);
                            ctx.beginPath();
                            ctx.moveTo(0, y);
                            ctx.lineTo(width, y);
                            ctx.stroke();
                        }
                    }
                }

                Rectangle { // Food
                    visible: gameLogic.state !== 0
                    x: gameLogic.food.x * (gameScreen.width / gameLogic.boardWidth); y: gameLogic.food.y * (gameScreen.height / gameLogic.boardHeight)
                    width: gameScreen.width / gameLogic.boardWidth; height: gameScreen.height / gameLogic.boardHeight
                    color: "#0f380f"; radius: width / 2
                }

                Repeater { // Snake
                    model: gameLogic.snakeModel
                    delegate: Rectangle {
                        x: model.pos.x * (gameScreen.width / gameLogic.boardWidth); y: model.pos.y * (gameScreen.height / gameLogic.boardHeight)
                        width: gameScreen.width / gameLogic.boardWidth; height: gameScreen.height / gameLogic.boardHeight
                        color: index === 0 ? "#0f380f" : "#306230"; radius: 1
                    }
                }

                // HUD
                Column {
                    anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 4
                    visible: gameLogic.state !== 0
                    Text { text: "HI: " + gameLogic.highScore; color: "#0f380f"; font.pixelSize: 10; font.bold: true; horizontalAlignment: Text.AlignRight }
                    Text { text: "SC: " + gameLogic.score; color: "#0f380f"; font.pixelSize: 12; font.bold: true; horizontalAlignment: Text.AlignRight }
                }

                // Overlays
                Rectangle { // Menu
                    anchors.fill: parent; color: "#9bbc0f"; visible: gameLogic.state === 0
                    Column {
                        anchors.centerIn: parent; spacing: 10
                        Text { text: "S N A K E"; font.pixelSize: 32; font.bold: true; color: "#0f380f" }
                        Text { text: "HI-SCORE: " + gameLogic.highScore; font.pixelSize: 14; color: "#0f380f"; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "Press Start"; font.pixelSize: 14; color: "#0f380f"; anchors.horizontalCenter: parent.horizontalCenter; SequentialAnimation on opacity { loops: Animation.Infinite; NumberAnimation { from: 1; to: 0; duration: 800 }; NumberAnimation { from: 0; to: 1; duration: 800 } } }
                    }
                }

                Rectangle { // Pause
                    anchors.fill: parent; color: "#809bbc0f"; visible: gameLogic.state === 2
                    Text { anchors.centerIn: parent; text: "PAUSED"; font.pixelSize: 24; font.bold: true; color: "#0f380f" }
                }

                Rectangle { // Game Over
                    anchors.fill: parent; color: "#A0000000"; visible: gameLogic.state === 3
                    Text { anchors.centerIn: parent; color: "#9bbc0f"; font.pixelSize: 18; text: "GAME OVER\nScore: " + gameLogic.score + "\nPress Start to Retry"; horizontalAlignment: Text.AlignHCenter }
                }
            }
        }

        // Controls
        DPad {
            id: dpadUI; anchors.bottom: parent.bottom; anchors.bottomMargin: 110; anchors.left: parent.left; anchors.leftMargin: 25
            onUpClicked: gameLogic.move(0, -1); onDownClicked: gameLogic.move(0, 1); onLeftClicked: gameLogic.move(-1, 0); onRightClicked: gameLogic.move(1, 0)
        }

        Row {
            anchors.bottom: parent.bottom; anchors.bottomMargin: 140; anchors.right: parent.right; anchors.rightMargin: 30; spacing: 15; rotation: -15
            GBButton { id: bBtnUI; text: "B" }
            GBButton { id: aBtnUI; text: "A"; onClicked: { if (gameLogic.state === 0) gameLogic.startGame(); else if (gameLogic.state === 3) gameLogic.restart(); } }
        }

        Row {
            anchors.bottom: parent.bottom; anchors.bottomMargin: 40; anchors.horizontalCenter: parent.horizontalCenter; spacing: 30
            SmallButton { id: selectBtnUI; text: "SELECT" }
            SmallButton { 
                id: startBtnUI; text: "START"
                onClicked: {
                    if (gameLogic.state === 0) gameLogic.startGame();
                    else if (gameLogic.state === 3) gameLogic.restart();
                    else gameLogic.togglePause();
                }
            }
        }
    }

    Item {
        focus: true
        Keys.onPressed: (event) => {
            if (event.isAutoRepeat) return;
            if (event.key === Qt.Key_Up) { dpadUI.upPressed = true; gameLogic.move(0, -1); }
            else if (event.key === Qt.Key_Down) { dpadUI.downPressed = true; gameLogic.move(0, 1); }
            else if (event.key === Qt.Key_Left) { dpadUI.leftPressed = true; gameLogic.move(-1, 0); }
            else if (event.key === Qt.Key_Right) { dpadUI.rightPressed = true; gameLogic.move(1, 0); }
            else if (event.key === Qt.Key_S || event.key === Qt.Key_Return) { 
                startBtnUI.isPressed = true; 
                if (gameLogic.state === 0) gameLogic.startGame();
                else if (gameLogic.state === 3) gameLogic.restart();
                else gameLogic.togglePause();
            }
            else if (event.key === Qt.Key_A || event.key === Qt.Key_Z) aBtnUI.isPressed = true;
            else if (event.key === Qt.Key_B || event.key === Qt.Key_X) bBtnUI.isPressed = true;
            else if (event.key === Qt.Key_Shift) selectBtnUI.isPressed = true;
        }
        Keys.onReleased: (event) => {
            if (event.isAutoRepeat) return;
            if (event.key === Qt.Key_Up) dpadUI.upPressed = false;
            else if (event.key === Qt.Key_Down) dpadUI.downPressed = false;
            else if (event.key === Qt.Key_Left) dpadUI.leftPressed = false;
            else if (event.key === Qt.Key_Right) dpadUI.rightPressed = false;
            else if (event.key === Qt.Key_S || event.key === Qt.Key_Return) startBtnUI.isPressed = false;
            else if (event.key === Qt.Key_A || event.key === Qt.Key_Z) aBtnUI.isPressed = false;
            else if (event.key === Qt.Key_B || event.key === Qt.Key_X) bBtnUI.isPressed = false;
            else if (event.key === Qt.Key_Shift) selectBtnUI.isPressed = false;
        }
    }
}
