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

        // --- 1. 核心层 ---
        Item {
            id: gameContent
            anchors.fill: parent
            
            Rectangle { 
                anchors.fill: parent
                color: p0
                z: -1 
            }

            // Splash
            Rectangle {
                id: splashLayer
                anchors.fill: parent
                color: p0
                visible: gameLogic.state === 0 || bootAnim.running
                z: 1000
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

            // Start Menu
            Rectangle {
                id: menuLayer
                anchors.fill: parent
                color: p0
                visible: gameLogic.state === 1 && !bootAnim.running
                z: 500
                Column {
                    anchors.centerIn: parent
                    spacing: 12
                    Text { 
                        text: "S N A K E"
                        font.family: gameFont
                        font.pixelSize: 40
                        color: p3
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Column {
                        spacing: 4
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text { text: "HI-SCORE: " + gameLogic.highScore; font.family: gameFont; font.pixelSize: 12; color: p3; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "LEVEL: " + gameLogic.currentLevelName; font.family: gameFont; font.pixelSize: 10; color: p3; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                    Rectangle {
                        width: 140
                        height: 24
                        color: p1
                        border.color: p3
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text { 
                            text: gameLogic.hasSave ? "START to Continue" : "START to Play"
                            color: p3
                            font.pixelSize: 9
                            anchors.centerIn: parent
                            font.bold: true
                        }
                    }
                    Column {
                        spacing: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text { text: "UP: Medals | B: Palette"; color: p3; font.pixelSize: 7; opacity: 0.6; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "SELECT: Switch Level"; color: p3; font.pixelSize: 7; opacity: 0.6; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                }
            }

            // World
            Item {
                id: gameWorld
                anchors.fill: parent
                z: 10
                visible: gameLogic.state >= 2 && gameLogic.state <= 6
                
                Repeater {
                    model: gameLogic.snakeModel
                    delegate: Rectangle {
                        x: model.pos.x * (240 / gameLogic.boardWidth)
                        y: model.pos.y * (216 / gameLogic.boardHeight)
                        width: 240 / gameLogic.boardWidth
                        height: 216 / gameLogic.boardHeight
                        color: gameLogic.activeBuff === 6 ? (Math.floor(elapsed * 10) % 2 === 0 ? "#ffd700" : p3) : (index === 0 ? p3 : p2)
                        radius: index === 0 ? 2 : 0
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
            }

            // Game Over
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
        }

        // --- 2. 特效层 (严禁一行流) ---
        ShaderEffect {
            id: lcdShader
            anchors.fill: parent
            z: 20
            property variant source: ShaderEffectSource { 
                sourceItem: gameContent
                hideSource: true
                live: true 
            }
            property variant history: ShaderEffectSource { 
                sourceItem: lcdShader
                live: true
                recursive: true 
            }
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
                    for (var i = 0; i < height; i = i + 3) { 
                        ctx.beginPath()
                        ctx.moveTo(0, i)
                        ctx.lineTo(width, i)
                        ctx.stroke() 
                    } 
                }
            }
        }

        Column {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 10
            z: 500
            visible: gameLogic.state >= 2 && gameLogic.state <= 6
            Text { text: "HI " + gameLogic.highScore; color: p3; font.family: gameFont; font.pixelSize: 8; anchors.right: parent.right }
            Text { text: "SC " + gameLogic.score; color: p3; font.family: gameFont; font.pixelSize: 12; font.bold: true; anchors.right: parent.right }
        }
        
        OSDLayer { 
            id: osd
            p0: root.p0
            p3: root.p3
            gameFont: root.gameFont
            z: 3000 
        }
    }

    function showOSD(t) { 
        osd.show(t) 
    }
    
    function triggerPowerCycle() { 
        bootAnim.restart() 
    }
}
