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

        // --- 1. 渲染源 ---
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
                property color gridColor: gameLogic.coverage > 0.5 ? Qt.lerp(p1, "#ff0000", Math.abs(Math.sin(elapsed * 5.0)) * 0.3) : p1
                onPaint: { 
                    var ctx = getContext("2d")
                    ctx.strokeStyle = gridColor
                    ctx.lineWidth = 1.5
                    ctx.beginPath()
                    for (var i = 0; i <= gameLogic.boardWidth; i = i + 1) { 
                        var xPos = i * (width / gameLogic.boardWidth)
                        ctx.moveTo(xPos, 0)
                        ctx.lineTo(xPos, height)
                    } 
                    for (var j = 0; j <= gameLogic.boardHeight; j = j + 1) { 
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
                    function onScoreChanged() { 
                        backgroundGrid.requestPaint() 
                    }
                }
            }

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

                // 几何 PowerUp (全垂直排版，绝无分号)
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
                        
                        // Ghost
                        Rectangle { 
                            anchors.fill: parent
                            border.color: p3
                            color: "transparent"
                            visible: gameLogic.powerUpType === 1
                            Rectangle { 
                                anchors.centerIn: parent
                                width: parent.width * 0.4
                                height: parent.height * 0.4
                                rotation: 45
                                border.color: p3
                                color: "transparent"
                            } 
                        }
                        // Slow
                        Rectangle { 
                            anchors.fill: parent
                            radius: width / 2
                            border.color: p3
                            color: "transparent"
                            border.width: 2
                            visible: gameLogic.powerUpType === 2
                            Rectangle { 
                                width: parent.width * 0.5
                                height: 2
                                color: p3
                                anchors.centerIn: parent
                            } 
                        }
                        // Magnet
                        Rectangle { 
                            anchors.centerIn: parent
                            width: parent.width * 0.8
                            height: parent.height * 0.8
                            color: p3
                            visible: gameLogic.powerUpType === 3
                            clip: true
                            Rectangle { 
                                width: parent.width
                                height: parent.height
                                rotation: 45
                                y: parent.height * 0.5
                                color: p0 
                            } 
                        }
                        // Shield
                        Rectangle { 
                            anchors.fill: parent
                            radius: width / 2
                            border.color: p3
                            color: "transparent"
                            border.width: 2
                            visible: gameLogic.powerUpType === 4
                            Rectangle { 
                                width: parent.width * 0.6
                                height: 2
                                color: p3
                                anchors.centerIn: parent
                            } 
                            Rectangle { 
                                height: parent.height * 0.6
                                width: 2
                                color: p3
                                anchors.centerIn: parent
                            } 
                        }
                        // Portal
                        Rectangle { 
                            anchors.fill: parent
                            radius: width / 2
                            border.color: p3
                            color: "transparent"
                            visible: gameLogic.powerUpType === 5
                            Rectangle { 
                                anchors.centerIn: parent
                                width: parent.width * 0.5
                                height: parent.height * 0.5
                                radius: width / 2
                                border.color: p3
                            } 
                        }
                        // Double
                        Rectangle { 
                            anchors.centerIn: parent
                            width: parent.width * 0.8
                            height: parent.height * 0.8
                            rotation: 45
                            color: "#ffd700"
                            visible: gameLogic.powerUpType === 6
                        }
                        // Rich
                        Rectangle { 
                            anchors.centerIn: parent
                            width: parent.width * 0.8
                            height: parent.height * 0.8
                            rotation: 45
                            color: "#00ffff"
                            visible: gameLogic.powerUpType === 7
                        }
                        // Laser
                        Rectangle { 
                            anchors.fill: parent
                            border.color: "#ff0000"
                            color: "transparent"
                            border.width: 2
                            visible: gameLogic.powerUpType === 8
                            Rectangle { 
                                width: 4
                                height: 4
                                color: "#ff0000"
                                anchors.centerIn: parent
                            } 
                        }
                        // Mini
                        Rectangle { 
                            anchors.fill: parent
                            border.color: p3
                            color: "transparent"
                            visible: gameLogic.powerUpType === 9
                            Rectangle { 
                                width: 4
                                height: 4
                                color: p3
                                anchors.centerIn: parent
                            } 
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
                        width: gameWorld.width / gameLogic.boardWidth
                        height: gameWorld.height / gameLogic.boardHeight
                        color: gameLogic.activeBuff === 6 ? (Math.floor(elapsed * 10) % 2 === 0 ? "#ffd700" : p3) : (index === 0 ? p3 : p2)
                        radius: index === 0 ? 2 : 0
                        Rectangle { 
                            anchors.fill: parent
                            anchors.margins: -2
                            border.color: "#00ffff"
                            border.width: 1
                            radius: parent.radius + 2
                            visible: index === 0 && gameLogic.shieldActive 
                        }
                    }
                }

                Repeater {
                    model: gameLogic.obstacles
                    Rectangle { 
                        x: modelData.x * (240 / gameLogic.boardWidth)
                        y: modelData.y * (216 / gameLogic.boardHeight)
                        width: 240 / gameLogic.boardWidth
                        height: 216 / gameLogic.boardHeight
                        color: p3
                        Rectangle { 
                            anchors.fill: parent
                            anchors.margins: 2
                            color: p0 
                        }
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                color: p0
                visible: gameLogic.state === 1
                z: 50
                Image { 
                    source: "qrc:/src/qml/icon.svg"
                    anchors.fill: parent
                    opacity: 0.05
                    fillMode: Image.Tile 
                }
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
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text { 
                            text: "LEVEL: " + gameLogic.currentLevelName
                            font.family: gameFont
                            font.pixelSize: 10
                            color: p3
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter 
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

            // Roguelike UI (全垂直)
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
                                    // Ghost
                                    Rectangle { anchors.centerIn: parent; width: 12; height: 12; border.color: p3; color: "transparent"; visible: modelData.type === 1 }
                                    // Slow
                                    Rectangle { anchors.centerIn: parent; width: 14; height: 14; radius: 7; border.color: p3; color: "transparent"; visible: modelData.type === 2 }
                                    // Magnet
                                    Rectangle { anchors.centerIn: parent; width: 14; height: 14; color: p3; visible: modelData.type === 3 }
                                    // Shield
                                    Rectangle { anchors.centerIn: parent; width: 14; height: 14; radius: 7; color: p3; visible: modelData.type === 4 }
                                    // Portal
                                    Rectangle { anchors.centerIn: parent; width: 14; height: 14; radius: 7; border.color: p3; color: "transparent"; visible: modelData.type === 5 }
                                    // Double
                                    Rectangle { anchors.centerIn: parent; width: 12; height: 12; rotation: 45; color: "#ffd700"; visible: modelData.type === 6 }
                                    // Rich
                                    Rectangle { anchors.centerIn: parent; width: 12; height: 12; rotation: 45; color: "#00ffff"; visible: modelData.type === 7 }
                                    // Laser
                                    Rectangle { anchors.centerIn: parent; width: 14; height: 14; border.color: "#ff0000"; color: "transparent"; visible: modelData.type === 8 }
                                    // Mini
                                    Rectangle { anchors.centerIn: parent; width: 14; height: 14; border.color: p3; color: "transparent"; visible: modelData.type === 9 }
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
                    Text { 
                        text: "FRUIT CATALOG"
                        color: p3
                        font.family: gameFont
                        font.pixelSize: 20
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter 
                    }
                    ListView {
                        width: parent.width
                        height: parent.height - 60
                        model: gameLogic.fruitLibrary
                        currentIndex: gameLogic.libraryIndex
                        spacing: 6
                        clip: true
                        delegate: Rectangle {
                            width: parent.width
                            height: 36
                            color: gameLogic.libraryIndex === index ? p2 : p1
                            border.color: p3
                            Row { 
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 10
                                Item { 
                                    width: 20
                                    height: 20
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text { 
                                        text: "?"
                                        visible: !modelData.discovered
                                        anchors.centerIn: parent
                                        color: p3 
                                    } 
                                }
                                Column { 
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text { text: modelData.name; color: p3; font.bold: true; font.pixelSize: 9 }
                                    Text { text: modelData.desc; color: p3; font.pixelSize: 6; opacity: 0.7 } 
                                }
                            }
                        }
                    }
                }
            }
        }

        // --- 2. 覆盖层 ---
        Column {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 10
            z: 500
            visible: gameLogic.state >= 2 && gameLogic.state <= 6
            Text { 
                text: "HI " + gameLogic.highScore
                color: p3
                font.family: gameFont
                font.pixelSize: 8
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
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 10
            width: 80
            height: 12
            color: Qt.rgba(p3.r, p3.g, p3.b, 0.2)
            radius: 2
            z: 500
            visible: gameLogic.state === 2 && gameLogic.activeBuff > 0
            Text { 
                anchors.centerIn: parent
                font.family: gameFont
                font.pixelSize: 6
                font.bold: true
                color: p3
                text: { 
                    var n = ["", "GHOST", "SLOW", "MAGNET", "SHIELD", "PORTAL", "2X", "3X", "LASER", "MINI"]
                    return n[gameLogic.activeBuff] + " ACTIVE"
                } 
            }
        }

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 10
            width: 60
            height: 12
            color: "red"
            z: 800
            visible: gameLogic.state === 5
            Text { 
                text: "REPLAYING"
                color: "white"
                font.pixelSize: 7
                font.bold: true
                anchors.centerIn: parent
                SequentialAnimation on opacity { 
                    loops: Animation.Infinite
                    NumberAnimation { from: 1; to: 0.4; duration: 400 }
                    NumberAnimation { from: 0.4; to: 1; duration: 400 } 
                } 
            }
        }

        OSDLayer { id: osd; p0: root.p0; p3: root.p3; gameFont: root.gameFont; z: 3000 }

        // --- 3. 着色器 & 物理层 ---
        ShaderEffect {
            id: lcdShader
            anchors.fill: parent
            property variant source: ShaderEffectSource { sourceItem: gameContent; hideSource: true; live: true }
            property variant history: ShaderEffectSource { sourceItem: lcdShader; live: true; recursive: true }
            property real time: root.elapsed
            fragmentShader: "qrc:/shaders/src/qml/lcd.frag.qsb"
            z: 20
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
    }

    function showOSD(t) { osd.show(t) }
    function triggerPowerCycle() { console.log("Pulse") }
}
