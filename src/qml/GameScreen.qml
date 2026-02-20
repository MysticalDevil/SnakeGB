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
    property bool showingMedals: false

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
                    function onPaletteChanged() { backgroundGrid.requestPaint() }
                }
            }

            Item {
                id: gameWorld
                anchors.fill: parent
                z: 1
                visible: gameLogic.state >= 2

                Rectangle {
                    visible: gameLogic.state >= 2
                    x: gameLogic.food.x * (parent.width / gameLogic.boardWidth)
                    y: gameLogic.food.y * (parent.height / gameLogic.boardHeight)
                    width: parent.width / gameLogic.boardWidth
                    height: parent.height / gameLogic.boardHeight
                    color: p3
                    radius: width / 2
                    z: 10
                }

                Repeater {
                    model: gameLogic.snakeModel
                    delegate: Rectangle {
                        x: model.pos.x * (gameWorld.width / gameLogic.boardWidth)
                        y: model.pos.y * (gameWorld.height / gameLogic.boardHeight)
                        width: gameWorld.width / gameLogic.boardWidth
                        height: gameWorld.height / gameLogic.boardHeight
                        color: index === 0 ? p3 : p2
                        radius: index === 0 ? 2 : 1
                        opacity: gameLogic.activeBuff === 1 ? 0.5 : 1.0
                        z: 8
                    }
                }

                Repeater {
                    model: gameLogic.obstacles
                    Rectangle {
                        x: modelData.x * (gameWorld.width / gameLogic.boardWidth)
                        y: modelData.y * (gameWorld.height / gameLogic.boardHeight)
                        width: gameWorld.width / gameLogic.boardWidth
                        height: gameWorld.height / gameLogic.boardHeight
                        color: p3
                        z: 5
                    }
                }
            }

            Rectangle { 
                anchors.fill: parent
                color: p0
                visible: gameLogic.state === 0
                z: 50
                Text { 
                    text: "S N A K E"
                    anchors.centerIn: parent
                    font.family: gameFont
                    font.pixelSize: 32
                    color: p3
                    font.bold: true 
                } 
            }

            Rectangle {
                anchors.fill: parent
                color: p0
                visible: gameLogic.state === 1
                z: 50
                Column {
                    anchors.centerIn: parent
                    spacing: 6
                    Text { 
                        text: "S N A K E"
                        font.family: gameFont
                        font.pixelSize: 32
                        color: p3
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter 
                    }
                    Text { 
                        text: "LEVEL: " + gameLogic.currentLevelName
                        font.family: gameFont
                        font.pixelSize: 10
                        color: p3
                        anchors.horizontalCenter: parent.horizontalCenter 
                    }
                    Text { 
                        text: "HI-SCORE: " + gameLogic.highScore
                        font.family: gameFont
                        font.pixelSize: 12
                        color: p3
                        anchors.horizontalCenter: parent.horizontalCenter 
                    }
                    Text { 
                        text: "UP: Medals | DOWN: Replay"
                        font.family: gameFont
                        font.pixelSize: 8
                        color: p3
                        anchors.horizontalCenter: parent.horizontalCenter 
                    }
                    Text { 
                        text: gameLogic.hasSave ? "START to Continue" : "START to Play"
                        font.family: gameFont
                        font.pixelSize: 14
                        color: p3
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                        SequentialAnimation on opacity { 
                            loops: Animation.Infinite
                            NumberAnimation { from: 1; to: 0; duration: 800 }
                            NumberAnimation { from: 0; to: 1; duration: 800 } 
                        }
                    }
                }
            }

            Column {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 4
                visible: gameLogic.state >= 2
                z: 60
                Text { 
                    text: "HI " + gameLogic.highScore
                    color: p3
                    font.family: gameFont
                    font.pixelSize: 10
                    font.bold: true
                    anchors.right: parent.right 
                }
                Text { 
                    text: "SC " + gameLogic.score
                    color: p3
                    font.family: gameFont
                    font.pixelSize: 12
                    font.bold: true
                    anchors.right: parent.right 
                }
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(p0.r, p0.g, p0.b, 0.6)
                visible: gameLogic.state === 3
                z: 70
                Text { 
                    text: "PAUSED"
                    font.family: gameFont
                    font.pixelSize: 32
                    font.bold: true
                    color: p3
                    anchors.centerIn: parent 
                }
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(p3.r, p3.g, p3.b, 0.8)
                visible: gameLogic.state === 4
                z: 70
                Column {
                    anchors.centerIn: parent
                    spacing: 10
                    Text { 
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: p0
                        font.family: gameFont
                        font.pixelSize: 20
                        font.bold: true
                        text: "GAME OVER\nSCORE: " + gameLogic.score
                        horizontalAlignment: Text.AlignHCenter 
                    }
                    Text { 
                        text: "Press B to Menu"
                        font.family: gameFont
                        font.pixelSize: 12
                        color: p0
                        anchors.horizontalCenter: parent.horizontalCenter 
                    }
                }
            }

            OSDLayer { 
                id: osd
                p0: root.p0
                p3: root.p3
                gameFont: root.gameFont
                z: 100 
            }
            
            MedalRoom {
                id: medalRoom
                p0: root.p0
                p3: root.p3
                gameFont: root.gameFont
                visible: root.showingMedals
                z: 110
                onCloseRequested: {
                    root.showingMedals = false
                }
            }
        }

        ShaderEffect {
            anchors.fill: parent
            property variant source: ShaderEffectSource { sourceItem: gameContent; hideSource: true; live: true }
            property variant history: ShaderEffectSource { sourceItem: parent; live: true; recursive: true }
            property real time: root.elapsed
            fragmentShader: "qrc:/shaders/src/qml/lcd.frag.qsb"
        }
    }

    function showOSD(text) { 
        osd.show(text) 
    }
}
