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
                property color gridColor: {
                    if (gameLogic.coverage > 0.5) {
                        return Qt.lerp(p1, "#ff0000", Math.abs(Math.sin(elapsed * 5.0)) * 0.3)
                    }
                    return p1
                }
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.strokeStyle = gridColor;
                    ctx.lineWidth = 1.5;
                    ctx.beginPath();
                    for (var i = 0; i <= gameLogic.boardWidth; i++) {
                        var xPos = i * (width / gameLogic.boardWidth);
                        ctx.moveTo(xPos, 0);
                        ctx.lineTo(xPos, height);
                    }
                    for (var j = 0; j <= gameLogic.boardHeight; j++) {
                        var yPos = j * (height / gameLogic.boardHeight);
                        ctx.moveTo(0, yPos);
                        ctx.lineTo(width, yPos);
                    }
                    ctx.stroke();
                }
                Connections {
                    target: gameLogic
                    function onPaletteChanged() { backgroundGrid.requestPaint(); }
                    function onScoreChanged() { backgroundGrid.requestPaint(); }
                }
                onGridColorChanged: { if (gameLogic.coverage > 0.5) backgroundGrid.requestPaint(); }
            }

            Item {
                id: gameWorld
                anchors.fill: parent
                z: 10
                visible: gameLogic.state >= 2

                // Ghost Replay Layer (z: 5, behind snake)
                Repeater {
                    model: gameLogic.ghost
                    visible: gameLogic.state === 2
                    delegate: Rectangle {
                        x: modelData.x * (gameWorld.width / gameLogic.boardWidth)
                        y: modelData.y * (gameWorld.height / gameLogic.boardHeight)
                        width: gameWorld.width / gameLogic.boardWidth
                        height: gameWorld.height / gameLogic.boardHeight
                        color: p3
                        opacity: 0.35
                        radius: 1
                        z: 5
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 2
                            color: "transparent"
                            border.color: p1
                            border.width: 1
                        }
                    }
                }

                Rectangle {
                    visible: gameLogic.state >= 2
                    x: gameLogic.food.x * (parent.width / gameLogic.boardWidth)
                    y: gameLogic.food.y * (parent.height / gameLogic.boardHeight)
                    width: parent.width / gameLogic.boardWidth
                    height: parent.height / gameLogic.boardHeight
                    color: p3
                    radius: width / 2
                    z: 20
                }

                Item {
                    id: powerUpContainer
                    visible: gameLogic.state >= 2 && gameLogic.powerUpPos.x !== -1
                    x: gameLogic.powerUpPos.x * (parent.width / gameLogic.boardWidth)
                    y: gameLogic.powerUpPos.y * (parent.height / gameLogic.boardHeight)
                    width: parent.width / gameLogic.boardWidth
                    height: parent.height / gameLogic.boardHeight
                    z: 30
                    
                    // Specific Visuals for PowerUp Types
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width * 0.8
                        height: parent.height * 0.8
                        rotation: (gameLogic.activeBuff === 0) ? 45 : 0
                        color: {
                            var type = gameLogic.powerUpType
                            if (type === 6) return "#ffd700" // Golden
                            if (type === 7) return "#00ffff" // Diamond
                            if (type === 8) return "#ff0000" // Laser
                            if (type === 9) return "#ffffff" // Mini
                            return p3
                        }
                        
                        // Internal icon shape
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width * 0.4; height: parent.height * 0.4
                            color: p0
                            visible: gameLogic.powerUpType < 6
                        }

                        // Special Particle Effect for high-tier fruits
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.color: parent.color
                            border.width: 1
                            scale: 1.5
                            opacity: 0.5
                            visible: gameLogic.powerUpType >= 6
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { from: 0.5; to: 0; duration: 400 }
                            }
                        }

                        SequentialAnimation on scale {
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.7; to: 1.2; duration: 300 }
                            NumberAnimation { from: 1.2; to: 0.7; duration: 300 }
                        }
                    }
                }

                Repeater {
                    model: gameLogic.snakeModel
                    delegate: Rectangle {
                        x: model.pos.x * (gameWorld.width / gameLogic.boardWidth)
                        y: model.pos.y * (gameWorld.height / gameLogic.boardHeight)
                        width: gameWorld.width / gameLogic.boardWidth
                        height: gameWorld.height / gameLogic.boardHeight
                        color: {
                            if (gameLogic.activeBuff === 6) return (Math.floor(elapsed * 10) % 2 === 0) ? "#ffd700" : p3
                            if (gameLogic.activeBuff === 7) return (Math.floor(elapsed * 15) % 2 === 0) ? "#00ffff" : "#ffffff"
                            if (gameLogic.activeBuff === 8) return "#ff4444"
                            return index === 0 ? p3 : p2
                        }
                        radius: index === 0 ? 2 : 1
                        opacity: gameLogic.activeBuff === 1 ? 0.4 : 1.0
                        border.color: p0; border.width: index === 0 ? 1 : 0
                        z: 15

                        // Shield visual effect
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: -2
                            color: "transparent"
                            border.color: "#00ffff"
                            border.width: 1
                            radius: parent.radius + 2
                            visible: index === 0 && gameLogic.shieldActive
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { from: 0.2; to: 0.8; duration: 500 }
                                NumberAnimation { from: 0.8; to: 0.2; duration: 500 }
                            }
                        }
                    }
                }

                Repeater {
                    model: gameLogic.obstacles
                    Rectangle {
                        x: modelData.x * (gameWorld.width / gameLogic.boardWidth)
                        y: modelData.y * (gameWorld.height / gameLogic.boardHeight)
                        width: gameWorld.width / gameLogic.boardWidth
                        height: gameWorld.height / gameLogic.boardHeight
                        color: p3; z: 12
                        Rectangle { anchors.fill: parent; anchors.margins: 2; color: p0 }
                    }
                }
            }

            Rectangle { 
                id: splashLayer
                anchors.fill: parent
                color: p0
                visible: gameLogic.state === 0 || bootAnim.running
                z: 200
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
                    NumberAnimation { 
                        target: bootText
                        property: "y"
                        from: -50
                        to: 80
                        duration: 600
                        easing.type: Easing.OutBounce 
                    }
                }
            }

            Rectangle {
                id: powerFlash
                anchors.fill: parent
                color: "black"
                opacity: 0
                z: 300
                SequentialAnimation {
                    id: flashEffect
                    NumberAnimation { target: powerFlash; property: "opacity"; from: 0; to: 1; duration: 50 }
                    PauseAnimation { duration: 100 }
                    ScriptAction { script: bootAnim.restart() }
                    NumberAnimation { target: powerFlash; property: "opacity"; from: 1; to: 0; duration: 300 }
                }
            }

            Rectangle {
                anchors.fill: parent
                color: p0
                visible: gameLogic.state === 1 && !bootAnim.running
                z: 50
                Column {
                    anchors.centerIn: parent
                    spacing: 6
                    Text { text: "S N A K E"; font.family: gameFont; font.pixelSize: 32; color: p3; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: "LEVEL: " + gameLogic.currentLevelName; font.family: gameFont; font.pixelSize: 10; color: p3; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: "HI-SCORE: " + gameLogic.highScore; font.family: gameFont; font.pixelSize: 12; color: p3; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { 
                        text: "UP: Medals | DOWN: Replay"
                        font.family: gameFont
                        font.pixelSize: 8
                        color: gameLogic.hasReplay ? p3 : Qt.rgba(p3.r, p3.g, p3.b, 0.3)
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
                Text { text: "HI " + gameLogic.highScore; color: p3; font.family: gameFont; font.pixelSize: 10; font.bold: true; anchors.right: parent.right }
                Text { text: "SC " + gameLogic.score; color: p3; font.family: gameFont; font.pixelSize: 12; font.bold: true; anchors.right: parent.right }
            }

            // Active Effect Status Bar
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 4
                width: 80; height: 12
                color: Qt.rgba(p3.r, p3.g, p3.b, 0.2)
                visible: gameLogic.state === 2 && gameLogic.activeBuff > 0
                z: 65
                radius: 2
                Text {
                    id: statusText
                    anchors.centerIn: parent
                    font.family: gameFont
                    font.pixelSize: 6
                    font.bold: true
                    color: p3
                    text: {
                        var names = ["", "GHOST", "SLOW", "MAGNET", "SHIELD", "PORTAL", "GOLD", "RICH", "LASER", "MINI"]
                        return names[gameLogic.activeBuff] + " ACTIVE"
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(p0.r, p0.g, p0.b, 0.6)
                visible: gameLogic.state === 3
                z: 70
                Text { text: "PAUSED"; font.family: gameFont; font.pixelSize: 32; font.bold: true; color: p3; anchors.centerIn: parent }
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
                    Text { text: "Press B to Menu"; font.family: gameFont; font.pixelSize: 12; color: p0; anchors.horizontalCenter: parent.horizontalCenter }
                }
            }

            OSDLayer { id: osd; p0: root.p0; p3: root.p3; gameFont: root.gameFont; z: 100 }

            // Choice Selection Layer (Roguelike)
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(p0.r, p0.g, p0.b, 0.9)
                visible: gameLogic.state === 6 // ChoiceSelection
                z: 105

                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    width: parent.width - 40

                    Text {
                        text: "LEVEL UP!"
                        color: p3
                        font.family: gameFont
                        font.pixelSize: 16
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "DPAD to Select | START to Confirm"
                        color: p3
                        font.family: gameFont
                        font.pixelSize: 7
                        anchors.horizontalCenter: parent.horizontalCenter
                        opacity: 0.8
                    }

                    Repeater {
                        model: gameLogic.choices
                        delegate: Rectangle {
                            id: choiceRect
                            width: parent.width
                            height: 40
                            color: gameLogic.choiceIndex === index ? p2 : p1
                            border.color: p3
                            border.width: gameLogic.choiceIndex === index ? 3 : 1
                            radius: 4

                            // Selection Arrow Indicator
                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 5
                                anchors.verticalCenter: parent.verticalCenter
                                text: ">"
                                color: p3
                                visible: gameLogic.choiceIndex === index
                                font.family: gameFont
                                font.bold: true
                            }

                            Column {
                                anchors.centerIn: parent
                                spacing: 1
                                Text {
                                    text: modelData.name
                                    color: p3
                                    font.family: gameFont
                                    font.pixelSize: 10
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: modelData.desc
                                    color: p3
                                    font.family: gameFont
                                    font.pixelSize: 7
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }

                            MouseArea {
                                id: mouseAreaChoice
                                anchors.fill: parent
                                onClicked: {
                                    gameLogic.requestFeedback(5)
                                    gameLogic.selectChoice(index)
                                }
                            }
                        }
                    }
                }
            }

            // Active Effect Status Bar
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 4
                width: 80; height: 12
                color: Qt.rgba(p3.r, p3.g, p3.b, 0.2)
                visible: gameLogic.state === 2 && gameLogic.activeBuff > 0
                z: 65
                radius: 2
                Text {
                    id: statusText
                    anchors.centerIn: parent
                    font.family: gameFont
                    font.pixelSize: 6
                    font.bold: true
                    color: p3
                    text: {
                        var names = ["", "GHOST", "SLOW", "MAGNET", "SHIELD", "PORTAL", "GOLD", "RICH", "LASER", "MINI"]
                        return names[gameLogic.activeBuff] + " ACTIVE"
                    }
                }
            }

            MedalRoom { id: medalRoom; p0: root.p0; p3: root.p3; gameFont: root.gameFont; visible: root.showingMedals; z: 110; onCloseRequested: { root.showingMedals = false; } }

            // Fruit Encyclopedia Layer (Hidden)
            Rectangle {
                anchors.fill: parent
                color: p0
                visible: gameLogic.state === 7 // Library
                z: 120

                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5

                    Text {
                        text: "FRUIT CATALOG"
                        color: p3
                        font.family: gameFont
                        font.pixelSize: 14
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    ListView {
                        width: parent.width
                        height: parent.height - 40
                        model: gameLogic.fruitLibrary
                        clip: true
                        spacing: 4
                        delegate: Rectangle {
                            width: parent.width
                            height: 35
                            color: modelData.discovered ? p1 : Qt.darker(p1, 1.5)
                            border.color: modelData.discovered ? p3 : p2
                            border.width: 1

                            Row {
                                anchors.fill: parent
                                anchors.margins: 5
                                spacing: 10
                                Rectangle {
                                    width: 20; height: 20
                                    color: {
                                        if (!modelData.discovered) return p2
                                        if (modelData.type === 6) return "#ffd700"
                                        if (modelData.type === 7) return "#00ffff"
                                        if (modelData.type === 8) return "#ff0000"
                                        return p3
                                    }
                                    anchors.verticalCenter: parent.verticalCenter
                                    rotation: 45
                                }
                                Column {
                                    width: parent.width - 40
                                    Text { text: modelData.name; color: p3; font.family: gameFont; font.pixelSize: 9; font.bold: true }
                                    Text { text: modelData.desc; color: p3; font.family: gameFont; font.pixelSize: 7; width: parent.width; wrapMode: Text.WordWrap; opacity: 0.8 }
                                }
                            }
                        }
                    }

                    Text {
                        text: "START to Back"
                        color: p3
                        font.family: gameFont
                        font.pixelSize: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
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

    function showOSD(text) { osd.show(text); }
    function triggerPowerCycle() { flashEffect.restart(); }
}
