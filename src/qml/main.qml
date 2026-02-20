import QtQuick
import QtQuick.Controls

Window {
    id: window
    width: 350
    height: 550
    visible: true
    title: qsTr("Snake GB Edition")
    color: "#1a1a1a"

    // Detect if we are on a mobile platform
    readonly property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios"
    
    readonly property color p0: gameLogic.palette[0]
    readonly property color p1: gameLogic.palette[1]
    readonly property color p2: gameLogic.palette[2]
    readonly property color p3: gameLogic.palette[3]
    readonly property string gameFont: "Monospace"

    property real elapsed: 0.0
    property bool showingMedals: false

    NumberAnimation on elapsed { from: 0; to: 1000; duration: 1000000; loops: Animation.Infinite }

    Timer {
        id: longPressTimer; interval: 1500
        onTriggered: {
            if (gameLogic.state === 1 && gameLogic.hasSave) {
                gameLogic.deleteSave()
                osd.show(qsTr("Save Cleared"))
            }
        }
    }

    Connections {
        target: gameLogic
        function onPaletteChanged() { osd.show(gameLogic.paletteName) }
        function onShellColorChanged() { osd.show(qsTr("Shell Swapped")) }
        function onAchievementEarned(title) { osd.show("UNLOCKED: " + title) }
        function onBuffChanged() {
            if (gameLogic.activeBuff !== 0) {
                var names = ["", "GHOST MODE", "SLOW DOWN", "MAGNET ON"]
                osd.show(names[gameLogic.activeBuff])
            }
        }
    }

    // --- Main Container with Smart Scaling ---
    Item {
        id: rootContainer
        anchors.fill: parent
        
        Item {
            id: scaledWrapper
            width: 350
            height: 550
            anchors.centerIn: parent
            
            // Calculate scale based on fitting the shell to screen
            scale: {
                var scaleX = window.width / width
                var scaleY = window.height / height
                return Math.min(scaleX, scaleY)
            }

            GameBoyShell {
                id: shell
                anchors.fill: parent
                
                GameScreen {
                    anchors.fill: parent
                    parent: shell.screenContainer
                    p0: window.p0; p1: window.p1; p2: window.p2; p3: window.p3
                    gameFont: window.gameFont; elapsed: window.elapsed
                }

                Item {
                    anchors.fill: shell.screenContainer
                    
                    Rectangle { anchors.fill: parent; color: p0; visible: gameLogic.state === 0; Text { text: "S N A K E"; anchors.centerIn: parent; font.pixelSize: 32; color: p3 } }
                    
                    Rectangle {
                        anchors.fill: parent; color: p0; visible: gameLogic.state === 1
                        Column {
                            anchors.centerIn: parent; spacing: 6
                            Text { text: "S N A K E"; font.pixelSize: 32; color: p3; anchors.horizontalCenter: parent.horizontalCenter }
                            Text { text: "LEVEL: " + gameLogic.currentLevelName; font.pixelSize: 10; color: p3; anchors.horizontalCenter: parent.horizontalCenter }
                            Text { text: qsTr("UP: Medals | DOWN: Replay"); font.pixelSize: 8; color: p3; anchors.horizontalCenter: parent.horizontalCenter }
                            Text { text: gameLogic.hasSave ? qsTr("START to Continue") : qsTr("START to Play"); font.pixelSize: 14; color: p3; anchors.horizontalCenter: parent.horizontalCenter }
                        }
                    }

                    OSDLayer { id: osd; p0: window.p0; p3: window.p3; gameFont: window.gameFont }
                    
                    MedalRoom {
                        p0: window.p0; p3: window.p3; gameFont: window.gameFont
                        visible: showingMedals
                        onCloseRequested: showingMedals = false
                    }
                }

                // Interaction
                dpad.onUpClicked: { if (gameLogic.state === 1) showingMedals = true; else gameLogic.move(0, -1) }
                dpad.onDownClicked: { if (gameLogic.state === 1 && gameLogic.hasReplay) gameLogic.startReplay(); else gameLogic.move(0, 1) }
                dpad.onLeftClicked: gameLogic.move(-1, 0)
                dpad.onRightClicked: gameLogic.move(1, 0)
                aButton.onClicked: { if (showingMedals) showingMedals = false; else gameLogic.handleStart() }
                bButton.onClicked: {
                    if (showingMedals) showingMedals = false
                    else if (gameLogic.state === 1) gameLogic.quit()
                    else if (gameLogic.state >= 3) gameLogic.quitToMenu()
                    else gameLogic.nextPalette()
                }
                selectButton.onPressed: longPressTimer.start()
                selectButton.onReleased: { if (longPressTimer.running) { longPressTimer.stop(); gameLogic.handleSelect() } }
                startButton.onClicked: gameLogic.handleStart()
            }
        }
    }

    Item {
        focus: true
        Keys.onPressed: (event) => {
            if (event.isAutoRepeat) return
            if (event.key === Qt.Key_Up) { shell.dpad.upPressed = true; if (gameLogic.state === 1) showingMedals = true; else gameLogic.move(0, -1) }
            else if (event.key === Qt.Key_Down) { shell.dpad.downPressed = true; if (gameLogic.state === 1 && gameLogic.hasReplay) gameLogic.startReplay(); else gameLogic.move(0, 1) }
            else if (event.key === Qt.Key_Left) { shell.dpad.leftPressed = true; gameLogic.move(-1, 0) }
            else if (event.key === Qt.Key_Right) { shell.dpad.rightPressed = true; gameLogic.move(1, 0) }
            else if (event.key === Qt.Key_S || event.key === Qt.Key_Return) { shell.startButton.isPressed = true; gameLogic.handleStart() }
            else if (event.key === Qt.Key_A || event.key === Qt.Key_Z) { shell.aButton.isPressed = true; gameLogic.handleStart() }
            else if (event.key === Qt.Key_B || event.key === Qt.Key_X) { shell.bButton.isPressed = true; if (gameLogic.state === 1) gameLogic.quit(); else if (gameLogic.state >= 3) gameLogic.quitToMenu(); else gameLogic.nextPalette(); }
            else if (event.key === Qt.Key_Shift) { shell.selectButton.isPressed = true; longPressTimer.start() }
            else if (event.key === Qt.Key_M) gameLogic.toggleMusic()
            else if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q) gameLogic.quit()
            else if (event.key === Qt.Key_Back) { if (showingMedals) showingMedals = false; else if (gameLogic.state === 1) gameLogic.quit(); else gameLogic.quitToMenu(); }
        }
        Keys.onReleased: (event) => {
            if (event.isAutoRepeat) return
            if (event.key === Qt.Key_Up) shell.dpad.upPressed = false
            else if (event.key === Qt.Key_Down) shell.dpad.downPressed = false
            else if (event.key === Qt.Key_Left) shell.dpad.leftPressed = false
            else if (event.key === Qt.Key_Right) shell.dpad.rightPressed = false
            else if (event.key === Qt.Key_S || event.key === Qt.Key_Return) shell.startButton.isPressed = false
            else if (event.key === Qt.Key_A || event.key === Qt.Key_Z) shell.aButton.isPressed = false
            else if (event.key === Qt.Key_B || event.key === Qt.Key_X) shell.bButton.isPressed = false
            else if (event.key === Qt.Key_Shift) { shell.selectButton.isPressed = false; if (longPressTimer.running) { longPressTimer.stop(); gameLogic.handleSelect() } }
        }
    }
}
