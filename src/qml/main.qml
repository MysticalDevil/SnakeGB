import QtQuick
import QtQuick.Controls

Window {
    id: window
    width: 350
    height: 550
    minimumWidth: 350
    maximumWidth: 350
    minimumHeight: 550
    maximumHeight: 550
    visible: true
    title: qsTr("Snake GB Edition")
    color: "#c0c0c0"

    readonly property color p0: gameLogic.palette[0]
    readonly property color p1: gameLogic.palette[1]
    readonly property color p2: gameLogic.palette[2]
    readonly property color p3: gameLogic.palette[3]

    readonly property string gameFont: "Monospace"

    Connections {
        target: gameLogic
        function onRequestFeedback() {
            screenShake.start()
        }
    }

    SequentialAnimation {
        id: screenShake
        NumberAnimation { target: gameBoyBody; property: "x"; from: 0; to: 2; duration: 40 }
        NumberAnimation { target: gameBoyBody; property: "x"; from: 2; to: -2; duration: 40 }
        NumberAnimation { target: gameBoyBody; property: "x"; from: -2; to: 0; duration: 40 }
    }

    Rectangle {
        id: gameBoyBody
        anchors.fill: parent
        color: gameLogic.shellColor
        radius: 10
        border.color: Qt.darker(color, 1.2)
        border.width: 2

        Behavior on color { ColorAnimation { duration: 300 } }

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
                color: p0
                clip: true

                Canvas {
                    id: backgroundGrid
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.strokeStyle = p1
                        ctx.lineWidth = 1
                        ctx.beginPath()
                        for (var i = 0; i <= gameLogic.boardWidth; i++) {
                            var x = i * (width / gameLogic.boardWidth)
                            ctx.moveTo(x, 0)
                            ctx.lineTo(x, height)
                        }
                        for (var j = 0; j <= gameLogic.boardHeight; j++) {
                            var y = j * (height / gameLogic.boardHeight)
                            ctx.moveTo(0, y)
                            ctx.lineTo(width, y)
                        }
                        ctx.stroke()
                    }
                    Connections {
                        target: gameLogic
                        function onPaletteChanged() { backgroundGrid.requestPaint() }
                    }
                }

                Item {
                    id: gameWorld
                    anchors.fill: parent
                    
                    Rectangle {
                        visible: gameLogic.state !== 0
                        x: gameLogic.food.x * (gameScreen.width / gameLogic.boardWidth)
                        y: gameLogic.food.y * (gameScreen.height / gameLogic.boardHeight)
                        width: gameScreen.width / gameLogic.boardWidth
                        height: gameScreen.height / gameLogic.boardHeight
                        color: p3
                        radius: width / 2
                    }

                    Repeater {
                        model: gameLogic.obstacles
                        Rectangle {
                            x: modelData.x * (gameScreen.width / gameLogic.boardWidth)
                            y: modelData.y * (gameScreen.height / gameLogic.boardHeight)
                            width: gameScreen.width / gameLogic.boardWidth
                            height: gameScreen.height / gameLogic.boardHeight
                            color: p3
                            Rectangle { anchors.fill: parent; anchors.margins: 2; color: p0 }
                        }
                    }

                    Repeater {
                        model: gameLogic.snakeModel
                        delegate: Rectangle {
                            x: model.pos.x * (gameScreen.width / gameLogic.boardWidth)
                            y: model.pos.y * (gameScreen.height / gameLogic.boardHeight)
                            width: gameScreen.width / gameLogic.boardWidth
                            height: gameScreen.height / gameLogic.boardHeight
                            color: index === 0 ? p3 : p2
                            radius: 1
                        }
                    }
                }

                Column {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 4
                    visible: gameLogic.state !== 0
                    Text { text: qsTr("HI: ") + gameLogic.highScore; color: p3; font.family: gameFont; font.pixelSize: 10; font.bold: true }
                    Text { text: qsTr("SC: ") + gameLogic.score; color: p3; font.family: gameFont; font.pixelSize: 12; font.bold: true }
                }

                Rectangle {
                    anchors.fill: parent
                    color: p0
                    visible: gameLogic.state === 0
                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        Text { text: "S N A K E"; font.family: gameFont; font.pixelSize: 32; font.bold: true; color: p3 }
                        Text { text: qsTr("HI-SCORE: ") + gameLogic.highScore; font.family: gameFont; font.pixelSize: 14; color: p3; anchors.horizontalCenter: parent.horizontalCenter }
                        
                        Text {
                            text: qsTr("SELECT to Continue")
                            visible: gameLogic.hasSave
                            font.family: gameFont
                            font.pixelSize: 12
                            color: p3
                            anchors.horizontalCenter: parent.horizontalCenter
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { from: 1; to: 0.3; duration: 600 }
                                NumberAnimation { from: 0.3; to: 1; duration: 600 }
                            }
                        }

                        Text { 
                            text: qsTr("START to New Game")
                            font.family: gameFont
                            font.pixelSize: 14
                            color: p3
                            anchors.horizontalCenter: parent.horizontalCenter
                            SequentialAnimation on opacity { 
                                loops: Animation.Infinite
                                NumberAnimation { from: 1; to: 0; duration: 800 }
                                NumberAnimation { from: 0; to: 1; duration: 800 }
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(p0.r, p0.g, p0.b, 0.5)
                    visible: gameLogic.state === 2
                    Text { anchors.centerIn: parent; text: qsTr("PAUSED"); font.family: gameFont; font.pixelSize: 24; font.bold: true; color: p3 }
                }

                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(p3.r, p3.g, p3.b, 0.6)
                    visible: gameLogic.state === 3
                    Text { 
                        anchors.centerIn: parent
                        color: p0
                        font.family: gameFont
                        font.pixelSize: 18
                        text: qsTr("GAME OVER\nScore: %1\nPress Start to Retry").arg(gameLogic.score)
                        horizontalAlignment: Text.AlignHCenter 
                    }
                }

                ShaderEffect {
                    anchors.fill: parent
                    property variant source: ShaderEffectSource { 
                        sourceItem: gameScreen
                        hideSource: false
                        recursive: false
                    }
                    fragmentShader: "qrc:/shaders/src/qml/lcd.frag.qsb"
                }
            }
        }

        DPad {
            id: dpadUI
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 110
            anchors.left: parent.left
            anchors.leftMargin: 25
            onUpClicked: gameLogic.move(0, -1)
            onDownClicked: gameLogic.move(0, 1)
            onLeftClicked: gameLogic.move(-1, 0)
            onRightClicked: gameLogic.move(1, 0)
        }

        Row {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 140
            anchors.right: parent.right
            anchors.rightMargin: 30
            spacing: 15
            rotation: -15
            GBButton { id: bBtnUI; text: "B" }
            GBButton { 
                id: aBtnUI
                text: "A"
                onClicked: {
                    if (gameLogic.state === 0) {
                        gameLogic.startGame()
                    } else if (gameLogic.state === 3) {
                        gameLogic.restart()
                    }
                }
            }
        }

        Row {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 30
            SmallButton { 
                id: selectBtnUI
                text: qsTr("SELECT")
                onClicked: {
                    if (gameLogic.state === 0 && gameLogic.hasSave) {
                        gameLogic.loadLastSession()
                    } else {
                        gameLogic.nextPalette()
                    }
                }
            }
            SmallButton { 
                id: startBtnUI
                text: qsTr("START")
                onClicked: {
                    if (gameLogic.state === 0) {
                        gameLogic.startGame()
                    } else if (gameLogic.state === 3) {
                        gameLogic.restart()
                    } else {
                        gameLogic.togglePause()
                    }
                }
            }
        }
    }

    Item {
        focus: true
        Keys.onPressed: (event) => {
            if (event.isAutoRepeat) return
            if (event.key === Qt.Key_Up) {
                dpadUI.upPressed = true
                gameLogic.move(0, -1)
            } else if (event.key === Qt.Key_Down) {
                dpadUI.downPressed = true
                gameLogic.move(0, 1)
            } else if (event.key === Qt.Key_Left) {
                dpadUI.leftPressed = true
                gameLogic.move(-1, 0)
            } else if (event.key === Qt.Key_Right) {
                dpadUI.rightPressed = true
                gameLogic.move(1, 0)
            } else if (event.key === Qt.Key_S || event.key === Qt.Key_Return) { 
                startBtnUI.isPressed = true 
                if (gameLogic.state === 0) {
                    gameLogic.startGame()
                } else if (gameLogic.state === 3) {
                    gameLogic.restart()
                } else {
                    gameLogic.togglePause()
                }
            } else if (event.key === Qt.Key_A || event.key === Qt.Key_Z) {
                aBtnUI.isPressed = true
            } else if (event.key === Qt.Key_B || event.key === Qt.Key_X) {
                bBtnUI.isPressed = true
            } else if (event.key === Qt.Key_Shift) {
                selectBtnUI.isPressed = true
                if (gameLogic.state === 0 && gameLogic.hasSave) {
                    gameLogic.loadLastSession()
                } else {
                    gameLogic.nextPalette()
                }
            } else if (event.key === Qt.Key_Control) {
                gameLogic.nextShellColor()
            }
        }
        Keys.onReleased: (event) => {
            if (event.isAutoRepeat) return
            if (event.key === Qt.Key_Up) dpadUI.upPressed = false
            else if (event.key === Qt.Key_Down) dpadUI.downPressed = false
            else if (event.key === Qt.Key_Left) dpadUI.leftPressed = false
            else if (event.key === Qt.Key_Right) dpadUI.rightPressed = false
            else if (event.key === Qt.Key_S || event.key === Qt.Key_Return) startBtnUI.isPressed = false
            else if (event.key === Qt.Key_A || event.key === Qt.Key_Z) aBtnUI.isPressed = false
            else if (event.key === Qt.Key_B || event.key === Qt.Key_X) bBtnUI.isPressed = false
            else if (event.key === Qt.Key_Shift) selectBtnUI.isPressed = false
        }
    }
}
