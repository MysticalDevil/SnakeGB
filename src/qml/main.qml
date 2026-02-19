import QtQuick
import QtQuick.Controls

Window {
    id: window
    width: 350
    height: 550
    visible: true
    title: qsTr("Snake GB Edition")
    color: "#1a1a1a"

    readonly property color p0: gameLogic.palette[0]
    readonly property color p1: gameLogic.palette[1]
    readonly property color p2: gameLogic.palette[2]
    readonly property color p3: gameLogic.palette[3]

    readonly property string gameFont: "Monospace"

    property int shakeMagnitude: 2
    property real elapsed: 0.0
    property bool showingMedals: false

    readonly property real refWidth: 350
    readonly property real refHeight: 550

    NumberAnimation on elapsed {
        from: 0
        to: 1000
        duration: 1000000
        loops: Animation.Infinite
    }

    Timer {
        id: longPressTimer
        interval: 1500
        onTriggered: {
            if (gameLogic.state === 1 && gameLogic.hasSave) {
                gameLogic.deleteSave()
                osdLabel.text = qsTr("Save Cleared")
                osdBox.visible = true
                osdTimer.restart()
            }
        }
    }

    Connections {
        target: gameLogic
        function onRequestFeedback(magnitude) {
            shakeMagnitude = magnitude
            screenShake.start()
        }
        function onPaletteChanged() {
            osdTimer.restart()
            osdLabel.text = gameLogic.paletteName
            osdBox.visible = true
        }
        function onShellColorChanged() {
            osdTimer.restart()
            osdLabel.text = qsTr("Shell Swapped")
            osdBox.visible = true
        }
        function onBuffChanged() {
            if (gameLogic.activeBuff !== 0) {
                osdTimer.restart()
                var buffName = ""
                if (gameLogic.activeBuff === 1) {
                    buffName = "GHOST MODE"
                } else if (gameLogic.activeBuff === 2) {
                    buffName = "SLOW DOWN"
                } else if (gameLogic.activeBuff === 3) {
                    buffName = "MAGNET ON"
                }
                osdLabel.text = buffName
                osdBox.visible = true
            }
        }
        function onAchievementEarned(title) {
            osdTimer.restart()
            osdLabel.text = "UNLOCKED: " + title
            osdBox.visible = true
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

    Item {
        id: rootContainer
        anchors.centerIn: parent
        width: refWidth
        height: refHeight
        scale: Math.min(window.width / refWidth, window.height / refHeight)

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
                    color: "black"
                    clip: true

                    Item {
                        id: gameContent
                        anchors.fill: parent
                        visible: true

                        Rectangle {
                            anchors.fill: parent
                            color: p0
                            z: -1
                        }

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
                                    var xPos = i * (width / gameLogic.boardWidth)
                                    ctx.moveTo(xPos, 0)
                                    ctx.lineTo(xPos, height)
                                }
                                for (var j = 0; j <= gameLogic.boardHeight; j++) {
                                    var yPos = j * (height / gameLogic.boardHeight)
                                    ctx.moveTo(0, yPos)
                                    ctx.lineTo(width, yPos)
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

                            Rectangle {
                                id: powerUpRect
                                visible: gameLogic.state > 1 && gameLogic.powerUpPos.x !== -1
                                x: gameLogic.powerUpPos.x * (gameContent.width / gameLogic.boardWidth)
                                y: gameLogic.powerUpPos.y * (gameContent.height / gameLogic.boardHeight)
                                width: gameContent.width / gameLogic.boardWidth
                                height: gameContent.height / gameLogic.boardHeight
                                color: p3
                                radius: 2
                                z: 11
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    color: p0
                                    radius: 1
                                }
                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    NumberAnimation {
                                        from: 1
                                        to: 0.2
                                        duration: 200
                                    }
                                    NumberAnimation {
                                        from: 0.2
                                        to: 1
                                        duration: 200
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
                                    opacity: gameLogic.activeBuff === 1 ? 0.5 : 1.0
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
                            Text {
                                text: gameLogic.activeBuff !== 0 ? "BUFF" : ""
                                color: p3
                                font.family: gameFont
                                font.pixelSize: 10
                                font.bold: true
                                anchors.right: parent.right
                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    running: gameLogic.activeBuff !== 0
                                    NumberAnimation {
                                        from: 1
                                        to: 0
                                        duration: 500
                                    }
                                    NumberAnimation {
                                        from: 0
                                        to: 1
                                        duration: 500
                                    }
                                }
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
                                spacing: 6
                                Text {
                                    text: "S N A K E"
                                    font.family: gameFont
                                    font.pixelSize: 32
                                    font.bold: true
                                    color: p3
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: qsTr("HI-SCORE: ") + gameLogic.highScore
                                    font.family: gameFont
                                    font.pixelSize: 12
                                    color: p3
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: qsTr("Level: ") + (gameLogic.level + 1)
                                    font.family: gameFont
                                    font.pixelSize: 10
                                    color: p3
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                
                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 4
                                    Repeater {
                                        model: gameLogic.achievements
                                        Rectangle {
                                            width: 12
                                            height: 12
                                            radius: 6
                                            color: p3
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    showingMedals = true
                                                }
                                            }
                                        }
                                    }
                                    Text {
                                        text: gameLogic.achievements.length > 0 ? qsTr("(Click to View)") : ""
                                        font.family: gameFont
                                        font.pixelSize: 8
                                        color: p3
                                        opacity: 0.5
                                    }
                                }

                                Text {
                                    text: qsTr("SELECT to Cycle Levels")
                                    font.family: gameFont
                                    font.pixelSize: 8
                                    color: p3
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: gameLogic.hasSave ? qsTr("START to Continue") : qsTr("START to Play")
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
                                    text: gameLogic.hasSave ? qsTr("Hold SELECT to Delete Save") : qsTr("B to Quit")
                                    font.family: gameFont
                                    font.pixelSize: 8
                                    color: p3
                                    opacity: 0.6
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }

                        Rectangle {
                            id: medalRoom
                            anchors.fill: parent
                            color: p0
                            visible: showingMedals
                            z: 150
                            Column {
                                anchors.centerIn: parent
                                width: parent.width - 40
                                spacing: 10
                                Text {
                                    text: "MEDAL COLLECTION"
                                    font.family: gameFont
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: p3
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Rectangle {
                                    width: parent.width
                                    height: 1
                                    color: p3
                                }
                                Repeater {
                                    model: gameLogic.achievements
                                    Text {
                                        text: "★ " + modelData
                                        font.family: gameFont
                                        font.pixelSize: 10
                                        color: p3
                                        width: parent.width
                                        wrapMode: Text.WordWrap
                                    }
                                }
                                Text { 
                                    text: qsTr("Press B to Close")
                                    font.family: gameFont
                                    font.pixelSize: 8
                                    color: p3
                                    opacity: 0.6
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 10
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
                                    text: qsTr("Press B to Menu")
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

                        Rectangle {
                            id: osdBox
                            anchors.centerIn: parent
                            width: 180
                            height: 40
                            radius: 5
                            color: Qt.rgba(p3.r, p3.g, p3.b, 0.8)
                            visible: false
                            z: 200
                            Text {
                                id: osdLabel
                                anchors.centerIn: parent
                                color: p0
                                font.family: gameFont
                                font.bold: true
                                font.pixelSize: 10
                            }
                            Timer {
                                id: osdTimer
                                interval: 1500
                                onTriggered: {
                                    osdBox.visible = false
                                }
                            }
                        }
                    }

                    ShaderEffect {
                        id: finalShader
                        anchors.fill: parent
                        
                        property variant source: ShaderEffectSource {
                            sourceItem: gameContent
                            hideSource: true 
                            live: true
                            recursive: false
                        }
                        
                        property variant history: ShaderEffectSource {
                            sourceItem: finalShader
                            live: true
                            recursive: true
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
                        if (showingMedals) {
                            showingMedals = false
                        } else if (gameLogic.state === 1) {
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
                        if (showingMedals) {
                            showingMedals = false
                        } else {
                            gameLogic.handleStart()
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
                    onPressed: {
                        longPressTimer.start()
                    }
                    onReleased: {
                        if (longPressTimer.running) {
                            longPressTimer.stop()
                            if (showingMedals) {
                                showingMedals = false
                            } else {
                                gameLogic.handleSelect()
                            }
                        }
                    }
                }
                SmallButton {
                    id: startBtnUI
                    text: "START"
                    onClicked: {
                        if (showingMedals) {
                            showingMedals = false
                        } else {
                            gameLogic.handleStart()
                        }
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
                if (showingMedals) {
                    showingMedals = false
                } else {
                    gameLogic.handleStart()
                }
            } else if (event.key === Qt.Key_A || event.key === Qt.Key_Z) {
                aBtnUI.isPressed = true
                if (showingMedals) {
                    showingMedals = false
                } else {
                    gameLogic.handleStart()
                }
            } else if (event.key === Qt.Key_B || event.key === Qt.Key_X) {
                bBtnUI.isPressed = true
                if (showingMedals) {
                    showingMedals = false
                } else if (gameLogic.state === 1) {
                    gameLogic.quit()
                } else if (gameLogic.state === 3 || gameLogic.state === 4) {
                    gameLogic.quitToMenu()
                } else {
                    gameLogic.nextPalette()
                }
            } else if (event.key === Qt.Key_Shift) {
                selectBtnUI.isPressed = true
                longPressTimer.start()
            } else if (event.key === Qt.Key_Control) {
                gameLogic.nextShellColor()
            } else if (event.key === Qt.Key_M) {
                gameLogic.toggleMusic()
            } else if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q) {
                gameLogic.quit()
            } else if (event.key === Qt.Key_Back) {
                if (showingMedals) {
                    showingMedals = false
                } else if (gameLogic.state === 1) {
                    gameLogic.quit()
                } else {
                    gameLogic.quitToMenu()
                }
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
                if (longPressTimer.running) {
                    longPressTimer.stop()
                    if (showingMedals) {
                        showingMedals = false
                    } else {
                        gameLogic.handleSelect()
                    }
                }
            }
        }
    }
}
