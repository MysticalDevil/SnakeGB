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

            // --- 游戏世界 ---
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

            // --- 主菜单 ---
            Rectangle {
                anchors.fill: parent
                color: p0
                visible: gameLogic.state === 1
                z: 50
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
                        Text { 
                            text: "HI-SCORE: " + gameLogic.highScore
                            font.family: gameFont
                            font.pixelSize: 12
                            color: p3 
                        }
                        Text { 
                            text: "LEVEL: " + gameLogic.currentLevelName
                            font.family: gameFont
                            font.pixelSize: 10
                            color: p3
                            font.bold: true 
                        }
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

            // --- Roguelike 升级界面 ---
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(p0.r, p0.g, p0.b, 0.95)
                visible: gameLogic.state === 6
                z: 100
                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    width: parent.width - 40
                    Text { 
                        text: "LEVEL UP!"
                        color: p3
                        font.pixelSize: 18
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter 
                    }
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
                                Item {
                                    width: 20
                                    height: 20
                                    anchors.verticalCenter: parent.verticalCenter
                                    // 图标逻辑
                                    Rectangle { anchors.centerIn: parent; width: 12; height: 12; border.color: p3; color: "transparent"; visible: modelData.type === 1 }
                                    Rectangle { anchors.centerIn: parent; width: 14; height: 14; radius: 7; border.color: p3; color: "transparent"; visible: modelData.type === 2 }
                                    Rectangle { anchors.centerIn: parent; width: 14; height: 14; color: p3; visible: modelData.type === 3 }
                                    Rectangle { anchors.centerIn: parent; width: 14; height: 14; radius: 7; color: p3; visible: modelData.type === 4 }
                                    Rectangle { anchors.centerIn: parent; width: 14; height: 14; radius: 7; border.color: p3; color: "transparent"; visible: modelData.type === 5 }
                                    Rectangle { anchors.centerIn: parent; width: 12; height: 12; rotation: 45; color: "#ffd700"; visible: modelData.type === 6 }
                                    Rectangle { anchors.centerIn: parent; width: 12; height: 12; rotation: 45; color: "#00ffff"; visible: modelData.type === 7 }
                                    Rectangle { anchors.centerIn: parent; width: 14; height: 14; border.color: "#ff0000"; color: "transparent"; visible: modelData.type === 8 }
                                    Rectangle { anchors.centerIn: parent; width: 14; height: 14; border.color: p3; color: "transparent"; visible: modelData.type === 9 }
                                }
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text { text: modelData.name; color: p3; font.bold: true; font.pixelSize: 9 }
                                    Text { text: modelData.desc; color: p3; font.pixelSize: 6; opacity: 0.8 }
                                }
                            }
                        }
                    }
                }
            }
        }

        // --- HUD ---
        Column {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 10
            z: 500
            visible: gameLogic.state >= 2 && gameLogic.state <= 6
            Text { text: "HI " + gameLogic.highScore; color: p3; font.family: gameFont; font.pixelSize: 8; anchors.right: parent.right }
            Text { text: "SC " + gameLogic.score; color: p3; font.family: gameFont; font.pixelSize: 12; font.bold: true; anchors.right: parent.right }
        }

        // --- Shader ---
        ShaderEffect {
            id: lcdShader
            anchors.fill: parent
            property variant source: ShaderEffectSource { sourceItem: gameContent; hideSource: true; live: true }
            property variant history: ShaderEffectSource { sourceItem: lcdShader; live: true; recursive: true }
            property real time: root.elapsed
            fragmentShader: "qrc:/shaders/src/qml/lcd.frag.qsb"
            z: 20
        }
    }

    function showOSD(t) { console.log(t) }
    function triggerPowerCycle() { console.log("Power Cycle") }
}
