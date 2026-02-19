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

    property int shakeMagnitude: 2
    property real elapsed: 0.0

    NumberAnimation on elapsed {
        from: 0
        to: 1000
        duration: 1000000
        loops: Animation.Infinite
    }

    Connections {
        target: gameLogic
        function onRequestFeedback(magnitude) {
            shakeMagnitude = magnitude
            screenShake.start()
        }
    }

    SequentialAnimation {
        id: screenShake
        NumberAnimation {
            target: gameBoyBody
            property: "x"
            from: 0
            to: shakeMagnitude
            duration: 40
        }
        NumberAnimation {
            target: gameBoyBody
            property: "x"
            from: shakeMagnitude
            to: -shakeMagnitude
            duration: 40
        }
        NumberAnimation {
            target: gameBoyBody
            property: "x"
            from: -shakeMagnitude
            to: 0
            duration: 40
        }
    }

    Rectangle {
        id: gameBoyBody
        anchors.fill: parent
        color: gameLogic.shellColor
        radius: 10
        border.color: Qt.darker(color, 1.2)
        border.width: 2

        Behavior on color {
            ColorAnimation {
                duration: 300
            }
        }

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

                Item {
                    id: gameContent
                    anchors.fill: parent
                    visible: true

                    Canvas {
                        id: backgroundGrid
                        anchors.fill: parent
                        z: 0
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.strokeStyle = p1
                            ctx.lineWidth = 1.5
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
                            function onPaletteChanged() {
                                backgroundGrid.requestPaint()
                            }
                        }
                    }

                    Item {
                        id: gameWorld
                        anchors.fill: parent
                        z: 1

                        Rectangle {
                            id: foodRect
                            visible: gameLogic.state > 1
                            x: gameLogic.food.x * (gameContent.width / gameLogic.boardWidth)
                            y: gameLogic.food.y * (gameContent.height / gameLogic.boardHeight)
                            width: gameContent.width / gameLogic.boardWidth
                            height: gameContent.height / gameLogic.boardHeight
                            color: p3
                            radius: width / 2
                            border.color: p0
                            border.width: 1
                            z: 10

                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width * 1.5
                                height: parent.height * 1.5
                                radius: width / 2
                                color: p3
                                opacity: 0.4
                                z: -1
                                SequentialAnimation on scale {
                                    loops: Animation.Infinite
                                    NumberAnimation {
                                        from: 0.8
                                        to: 1.2
                                        duration: 500
                                    }
                                    NumberAnimation {
                                        from: 1.2
                                        to: 0.8
                                        duration: 500
                                    }
                                }
                            }
                        }

                        Repeater {
                            model: gameLogic.obstacles
                            Rectangle {
                                x: modelData.x * (gameContent.width / gameLogic.boardWidth)
                                y: modelData.y * (gameContent.height / gameLogic.boardHeight)
                                width: gameContent.width / gameLogic.boardWidth
                                height: gameContent.height / gameLogic.boardHeight
                                color: p3
                                z: 5
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    color: p0
                                }
                            }
                        }

                        Repeater {
                            model: gameLogic.ghost
                            delegate: Rectangle {
                                x: modelData.x * (gameContent.width / gameLogic.boardWidth)
                                y: modelData.y * (gameContent.height / gameLogic.boardHeight)
                                width: gameContent.width / gameLogic.boardWidth
                                height: gameContent.height / gameLogic.boardHeight
                                color: p3
                                opacity: 0.15
                                radius: 1
                                z: 2
                            }
                        }

                        Repeater {
                            model: gameLogic.snakeModel
                            delegate: Rectangle {
                                x: model.pos.x * (gameContent.width / gameLogic.boardWidth)
                                y: model.pos.y * (gameContent.height / gameLogic.boardHeight)
                                width: gameContent.width / gameLogic.boardWidth
                                height: gameContent.height / gameLogic.boardHeight
                                color: index === 0 ? p3 : p2
                                radius: index === 0 ? 2 : 1
                                border.color: p0
                                border.width: index === 0 ? 1 : 0
                                z: 8
                            }
                        }
                    }

                    Column {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 4
                        visible: gameLogic.state > 1
                        z: 20
                        Text {
                            text: "HI " + gameLogic.highScore
                            color: p3
                            font.family: gameFont
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: "SC " + gameLogic.score
                            color: p3
                            font.family: gameFont
                            font.pixelSize: 14
                            font.bold: true
                        }
                        Text {
                            text: gameLogic.musicEnabled ? "♪" : "×"
                            color: p3
                            font.family: gameFont
                            font.pixelSize: 14
                            anchors.right: parent.right
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: p0
                        visible: gameLogic.state === 0
                        z: 30
                        Text {
                            id: splashText
                            text: "S N A K E"
                            font.family: gameFont
                            font.pixelSize: 32
                            font.bold: true
                            color: p3
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: 80
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: p0
                        visible: gameLogic.state === 1
                        z: 30
                        Column {
                            anchors.centerIn: parent
                            spacing: 8
                            Text {
                                text: "S N A K E"
                                font.family: gameFont
                                font.pixelSize: 32
                                font.bold: true
                                color: p3
                            }
                            Text {
                                text: qsTr("HI-SCORE: ") + gameLogic.highScore
                                font.family: gameFont
                                font.pixelSize: 14
                                color: p3
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: qsTr("Level: ") + (gameLogic.level + 1)
                                font.family: gameFont
                                font.pixelSize: 12
                                color: p3
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: qsTr("SELECT to Continue/Cycle")
                                visible: gameLogic.hasSave
                                font.family: gameFont
                                font.pixelSize: 10
                                color: p3
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: qsTr("START to Play")
                                font.family: gameFont
                                font.pixelSize: 14
                                color: p3
                                anchors.horizontalCenter: parent.horizontalCenter
                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    NumberAnimation {
                                        from: 1
                                        to: 0
                                        duration: 800
                                    }
                                    NumberAnimation {
                                        from: 0
                                        to: 1
                                        duration: 800
                                    }
                                }
                            }
                            Text {
                                text: qsTr("M to Mute Music")
                                font.family: gameFont
                                font.pixelSize: 8
                                color: p3
                                opacity: 0.6
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: qsTr("B to Quit App")
                                font.family: gameFont
                                font.pixelSize: 8
                                color: p3
                                opacity: 0.6
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: Qt.rgba(p0.r, p0.g, p0.b, 0.6)
                        visible: gameLogic.state === 3
                        z: 40
                        Column {
                            anchors.centerIn: parent
                            spacing: 15
                            Text {
                                text: "PAUSED"
                                font.family: gameFont
                                font.pixelSize: 32
                                font.bold: true
                                color: p3
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: qsTr("Press B to Quit Game")
                                font.family: gameFont
                                font.pixelSize: 12
                                color: p3
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: Qt.rgba(p3.r, p3.g, p3.b, 0.8)
                        visible: gameLogic.state === 4
                        z: 40
                        Column {
                            anchors.centerIn: parent
                            spacing: 10
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: p0
                                font.family: gameFont
                                font.pixelSize: 20
                                font.bold: true
                                text: qsTr("GAME OVER\nSCORE: %1").arg(gameLogic.score)
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Text {
                                text: qsTr("Press B to Menu")
                                font.family: gameFont
                                font.pixelSize: 12
                                color: p0
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }

                ShaderEffect {
                    anchors.fill: parent
                    property variant source: ShaderEffectSource {
                        sourceItem: gameContent
                        hideSource: true
                        live: true
                        recursive: false
                    }
                    property real time: window.elapsed
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
            onUpClicked: {
                gameLogic.move(0, -1)
            }
            onDownClicked: {
                gameLogic.move(0, 1)
            }
            onLeftClicked: {
                gameLogic.move(-1, 0)
            }
            onRightClicked: {
                gameLogic.move(1, 0)
            }
        }

        Row {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 140
            anchors.right: parent.right
            anchors.rightMargin: 30
            spacing: 15
            rotation: -15
            GBButton {
                id: bBtnUI
                text: "B"
                onClicked: {
                    if (gameLogic.state === 1) {
                        gameLogic.quit()
                    } else if (gameLogic.state === 3 || gameLogic.state === 4) {
                        gameLogic.quitToMenu()
                    } else {
                        gameLogic.nextPalette()
                    }
                }
            }
            GBButton {
                id: aBtnUI
                text: "A"
                onClicked: {
                    if (gameLogic.state === 1) {
                        gameLogic.startGame()
                    } else if (gameLogic.state === 4) {
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
                text: "SELECT"
                onClicked: {
                    if (gameLogic.state === 1) {
                        if (gameLogic.hasSave) {
                            gameLogic.loadLastSession()
                        } else {
                            gameLogic.nextLevel()
                        }
                    }
                }
            }
            SmallButton {
                id: startBtnUI
                text: "START"
                onClicked: {
                    if (gameLogic.state === 1) {
                        gameLogic.startGame()
                    } else if (gameLogic.state === 4) {
                        gameLogic.restart()
                    } else if (gameLogic.state > 1) {
                        gameLogic.togglePause()
                    }
                }
            }
        }
    }

    Item {
        focus: true
        Keys.onPressed: (event) => {
            if (event.isAutoRepeat) {
                return
            }
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
                if (gameLogic.state === 1) {
                    gameLogic.startGame()
                } else if (gameLogic.state === 4) {
                    gameLogic.restart()
                } else if (gameLogic.state > 1) {
                    gameLogic.togglePause()
                }
            } else if (event.key === Qt.Key_A || event.key === Qt.Key_Z) {
                aBtnUI.isPressed = true
            } else if (event.key === Qt.Key_B || event.key === Qt.Key_X) {
                bBtnUI.isPressed = true
                if (gameLogic.state === 1) {
                    gameLogic.quit()
                } else if (gameLogic.state === 3 || gameLogic.state === 4) {
                    gameLogic.quitToMenu()
                } else {
                    gameLogic.nextPalette()
                }
            } else if (event.key === Qt.Key_Shift) {
                selectBtnUI.isPressed = true
                if (gameLogic.state === 1) {
                    if (gameLogic.hasSave) {
                        gameLogic.loadLastSession()
                    } else {
                        gameLogic.nextLevel()
                    }
                }
            } else if (event.key === Qt.Key_Control) {
                gameLogic.nextShellColor()
            } else if (event.key === Qt.Key_M) {
                gameLogic.toggleMusic()
            } else if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q) {
                gameLogic.quit()
            }
        }
        Keys.onReleased: (event) => {
            if (event.isAutoRepeat) {
                return
            }
            if (event.key === Qt.Key_Up) {
                dpadUI.upPressed = false
            } else if (event.key === Qt.Key_Down) {
                dpadUI.downPressed = false
            } else if (event.key === Qt.Key_Left) {
                dpadUI.leftPressed = false
            } else if (event.key === Qt.Key_Right) {
                dpadUI.rightPressed = false
            } else if (event.key === Qt.Key_S || event.key === Qt.Key_Return) {
                startBtnUI.isPressed = false
            } else if (event.key === Qt.Key_A || event.key === Qt.Key_Z) {
                aBtnUI.isPressed = false
            } else if (event.key === Qt.Key_B || event.key === Qt.Key_X) {
                bBtnUI.isPressed = false
            } else if (event.key === Qt.Key_Shift) {
                selectBtnUI.isPressed = false
            }
        }
    }
}
