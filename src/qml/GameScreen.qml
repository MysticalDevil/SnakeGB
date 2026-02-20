import QtQuick
import QtQuick.Controls

Item {
    id: root
    property color p0
    property color p1
    property color p2
    property color p3
    property string gameFont
    property real elapsed

    function buffName(type) {
        if (type === 1) return "GHOST"
        if (type === 2) return "SLOW"
        if (type === 3) return "MAGNET"
        if (type === 4) return "SHIELD"
        if (type === 5) return "PORTAL"
        if (type === 6) return "DOUBLE"
        if (type === 7) return "DIAMOND"
        if (type === 8) return "LASER"
        if (type === 9) return "MINI"
        return "NONE"
    }

    function powerGlyph(type) {
        if (type === 1) return "G"
        if (type === 2) return "S"
        if (type === 3) return "M"
        if (type === 4) return "H"
        if (type === 5) return "P"
        if (type === 6) return "2"
        if (type === 7) return "D"
        if (type === 8) return "L"
        if (type === 9) return "m"
        return "?"
    }

    function powerColor(type) {
        if (type === 6) return "#ffd700"
        if (type === 7) return "#7ee7ff"
        if (type === 8) return "#ff6666"
        if (type === 4) return "#8aff8a"
        if (type === 5) return "#b78bff"
        return p3
    }

    function choiceGlyph(type) {
        if (type === 1) return "G"
        if (type === 2) return "S"
        if (type === 3) return "M"
        if (type === 4) return "H"
        if (type === 5) return "P"
        if (type === 6) return "2x"
        if (type === 7) return "3x"
        if (type === 8) return "L"
        if (type === 9) return "m"
        return "?"
    }

    width: 240
    height: 216

    Rectangle {
        id: screenContainer
        anchors.fill: parent
        color: "black"
        clip: true

        Item {
            id: gameContent
            anchors.fill: parent
            
            Rectangle { 
                anchors.fill: parent
                color: p0
                z: -1 
            }

            // --- STATE 0: SPLASH ---
            Rectangle {
                id: splashLayer
                anchors.fill: parent
                color: p0
                visible: gameLogic.state === 0
                z: 1000
                property real logoY: -56
                property int fakeLoad: 0

                onVisibleChanged: {
                    if (visible) {
                        logoY = -56
                        fakeLoad = 0
                        dropAnim.restart()
                        loadTimer.start()
                    } else {
                        dropAnim.stop()
                        loadTimer.stop()
                    }
                }

                SequentialAnimation {
                    id: dropAnim
                    running: splashLayer.visible
                    NumberAnimation { target: splashLayer; property: "logoY"; to: 82; duration: 480; easing.type: Easing.OutQuad }
                    NumberAnimation { target: splashLayer; property: "logoY"; to: 90; duration: 80; easing.type: Easing.OutQuad }
                    NumberAnimation { target: splashLayer; property: "logoY"; to: 76; duration: 95; easing.type: Easing.OutQuad }
                    NumberAnimation { target: splashLayer; property: "logoY"; to: 82; duration: 85; easing.type: Easing.OutQuad }
                }

                Timer {
                    id: loadTimer
                    interval: 75
                    repeat: true
                    running: splashLayer.visible
                    onTriggered: {
                        if (splashLayer.fakeLoad < 100) {
                            splashLayer.fakeLoad += 5
                        } else {
                            stop()
                        }
                    }
                }

                Text {
                    id: bootText
                    text: "S N A K E"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: gameFont
                    font.pixelSize: 32
                    color: p3
                    font.bold: true
                    y: splashLayer.logoY
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 156
                    width: 120
                    height: 8
                    color: p1
                    border.color: p3
                    border.width: 1
                    Rectangle {
                        x: 1
                        y: 1
                        width: (parent.width - 2) * (splashLayer.fakeLoad / 100.0)
                        height: parent.height - 2
                        color: p3
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 170
                    text: "LOADING " + splashLayer.fakeLoad + "%"
                    font.family: gameFont
                    font.pixelSize: 8
                    color: p3
                    opacity: 0.75
                }
            }

            // --- STATE 1: MENU ---
            Rectangle {
                id: menuLayer
                anchors.fill: parent
                color: p0
                visible: gameLogic.state === 1
                z: 500
                Column {
                    anchors.centerIn: parent
                    spacing: 12
                    Text { text: "S N A K E"; font.family: gameFont; font.pixelSize: 40; color: p3; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    Column {
                        spacing: 4
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text { text: "HI-SCORE: " + gameLogic.highScore; font.family: gameFont; font.pixelSize: 12; color: p3; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "LEVEL: " + gameLogic.currentLevelName; font.family: gameFont; font.pixelSize: 10; color: p3; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                    Rectangle {
                        width: 140; height: 24; color: p1; border.color: p3; anchors.horizontalCenter: parent.horizontalCenter
                        Text {
                            text: gameLogic.hasSave ? "START to Continue" : "START to Play"
                            color: p3
                            font.pixelSize: 9
                            anchors.centerIn: parent
                            font.bold: true
                            opacity: (Math.floor(elapsed * 4) % 2 === 0) ? 1.0 : 0.45
                        }
                    }
                    Column {
                        spacing: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text { text: "UP: Medals | DOWN: Replay"; color: p3; font.pixelSize: 7; opacity: 0.6; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "SELECT: Switch Level"; color: p3; font.pixelSize: 7; opacity: 0.6; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                }
            }

            // --- STATE 2, 3, 4, 5, 6: WORLD ---
            Item {
                id: gameWorld
                anchors.fill: parent
                z: 10
                visible: gameLogic.state >= 2 && gameLogic.state <= 6
                
                Repeater {
                    model: gameLogic.ghost
                    visible: gameLogic.state === 2
                    delegate: Rectangle {
                        x: modelData.x * (240 / gameLogic.boardWidth)
                        y: modelData.y * (216 / gameLogic.boardHeight)
                        width: 240 / gameLogic.boardWidth
                        height: 216 / gameLogic.boardHeight
                        color: p3
                        opacity: 0.2
                    }
                }

                Repeater {
                    model: gameLogic.snakeModel
                    delegate: Rectangle {
                        x: model.pos.x * (240 / gameLogic.boardWidth)
                        y: model.pos.y * (216 / gameLogic.boardHeight)
                        width: 240 / gameLogic.boardWidth
                        height: 216 / gameLogic.boardHeight
                        color: gameLogic.activeBuff === 6 ? (Math.floor(elapsed * 10) % 2 === 0 ? "#ffd700" : p3) : (index === 0 ? p3 : p2)
                        radius: index === 0 ? 2 : 0
                        Rectangle { anchors.fill: parent; anchors.margins: -2; border.color: "#00ffff"; border.width: 1; radius: parent.radius + 2; visible: index === 0 && gameLogic.shieldActive }
                    }
                }

                Repeater {
                    model: gameLogic.obstacles
                    delegate: Rectangle {
                        x: modelData.x * (240 / gameLogic.boardWidth)
                        y: modelData.y * (216 / gameLogic.boardHeight)
                        width: 240 / gameLogic.boardWidth
                        height: 216 / gameLogic.boardHeight
                        color: gameLogic.currentLevelName === "Dynamic Pulse" || gameLogic.currentLevelName === "Crossfire" || gameLogic.currentLevelName === "Shifting Box"
                               ? ((Math.floor(elapsed * 8) % 2 === 0) ? p3 : p2)
                               : p2
                        border.color: p3
                        border.width: 1
                        z: 12
                    }
                }
                
                Item {
                    x: gameLogic.food.x * (240 / gameLogic.boardWidth)
                    y: gameLogic.food.y * (216 / gameLogic.boardHeight)
                    width: 240 / gameLogic.boardWidth
                    height: 216 / gameLogic.boardHeight
                    z: 20

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width - 2
                        height: parent.height - 2
                        radius: width / 2
                        color: p3
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: -2
                        anchors.verticalCenterOffset: -2
                        width: Math.max(2, parent.width * 0.35)
                        height: Math.max(2, parent.height * 0.35)
                        radius: width / 2
                        color: p0
                        opacity: 0.45
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: 1
                        y: -1
                        width: 2
                        height: 4
                        color: p2
                    }

                    Repeater {
                        model: 3
                        delegate: Rectangle {
                            width: 1
                            height: 1
                            color: p1
                            opacity: 0.8
                            x: 2 + index * 3
                            y: parent.height - 4 - (index % 2)
                        }
                    }
                }

                // PowerUp Icon
                Item {
                    visible: gameLogic.powerUpPos.x !== -1
                    x: gameLogic.powerUpPos.x * (240 / gameLogic.boardWidth)
                    y: gameLogic.powerUpPos.y * (216 / gameLogic.boardHeight)
                    width: 240 / gameLogic.boardWidth
                    height: 216 / gameLogic.boardHeight
                    z: 30

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width + 2
                        height: parent.height + 2
                        radius: width / 2
                        color: "transparent"
                        border.color: p3
                        border.width: 1
                        opacity: 0.75
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 8
                        height: 8
                        color: powerColor(gameLogic.powerUpType)
                        rotation: 45
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 4
                        height: 4
                        color: p0
                        rotation: 45
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width + 6
                        height: parent.height + 6
                        radius: width / 2
                        color: "transparent"
                        border.color: p3
                        border.width: 1
                        opacity: (Math.floor(elapsed * 8) % 2 === 0) ? 0.45 : 0.1
                    }

                    Text {
                        anchors.centerIn: parent
                        text: powerGlyph(gameLogic.powerUpType)
                        color: p3
                        font.family: gameFont
                        font.pixelSize: 7
                        font.bold: true
                    }
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: 4
                    anchors.leftMargin: 4
                    width: 90
                    height: 20
                    color: p1
                    border.color: p3
                    border.width: 1
                    z: 40
                    visible: (gameLogic.state === 2 || gameLogic.state === 5) &&
                             gameLogic.activeBuff !== 0 && gameLogic.buffTicksTotal > 0

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 4
                        anchors.top: parent.top
                        anchors.topMargin: 2
                        text: buffName(gameLogic.activeBuff)
                        color: p3
                        font.family: gameFont
                        font.pixelSize: 7
                        font.bold: true
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 3
                        anchors.rightMargin: 3
                        anchors.bottomMargin: 3
                        height: 5
                        color: p0
                        border.color: p3
                        border.width: 1

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: parent.width * (gameLogic.buffTicksRemaining / Math.max(1, gameLogic.buffTicksTotal))
                            color: p3
                        }
                    }
                }
            }

            // --- STATE 3: PAUSED ---
            Rectangle {
                id: pausedLayer
                anchors.fill: parent
                color: Qt.rgba(p0.r, p0.g, p0.b, 0.7)
                visible: gameLogic.state === 3
                z: 600
                Column {
                    anchors.centerIn: parent
                    spacing: 6
                    Text { text: "PAUSED"; font.family: gameFont; font.pixelSize: 20; color: p3; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: "START: RESUME   B: MENU"; color: p3; font.family: gameFont; font.pixelSize: 8; anchors.horizontalCenter: parent.horizontalCenter }
                }
            }

            // --- STATE 4: GAME OVER ---
            Rectangle {
                id: gameOverLayer
                anchors.fill: parent
                color: Qt.rgba(p3.r, p3.g, p3.b, 0.95)
                visible: gameLogic.state === 4
                z: 700
                Column {
                    anchors.centerIn: parent
                    spacing: 10
                    Text { text: "GAME OVER"; color: p0; font.family: gameFont; font.pixelSize: 24; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: "SCORE: " + gameLogic.score; color: p0; font.family: gameFont; font.pixelSize: 14; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: "START: RESTART   B: MENU"; color: p0; font.family: gameFont; font.pixelSize: 8; anchors.horizontalCenter: parent.horizontalCenter }
                }
            }

            // --- STATE 5: REPLAYING (Overlay) ---
            Rectangle {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: 100
                height: 20
                color: p3
                visible: gameLogic.state === 5
                z: 600
                Text { text: "REPLAY"; color: p0; anchors.centerIn: parent; font.bold: true }
            }

            // --- STATE 6: CHOICE SELECTION ---
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(p0.r, p0.g, p0.b, 0.95)
                visible: gameLogic.state === 6
                z: 650
                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    width: parent.width - 40
                    Text { text: "LEVEL UP!"; color: p3; font.pixelSize: 18; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    Repeater {
                        model: gameLogic.choices
                        delegate: Rectangle {
                            width: parent.width
                            height: 38
                            color: gameLogic.choiceIndex === index ? p2 : p1
                            border.color: p3
                            border.width: gameLogic.choiceIndex === index ? 2 : 1
                            Row {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 8
                                Rectangle {
                                    width: 22
                                    height: 22
                                    radius: 11
                                    color: p0
                                    border.color: p3
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        anchors.centerIn: parent
                                        text: choiceGlyph(modelData.type)
                                        color: p3
                                        font.family: gameFont
                                        font.pixelSize: 9
                                        font.bold: true
                                    }
                                }
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text { text: modelData.name; color: p3; font.bold: true; font.pixelSize: 9 }
                                    Text { text: modelData.desc; color: p3; font.pixelSize: 6; opacity: 0.8; width: parent.width - 30; wrapMode: Text.WordWrap }
                                }
                            }
                        }
                    }
                }
            }

            // --- STATE 7: LIBRARY ---
            Rectangle {
                anchors.fill: parent
                color: p0
                visible: gameLogic.state === 7
                z: 800
                Column {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    Text { text: "CATALOG"; color: p3; font.family: gameFont; font.pixelSize: 20; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    ListView {
                        id: libraryList
                        width: parent.width
                        height: parent.height - 60
                        model: gameLogic.fruitLibrary
                        currentIndex: 0
                        spacing: 6
                        clip: true
                        interactive: true
                        boundsBehavior: Flickable.StopAtBounds
                        Component.onCompleted: currentIndex = gameLogic.libraryIndex
                        onCurrentIndexChanged: {
                            positionViewAtIndex(currentIndex, ListView.Contain)
                            if (currentIndex !== gameLogic.libraryIndex) {
                                gameLogic.setLibraryIndex(currentIndex)
                            }
                        }
                        Connections {
                            target: gameLogic
                            function onLibraryIndexChanged() {
                                if (libraryList.currentIndex !== gameLogic.libraryIndex) {
                                    libraryList.currentIndex = gameLogic.libraryIndex
                                }
                            }
                        }
                        WheelHandler {
                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                            onWheel: (event) => {
                                libraryList.contentY = Math.max(0, Math.min(
                                    libraryList.contentHeight - libraryList.height,
                                    libraryList.contentY - event.angleDelta.y
                                ))
                            }
                        }
                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                            width: 6
                        }
                        delegate: Rectangle {
                            width: parent.width
                            height: 40
                            color: libraryList.currentIndex === index ? p2 : p1
                            border.color: p3
                            border.width: libraryList.currentIndex === index ? 2 : 1
                            Row {
                                anchors.fill: parent
                                anchors.margins: 5
                                spacing: 12
                                Item {
                                    width: 24
                                    height: 24
                                    anchors.verticalCenter: parent.verticalCenter
                                    Item {
                                        anchors.centerIn: parent
                                        width: 20
                                        height: 20
                                        Rectangle { anchors.fill: parent; color: "transparent"; border.color: p3; border.width: 1; visible: modelData.discovered && modelData.type === 1 }
                                        Rectangle { anchors.fill: parent; radius: 10; color: "transparent"; border.color: p3; border.width: 2; visible: modelData.discovered && modelData.type === 2
                                            Rectangle { width: 10; height: 2; color: p3; anchors.centerIn: parent }
                                        }
                                        Rectangle { anchors.fill: parent; color: p3; visible: modelData.discovered && modelData.type === 3; clip: true
                                            Rectangle { width: 20; height: 20; rotation: 45; y: 10; color: p1 }
                                        }
                                        Rectangle { anchors.fill: parent; radius: 10; color: "transparent"; border.color: p3; border.width: 2; visible: modelData.discovered && modelData.type === 4 }
                                        Rectangle { anchors.fill: parent; radius: 10; color: "transparent"; border.color: p3; border.width: 1; visible: modelData.discovered && modelData.type === 5
                                            Rectangle { anchors.centerIn: parent; width: 10; height: 10; radius: 5; border.color: p3; border.width: 1 }
                                        }
                                        Rectangle { anchors.centerIn: parent; width: 16; height: 16; rotation: 45; color: "#ffd700"; visible: modelData.discovered && modelData.type === 6 }
                                        Rectangle { anchors.centerIn: parent; width: 16; height: 16; rotation: 45; color: "#00ffff"; visible: modelData.discovered && modelData.type === 7 }
                                        Rectangle { anchors.fill: parent; color: "transparent"; border.color: "#ff0000"; border.width: 2; visible: modelData.discovered && modelData.type === 8 }
                                        Rectangle { anchors.fill: parent; color: "transparent"; border.color: p3; border.width: 1; visible: modelData.discovered && modelData.type === 9
                                            Rectangle { anchors.centerIn: parent; width: 4; height: 4; color: "white" }
                                        }
                                        Text { text: "?"; color: p0; visible: !modelData.discovered; anchors.centerIn: parent; font.bold: true; font.pixelSize: 12 }
                                    }
                                }
                                Column {
                                    width: parent.width - 50
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text { text: modelData.name; color: p3; font.family: gameFont; font.pixelSize: 10; font.bold: true }
                                    Text { text: modelData.desc; color: p3; font.family: gameFont; font.pixelSize: 7; opacity: 0.7; width: parent.width; wrapMode: Text.WordWrap }
                                }
                            }
                        }
                    }
                }
            }

            // --- STATE 8: MEDAL ROOM ---
            MedalRoom {
                id: medalRoom
                p0: root.p0
                p1: root.p1
                p2: root.p2
                p3: root.p3
                gameFont: root.gameFont
                visible: gameLogic.state === 8
                z: 900
            }
        }

        // --- 2. 特效层 ---
        ShaderEffect {
            id: lcdShader
            anchors.fill: parent
            z: 20
            property variant source: ShaderEffectSource { sourceItem: gameContent; hideSource: true; live: true }
            property variant history: ShaderEffectSource { sourceItem: lcdShader; live: true; recursive: true }
            property real time: root.elapsed
            fragmentShader: "qrc:/shaders/src/qml/lcd.frag.qsb"
        }

        Item {
            id: crtLayer
            anchors.fill: parent
            z: 10000
            opacity: 0.1
            Canvas {
                anchors.fill: parent
                onPaint: { 
                    var ctx = getContext("2d")
                    ctx.strokeStyle = "black"
                    ctx.lineWidth = 1
                    var i = 0
                    while (i < height) {
                        ctx.beginPath(); ctx.moveTo(0, i); ctx.lineTo(width, i); ctx.stroke()
                        i = i + 3
                    }
                }
            }
        }

        // --- 3. HUD ---
        Column {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 10
            z: 500
            visible: gameLogic.state >= 2 && gameLogic.state <= 6
            Text { text: "HI " + gameLogic.highScore; color: p3; font.family: gameFont; font.pixelSize: 8; anchors.right: parent.right }
            Text { text: "SC " + gameLogic.score; color: p3; font.family: gameFont; font.pixelSize: 12; font.bold: true; anchors.right: parent.right }
        }
        
        OSDLayer { id: osd; p0: root.p0; p3: root.p3; gameFont: root.gameFont; z: 3000 }
    }

    function showOSD(t) { osd.show(t) }
    function triggerPowerCycle() { gameLogic.requestStateChange(0) }
}
