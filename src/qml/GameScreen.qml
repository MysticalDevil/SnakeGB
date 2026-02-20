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
                        color: index === 0 ? p3 : p2
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                color: p0
                visible: gameLogic.state === 1
                Column {
                    anchors.centerIn: parent
                    spacing: 10
                    Text { text: "S N A K E"; color: p3; font.pixelSize: 30 }
                    Text { text: "START to Play"; color: p3; font.pixelSize: 10 }
                    Text { text: "LEVEL: " + gameLogic.currentLevelName; color: p3; font.pixelSize: 8 }
                }
            }
        }

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
