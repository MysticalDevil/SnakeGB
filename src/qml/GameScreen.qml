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

        // --- 1. 内容源 (经过 Shader 处理) ---
        Item {
            id: gameContent
            anchors.fill: parent
            
            Rectangle { 
                anchors.fill: parent
                color: p0
                z: -1 
            }
            
            Canvas {
                id: backgroundGrid
                anchors.fill: parent
                z: 0
                property color gridColor: (gameLogic.coverage > 0.5) ? Qt.lerp(p1, "#ff0000", Math.abs(Math.sin(elapsed * 5.0)) * 0.3) : p1
                onPaint: { 
                    var ctx = getContext("2d")
                    ctx.strokeStyle = gridColor
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
                    function onPaletteChanged() { backgroundGrid.requestPaint() } 
                    function onScoreChanged() { backgroundGrid.requestPaint() }
                }
            }

            Item {
                id: gameWorld
                anchors.fill: parent
                z: 10
                visible: gameLogic.state >= 2 && gameLogic.state <= 6

                // GHOST REPLAY
                Repeater {
                    model: gameLogic.ghost
                    visible: gameLogic.state === 2
                    delegate: Rectangle {
                        x: modelData.x * (gameWorld.width / gameLogic.boardWidth)
                        y: modelData.y * (gameWorld.height / gameLogic.boardHeight)
                        width: gameWorld.width / gameLogic.boardWidth
                        height: gameWorld.height / gameLogic.boardHeight
                        color: p3
                        opacity: 0.25
                        radius: 1
                    }
                }

                // Food
                Rectangle { 
                    x: gameLogic.food.x * (parent.width / gameLogic.boardWidth)
                    y: gameLogic.food.y * (parent.height / gameLogic.boardHeight)
                    width: parent.width / gameLogic.boardWidth
                    height: parent.height / gameLogic.boardHeight
                    color: p3
                    radius: width / 2
                    z: 20 
                }
                
                // PowerUps (9 Styles Restored)
                Item {
                    visible: gameLogic.powerUpPos.x !== -1
                    x: gameLogic.powerUpPos.x * (parent.width / gameLogic.boardWidth)
                    y: gameLogic.powerUpPos.y * (parent.height / gameLogic.boardHeight)
                    width: parent.width / gameLogic.boardWidth
                    height: parent.height / gameLogic.boardHeight
                    z: 30
                    Item {
                        anchors.centerIn: parent
                        width: parent.width * 0.9
                        height: parent.height * 0.9
                        // Ghost
                        Rectangle { 
                            anchors.fill: parent
                            color: "transparent"
                            border.color: p3
                            border.width: 1
                            visible: gameLogic.powerUpType === 1
                            Rectangle { 
                                anchors.centerIn: parent
                                width: parent.width*0.4
                                height: parent.height*0.4
                                rotation: 45
                                border.color: p3
                                border.width: 1
                                color: "transparent" 
                            } 
                        }
                        // Slow
                        Rectangle { 
                            anchors.fill: parent
                            radius: width/2
                            color: "transparent"
                            border.color: p3
                            border.width: 2
                            visible: gameLogic.powerUpType === 2
                            Rectangle { 
                                width: parent.width*0.5
                                height: 2
                                color: p3
                                anchors.centerIn: parent 
                            } 
                        }
                        // Magnet
                        Rectangle { 
                            anchors.centerIn: parent
                            width: parent.width*0.8
                            height: parent.height*0.8
                            color: p3
                            visible: gameLogic.powerUpType === 3
                            clip: true
                            Rectangle { 
                                width: parent.width
                                height: parent.height
                                rotation: 45
                                y: parent.height*0.5
                                color: p0 
                            } 
                        }
                        // Shield
                        Rectangle { 
                            anchors.fill: parent
                            radius: width/2
                            color: "transparent"
                            border.color: p3
                            border.width: 2
                            visible: gameLogic.powerUpType === 4
                            Rectangle { width: parent.width*0.6; height: 2; color: p3; anchors.centerIn: parent }
                            Rectangle { height: parent.height*0.6; width: 2; color: p3; anchors.centerIn: parent } 
                        }
                        // Portal
                        Rectangle { 
                            anchors.fill: parent
                            radius: width/2
                            color: "transparent"
                            border.color: p3
                            border.width: 1
                            visible: gameLogic.powerUpType === 5
                            Rectangle { 
                                anchors.centerIn: parent
                                width: parent.width*0.5
                                height: parent.height*0.5
                                radius: width/2
                                border.color: p3
                                border.width: 1 
                            } 
                        }
                        // Golden
                        Rectangle { 
                            anchors.centerIn: parent
                            width: parent.width*0.8
                            height: parent.height*0.8
                            rotation: 45
                            color: "#ffd700"
                            visible: gameLogic.powerUpType === 6
                            Rectangle { anchors.centerIn: parent; width: parent.width*0.4; height: parent.height*0.4; color: p0 } 
                        }
                        // Rich
                        Rectangle { 
                            anchors.centerIn: parent
                            width: parent.width*0.8
                            height: parent.height*0.8
                            rotation: 45
                            color: "#00ffff"
                            visible: gameLogic.powerUpType === 7
                            Rectangle { anchors.centerIn: parent; width: parent.width*0.2; height: parent.height*0.2; color: "white" } 
                        }
                        // Laser
                        Rectangle { 
                            anchors.fill: parent
                            color: "transparent"
                            border.color: "#ff0000"
                            border.width: 2
                            visible: gameLogic.powerUpType === 8
                            Rectangle { anchors.centerIn: parent; width: 4; height: 4; color: "#ff0000" } 
                        }
                        // Mini
                        Rectangle { 
                            anchors.fill: parent
                            color: "transparent"
                            border.color: p3
                            border.width: 1
                            visible: gameLogic.powerUpType === 9
                            Rectangle { anchors.centerIn: parent; width: 4; height: 4; color: "white" } 
                        }

                        SequentialAnimation on scale { 
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.8; to: 1.1; duration: 300 }
                            NumberAnimation { from: 1.1; to: 0.8; duration: 300 } 
                        }
                    }
                }

                // Snake
                Repeater {
                    model: gameLogic.snakeModel
                    delegate: Rectangle {
                        x: model.pos.x * (gameWorld.width / gameLogic.boardWidth)
                        y: model.pos.y * (gameWorld.height / gameLogic.boardHeight)
                        width: gameWorld.width / gameLogic.boardWidth
                        height: gameWorld.height / gameLogic.boardHeight
                        color: (gameLogic.activeBuff === 6) ? ((Math.floor(elapsed * 10) % 2 === 0) ? "#ffd700" : p3) : (index === 0 ? p3 : p2)
                        radius: index === 0 ? 2 : 1
                        opacity: gameLogic.activeBuff === 1 ? 0.4 : 1.0
                        z: 15
                        Rectangle { 
                            anchors.fill: parent
                            anchors.margins: -2
                            color: "transparent"
                            border.color: "#00ffff"
                            border.width: 1
                            radius: parent.radius + 2
                            visible: index === 0 && gameLogic.shieldActive 
                        }
                    }
                }

                // Obstacles
                Repeater {
                    model: gameLogic.obstacles
                    Rectangle { 
                        x: modelData.x * (gameWorld.width / gameLogic.boardWidth)
                        y: modelData.y * (gameWorld.height / gameLogic.boardHeight)
                        width: gameWorld.width / gameLogic.boardWidth
                        height: gameWorld.height / gameLogic.boardHeight
                        color: p3
                        z: 12
                        Rectangle { anchors.fill: parent; anchors.margins: 2; color: p0 } 
                    }
                }
            }

            // Splash
            Rectangle {
                id: splashLayer
                anchors.fill: parent
                color: p0
                visible: gameLogic.state === 0 || bootAnim.running
                z: 100
                Text { 
                    id: bootText
                    text: "S N A K E"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: gameFont
                    font.pixelSize: 32
                    color: p3
                    font.bold: true
                    y: -50 
                }
                SequentialAnimation {
                    id: bootAnim
                    running: gameLogic.state === 0
                    PauseAnimation { duration: 200 }
                    NumberAnimation { target: bootText; property: "y"; from: -50; to: 80; duration: 600; easing.type: Easing.OutBounce }
                }
            }

            // Menu
            Rectangle {
                anchors.fill: parent
                color: p0
                visible: gameLogic.state === 1 && !bootAnim.running
                z: 50
                Image { source: "qrc:/src/qml/icon.svg"; anchors.fill: parent; opacity: 0.05; fillMode: Image.Tile }
                Column {
                    anchors.centerIn: parent
                    spacing: 12
                    Text { 
                        text: "S N A K E"
                        font.family: gameFont
                        font.pixelSize: 42
                        color: p3
                        font.bold: true 
                    }
                    Column {
                        spacing: 4
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text { text: "LEVEL: " + gameLogic.currentLevelName; font.family: gameFont; font.pixelSize: 11; color: p3; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "HI-SCORE: " + gameLogic.highScore; font.family: gameFont; font.pixelSize: 13; color: p3; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                    Rectangle {
                        width: 160
                        height: 30
                        color: p1
                        border.color: p3
                        border.width: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text { 
                            text: "PRESS START"
                            font.family: gameFont
                            font.pixelSize: 10
                            color: p3
                            anchors.centerIn: parent
                            SequentialAnimation on opacity { 
                                loops: Animation.Infinite
                                NumberAnimation { from: 1; to: 0.3; duration: 500 }
                                NumberAnimation { from: 0.3; to: 1; duration: 500 } 
                            } 
                        }
                    }
                    Column {
                        spacing: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text { text: "UP: Medals"; font.family: gameFont; font.pixelSize: 7; color: p3; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "DOWN: Replay"; font.family: gameFont; font.pixelSize: 7; color: gameLogic.hasReplay ? p3 : Qt.rgba(p3.r, p3.g, p3.b, 0.3); anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "SELECT: Switch Level (Long to Clear)"; font.family: gameFont; font.pixelSize: 7; color: p3; anchors.horizontalCenter: parent.horizontalCenter; opacity: 0.8 }
                    }
                }
            }

            // Secondary Pages
            MedalRoom { 
                id: medalRoom
                p0: root.p0
                p3: root.p3
                gameFont: root.gameFont
                visible: gameLogic.state === 8
                z: 200 
            }
            
            Rectangle {
                id: libraryLayer
                anchors.fill: parent
                color: p0
                visible: gameLogic.state === 7
                z: 200
                Column {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    Text { text: "FRUIT CATALOG"; color: p3; font.family: gameFont; font.pixelSize: 20; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    ListView {
                        id: libraryList
                        width: parent.width
                        height: parent.height - 60
                        model: gameLogic.fruitLibrary
                        currentIndex: gameLogic.libraryIndex
                        clip: true
                        spacing: 6
                        onCurrentIndexChanged: libraryList.positionViewAtIndex(currentIndex, ListView.Contain)
                        delegate: Rectangle {
                            width: parent.width
                            height: 40
                            color: gameLogic.libraryIndex === index ? p2 : p1
                            border.color: p3
                            border.width: gameLogic.libraryIndex === index ? 2 : 1
                            Row { 
                                anchors.fill: parent
                                anchors.margins: 5
                                spacing: 15
                                Item {
                                    width: 24
                                    height: 24
                                    anchors.verticalCenter: parent.verticalCenter
                                    Rectangle { 
                                        anchors.centerIn: parent
                                        width: 18
                                        height: 18
                                        rotation: 45
                                        color: modelData.discovered ? p3 : p2 
                                    }
                                    Text { text: "?"; color: p0; visible: !modelData.discovered; anchors.centerIn: parent; font.bold: true } 
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
        }

        // --- 2. Shader ---
        ShaderEffect {
            id: lcdShader
            anchors.fill: parent
            property variant source: ShaderEffectSource { sourceItem: gameContent; hideSource: true; live: true }
            property variant history: ShaderEffectSource { sourceItem: lcdShader; live: true; recursive: true }
            property real time: root.elapsed
            fragmentShader: "qrc:/shaders/src/qml/lcd.frag.qsb"
            z: 20
        }

        // --- 3. 覆盖层 ---
        
        // HUD RESTORED
        Column {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 4
            z: 100
            visible: gameLogic.state >= 2 && gameLogic.state <= 6
            Text { text: "HI " + gameLogic.highScore; color: p3; font.family: gameFont; font.pixelSize: 8; anchors.right: parent.right }
            Text { text: "SC " + gameLogic.score; color: p3; font.family: gameFont; font.pixelSize: 12; font.bold: true; anchors.right: parent.right }
        }

        // STATUS RESTORED
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 4
            width: 80; height: 12
            color: Qt.rgba(p3.r, p3.g, p3.b, 0.2)
            radius: 2
            z: 100
            visible: gameLogic.state === 2 && gameLogic.activeBuff > 0
            Text {
                anchors.centerIn: parent; font.family: gameFont; font.pixelSize: 6; font.bold: true; color: p3
                text: {
                    var names = ["", "GHOST ACTIVE", "SLOW ACTIVE", "MAGNET ON", "SHIELD ON", "PORTAL OPEN", "2X MULTIPLY", "3X RICH", "LASER READY", "BODY MINI"]
                    return names[gameLogic.activeBuff] || ""
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(p0.r, p0.g, p0.b, 0.8)
            visible: gameLogic.state === 3
            z: 500
            Text { text: "PAUSED"; color: p3; font.family: gameFont; font.pixelSize: 32; font.bold: true; anchors.centerIn: parent }
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(p3.r, p3.g, p3.b, 0.9)
            visible: gameLogic.state === 4
            z: 500
            Column {
                anchors.centerIn: parent
                spacing: 10
                Text { text: "GAME OVER"; color: p0; font.family: gameFont; font.pixelSize: 24; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                Text { text: "SCORE: " + gameLogic.score; color: p0; font.family: gameFont; font.pixelSize: 16; anchors.horizontalCenter: parent.horizontalCenter }
                Text { text: "START to Restart\nB to Menu"; color: p0; font.family: gameFont; font.pixelSize: 8; horizontalAlignment: Text.AlignHCenter; anchors.horizontalCenter: parent.horizontalCenter }
            }
        }

        // CRT PHYSICAL LAYER (ABS TOP)
        Item {
            id: crtLayer
            anchors.fill: parent
            z: 10000
            opacity: 0.15
            Canvas {
                anchors.fill: parent
                onPaint: { 
                    var ctx = getContext("2d")
                    ctx.strokeStyle = "black"
                    ctx.lineWidth = 1
                    for (var i = 0; i < height; i += 3) { 
                        ctx.beginPath()
                        ctx.moveTo(0, i)
                        ctx.lineTo(width, i)
                        ctx.stroke() 
                    } 
                }
            }
        }

        OSDLayer { id: osd; p0: root.p0; p3: root.p3; gameFont: root.gameFont; z: 3000 }

        Rectangle {
            id: powerFlash
            anchors.fill: parent
            color: "black"
            opacity: 0
            z: 4000
            SequentialAnimation {
                id: flashEffect
                NumberAnimation { target: powerFlash; property: "opacity"; from: 0; to: 1; duration: 50 }
                PauseAnimation { duration: 100 }
                NumberAnimation { target: powerFlash; property: "opacity"; from: 1; to: 0; duration: 300 }
            }
        }
    }

    function showOSD(text) { osd.show(text) }
    function triggerPowerCycle() { flashEffect.restart() }
}
