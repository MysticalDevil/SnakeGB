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

        // --- 1. GAME CONTENT (Under Shader) ---
        Item {
            id: gameContent
            anchors.fill: parent
            
            Rectangle { anchors.fill: parent; color: p0; z: -1 }
            
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
                        var x = i * (width / gameLogic.boardWidth)
                        ctx.moveTo(x, 0)
                        ctx.lineTo(x, height)
                    } 
                    for (var j = 0; j <= gameLogic.boardHeight; j++) { 
                        var y = j * (height / gameLogic.boardHeight)
                        ctx.moveTo(0, y)
                        ctx.lineTo(width, y)
                    } 
                    ctx.stroke() 
                }
                Connections { target: gameLogic; function onPaletteChanged() { backgroundGrid.requestPaint() } }
            }

            Item {
                id: gameWorld
                anchors.fill: parent; z: 10
                visible: gameLogic.state >= 2 && gameLogic.state <= 6

                // Food & PowerUps
                Rectangle { x: gameLogic.food.x * (parent.width / gameLogic.boardWidth); y: gameLogic.food.y * (parent.height / gameLogic.boardHeight); width: parent.width / gameLogic.boardWidth; height: parent.height / gameLogic.boardHeight; color: p3; radius: width / 2; z: 20 }
                
                Item {
                    id: powerUpItem; visible: gameLogic.powerUpPos.x !== -1; z: 30
                    x: gameLogic.powerUpPos.x * (parent.width / gameLogic.boardWidth); y: gameLogic.powerUpPos.y * (parent.height / gameLogic.boardHeight); width: parent.width / gameLogic.boardWidth; height: parent.height / gameLogic.boardHeight
                    Rectangle { 
                        anchors.centerIn: parent; width: parent.width*0.8; height: parent.height*0.8; rotation: 45; color: p3
                        SequentialAnimation on scale { loops: Animation.Infinite; NumberAnimation { from: 0.7; to: 1.2; duration: 300 }; NumberAnimation { from: 1.2; to: 0.7; duration: 300 } }
                    }
                }

                // Snake body
                Repeater {
                    model: gameLogic.snakeModel
                    delegate: Rectangle {
                        x: model.pos.x * (gameWorld.width / gameLogic.boardWidth); y: model.pos.y * (gameWorld.height / gameLogic.boardHeight); width: gameWorld.width / gameLogic.boardWidth; height: gameWorld.height / gameLogic.boardHeight
                        color: (gameLogic.activeBuff === 6) ? ((Math.floor(elapsed * 10) % 2 === 0) ? "#ffd700" : p3) : (index === 0 ? p3 : p2)
                        radius: index === 0 ? 2 : 1; opacity: gameLogic.activeBuff === 1 ? 0.4 : 1.0; z: 15
                        Rectangle { anchors.fill: parent; anchors.margins: -2; color: "transparent"; border.color: "#00ffff"; border.width: 1; radius: parent.radius+2; visible: index === 0 && gameLogic.shieldActive }
                    }
                }

                // Obstacles
                Repeater {
                    model: gameLogic.obstacles
                    Rectangle { x: modelData.x * (gameWorld.width / gameLogic.boardWidth); y: modelData.y * (gameWorld.height / gameLogic.boardHeight); width: gameWorld.width / gameLogic.boardWidth; height: gameWorld.height / gameLogic.boardHeight; color: p3; z: 12; Rectangle { anchors.fill: parent; anchors.margins: 2; color: p0 } }
                }
            }
        }

        // --- 2. LCD SHADER LAYER ---
        ShaderEffect {
            anchors.fill: parent
            property variant source: ShaderEffectSource { sourceItem: gameContent; hideSource: true; live: true }
            property real time: root.elapsed
            fragmentShader: "qrc:/shaders/src/qml/lcd.frag.qsb"
            z: 20
        }

        // --- 3. OVERLAY UI (Above Shader) ---
        
        // Splash Animation
        Rectangle {
            id: splashLayer; anchors.fill: parent; color: p0; visible: gameLogic.state === 0 || bootAnim.running; z: 100
            Text { id: bootText; text: "S N A K E"; anchors.centerIn: parent; font.family: gameFont; font.pixelSize: 32; color: p3; font.bold: true; y: -50 }
            SequentialAnimation {
                id: bootAnim; running: gameLogic.state === 0
                PauseAnimation { duration: 200 }
                NumberAnimation { target: bootText; property: "y"; from: -50; to: 80; duration: 600; easing.type: Easing.OutBounce }
            }
        }

        // Main Menu
        Rectangle {
            anchors.fill: parent; color: p0; visible: gameLogic.state === 1 && !bootAnim.running; z: 100
            Column {
                anchors.centerIn: parent; spacing: 6
                Text { text: "S N A K E"; font.family: gameFont; font.pixelSize: 32; color: p3; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                Text { text: "LEVEL: " + gameLogic.currentLevelName; font.family: gameFont; font.pixelSize: 10; color: p3; anchors.horizontalCenter: parent.horizontalCenter }
                Text { text: "HI-SCORE: " + gameLogic.highScore; font.family: gameFont; font.pixelSize: 12; color: p3; anchors.horizontalCenter: parent.horizontalCenter }
                Text { text: "UP: Medals | DOWN: Replay"; font.family: gameFont; font.pixelSize: 8; color: gameLogic.hasReplay ? p3 : Qt.rgba(p3.r, p3.g, p3.b, 0.3); anchors.horizontalCenter: parent.horizontalCenter }
            }
        }

        // HUD (Play State)
        Column { 
            anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 4; z: 150
            visible: gameLogic.state >= 2 && gameLogic.state <= 6
            Text { text: "HI " + gameLogic.highScore; color: p3; font.family: gameFont; font.pixelSize: 8; anchors.right: parent.right }
            Text { text: "SC " + gameLogic.score; color: p3; font.family: gameFont; font.pixelSize: 10; font.bold: true; anchors.right: parent.right }
        }

        // Choice Selection
        Rectangle {
            anchors.fill: parent; color: Qt.rgba(p0.r, p0.g, p0.b, 0.95); visible: gameLogic.state === 6; z: 200
            Column {
                anchors.centerIn: parent; spacing: 8; width: parent.width - 40
                Text { text: "LEVEL UP!"; color: p3; font.family: gameFont; font.pixelSize: 16; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                Repeater {
                    model: gameLogic.choices
                    delegate: Rectangle {
                        width: parent.width; height: 35; color: gameLogic.choiceIndex === index ? p2 : p1; border.color: p3; border.width: gameLogic.choiceIndex === index ? 2 : 1; radius: 4
                        Text { anchors.left: parent.left; anchors.leftMargin: 5; anchors.verticalCenter: parent.verticalCenter; text: ">"; color: p3; visible: gameLogic.choiceIndex === index; font.bold: true }
                        Column { anchors.centerIn: parent; Text { text: modelData.name; color: p3; font.family: gameFont; font.pixelSize: 9; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter } Text { text: modelData.desc; color: p3; font.family: gameFont; font.pixelSize: 6; anchors.horizontalCenter: parent.horizontalCenter } }
                    }
                }
            }
        }

        // Secondary Screens
        MedalRoom { id: medalRoom; p0: root.p0; p3: root.p3; gameFont: root.gameFont; visible: gameLogic.state === 8; z: 300 }
        
        Rectangle {
            id: libraryLayer; anchors.fill: parent; color: p0; visible: gameLogic.state === 7; z: 300
            Column {
                anchors.fill: parent; anchors.margins: 10; spacing: 5
                Text { text: "FRUIT CATALOG"; color: p3; font.family: gameFont; font.pixelSize: 14; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                ListView {
                    id: libraryList; width: parent.width; height: parent.height - 40; model: gameLogic.fruitLibrary; currentIndex: gameLogic.libraryIndex; clip: true; spacing: 4
                    onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
                    delegate: Rectangle {
                        width: parent.width; height: 30; color: gameLogic.libraryIndex === index ? p2 : (modelData.discovered ? p1 : Qt.darker(p1, 1.5)); border.color: gameLogic.libraryIndex === index ? p3 : p2; border.width: 1
                        Row { anchors.fill: parent; anchors.margins: 5; spacing: 10; Rectangle { width: 16; height: 16; rotation: 45; color: modelData.discovered ? p3 : p2; anchors.verticalCenter: parent.verticalCenter } Column { Text { text: modelData.name; color: p3; font.pixelSize: 8; font.bold: true } Text { text: modelData.desc; color: p3; font.pixelSize: 6; opacity: 0.8 } } }
                    }
                }
            }
        }

        OSDLayer { id: osd; p0: root.p0; p3: root.p3; gameFont: root.gameFont; z: 500 }
    }

    function showOSD(text) { osd.show(text) }
    function triggerPowerCycle() { /* Placeholder for future hardware effects */ }
}
