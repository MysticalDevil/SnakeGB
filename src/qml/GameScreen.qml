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

            // Menu
            Rectangle {
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
                }
            }

            // World
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

                Item {
                    visible: gameLogic.powerUpPos.x !== -1
                    x: gameLogic.powerUpPos.x * (240 / gameLogic.boardWidth)
                    y: gameLogic.powerUpPos.y * (216 / gameLogic.boardHeight)
                    width: 240 / gameLogic.boardWidth
                    height: 216 / gameLogic.boardHeight
                    z: 30
                    Item {
                        anchors.centerIn: parent
                        width: parent.width * 0.9
                        height: parent.height * 0.9
                        Rectangle { 
                            anchors.fill: parent
                            border.color: p3
                            color: "transparent"
                            visible: gameLogic.powerUpType === 1
                            Rectangle { 
                                anchors.centerIn: parent
                                width: 6
                                height: 6
                                rotation: 45
                                border.color: p3
                            } 
                        }
                        Rectangle { 
                            anchors.fill: parent
                            radius: 10
                            border.color: p3
                            color: "transparent"
                            border.width: 2
                            visible: gameLogic.powerUpType === 2
                        }
                        Rectangle { 
                            anchors.centerIn: parent
                            width: 14
                            height: 14
                            color: p3
                            visible: gameLogic.powerUpType === 3
                        }
                        Rectangle { 
                            anchors.fill: parent
                            radius: 10
                            color: p3
                            visible: gameLogic.powerUpType === 4
                        }
                        Rectangle { 
                            anchors.fill: parent
                            radius: 10
                            border.color: p3
                            color: "transparent"
                            visible: gameLogic.powerUpType === 5
                        }
                        Rectangle { 
                            anchors.centerIn: parent
                            width: 14
                            height: 14
                            rotation: 45
                            color: "#ffd700"
                            visible: gameLogic.powerUpType === 6
                        }
                        Rectangle { 
                            anchors.centerIn: parent
                            width: 14
                            height: 14
                            rotation: 45
                            color: "#00ffff"
                            visible: gameLogic.powerUpType === 7
                        }
                        Rectangle { 
                            anchors.fill: parent
                            border.color: "#ff0000"
                            color: "transparent"
                            border.width: 2
                            visible: gameLogic.powerUpType === 8
                        }
                        Rectangle { 
                            anchors.fill: parent
                            border.color: p3
                            color: "transparent"
                            visible: gameLogic.powerUpType === 9
                        }
                        SequentialAnimation on scale { 
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.8; to: 1.1; duration: 300 }
                            NumberAnimation { from: 1.1; to: 0.8; duration: 300 } 
                        }
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
            }
        }

        ShaderEffect {
            id: lcdShader
            anchors.fill: parent
            z: 20
            property variant source: ShaderEffectSource { sourceItem: gameContent; hideSource: true; live: true }
            property variant history: ShaderEffectSource { sourceItem: lcdShader; live: true; recursive: true }
            property real time: root.elapsed
            fragmentShader: "qrc:/shaders/src/qml/lcd.frag.qsb"
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
    }

    function showOSD(t) { console.log(t) }
    function triggerPowerCycle() { bootAnim.restart() }
}
