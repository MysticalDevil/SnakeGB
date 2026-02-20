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
                Text {
                    id: bootText
                    text: "S N A K E"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: gameFont
                    font.pixelSize: 32
                    color: p3
                    font.bold: true
                    y: gameLogic.state === 0 ? 80 : -50
                    Behavior on y { NumberAnimation { duration: 600; easing.type: Easing.OutBounce } }
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
                        Text { text: gameLogic.hasSave ? "START to Continue" : "START to Play"; color: p3; font.pixelSize: 9; anchors.centerIn: parent; font.bold: true }
                    }
                    Column {
                        spacing: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text { text: "UP: Medals | B: Palette"; color: p3; font.pixelSize: 7; opacity: 0.6; anchors.horizontalCenter: parent.horizontalCenter }
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
                
                Rectangle {
                    x: gameLogic.food.x * (240 / gameLogic.boardWidth)
                    y: gameLogic.food.y * (216 / gameLogic.boardHeight)
                    width: 240 / gameLogic.boardWidth
                    height: 216 / gameLogic.boardHeight
                    color: p3
                    radius: width / 2
                }

                // PowerUp Icon
                Item {
                    visible: gameLogic.powerUpPos.x !== -1
                    x: gameLogic.powerUpPos.x * (240 / gameLogic.boardWidth)
                    y: gameLogic.powerUpPos.y * (216 / gameLogic.boardHeight)
                    width: 240 / gameLogic.boardWidth
                    height: 216 / gameLogic.boardHeight
                    z: 30
                    Rectangle { anchors.centerIn: parent; width: 8; height: 8; color: p3; rotation: 45; visible: gameLogic.powerUpPos.x !== -1 }
                }
            }

            // --- STATE 3: PAUSED ---
            Rectangle {
                id: pausedLayer
                anchors.fill: parent
                color: Qt.rgba(p0.r, p0.g, p0.b, 0.7)
                visible: gameLogic.state === 3
                z: 600
                Text { text: "PAUSED"; font.family: gameFont; font.pixelSize: 20; color: p3; font.bold: true; anchors.centerIn: parent }
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
                    Text { text: "START to RESTART"; color: p0; font.family: gameFont; font.pixelSize: 8; anchors.horizontalCenter: parent.horizontalCenter }
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
                        width: parent.width
                        height: parent.height - 60
                        model: gameLogic.fruitLibrary
                        spacing: 6
                        clip: true
                        delegate: Rectangle {
                            width: parent.width
                            height: 36
                            color: p1
                            border.color: p3
                            Row {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 10
                                Text { text: modelData.discovered ? modelData.name : "???"; color: p3; font.bold: true; font.pixelSize: 9; anchors.verticalCenter: parent.verticalCenter }
                            }
                        }
                    }
                }
            }

            // --- STATE 8: MEDAL ROOM ---
            MedalRoom {
                id: medalRoom
                p0: root.p0; p3: root.p3; gameFont: root.gameFont
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
