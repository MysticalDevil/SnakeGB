import QtQuick
import QtQuick.Controls

Window {
    id: window
    width: 350
    height: 550
    visible: true
    title: qsTr("Snake GB Edition")
    color: "#1a1a1a"

    readonly property color p0: gameLogic.palette[0]
    readonly property color p1: gameLogic.palette[1]
    readonly property color p2: gameLogic.palette[2]
    readonly property color p3: gameLogic.palette[3]
    readonly property string gameFont: "Monospace"

    property real elapsed: 0.0

    NumberAnimation on elapsed { 
        from: 0 
        to: 1000 
        duration: 1000000 
        loops: Animation.Infinite 
    }

    Timer {
        id: longPressTimer
        interval: 1500
        onTriggered: {
            if (gameLogic.state === 1 && gameLogic.hasSave) {
                gameLogic.deleteSave()
                screen.showOSD(qsTr("Save Cleared"))
            }
        }
    }

    Connections {
        target: gameLogic
        function onPaletteChanged() { screen.showOSD(gameLogic.paletteName) }
        function onShellColorChanged() { screen.showOSD(qsTr("Shell Swapped")) }
        function onAchievementEarned(title) { screen.showOSD("UNLOCKED: " + title) }
        function onBuffChanged() {
            if (gameLogic.activeBuff !== 0) {
                var names = ["", "GHOST MODE", "SLOW DOWN", "MAGNET ON"]
                screen.showOSD(names[gameLogic.activeBuff])
            }
        }
    }

    Item {
        id: rootContainer
        anchors.fill: parent
        
        Item {
            id: scaledWrapper
            width: 350
            height: 550
            anchors.centerIn: parent
            scale: Math.min(window.width / 350, window.height / 550)

            GameBoyShell {
                id: shell
                anchors.fill: parent
                
                GameScreen {
                    id: screen
                    parent: shell.screenContainer
                    anchors.fill: parent
                    p0: window.p0
                    p1: window.p1
                    p2: window.p2
                    p3: window.p3
                    gameFont: window.gameFont
                    elapsed: window.elapsed
                }

                // Correct way to handle nested signals: Connections
                Connections {
                    target: shell.dpad
                    function onUpClicked() { gameLogic.requestFeedback(1); if (gameLogic.state === 1) screen.showingMedals = true; else gameLogic.move(0, -1) }
                    function onDownClicked() { gameLogic.requestFeedback(1); if (gameLogic.state === 1 && gameLogic.hasReplay) gameLogic.startReplay(); else gameLogic.move(0, 1) }
                    function onLeftClicked() { gameLogic.requestFeedback(1); gameLogic.move(-1, 0) }
                    function onRightClicked() { gameLogic.requestFeedback(1); gameLogic.move(1, 0) }
                }

                Connections {
                    target: shell.aButton
                    function onClicked() { gameLogic.requestFeedback(1); if (screen.showingMedals) screen.showingMedals = false; else gameLogic.handleStart() }
                }

                Connections {
                    target: shell.bButton
                    function onClicked() {
                        gameLogic.requestFeedback(1)
                        if (screen.showingMedals) screen.showingMedals = false
                        else if (gameLogic.state === 1) gameLogic.quit()
                        else if (gameLogic.state >= 3) gameLogic.quitToMenu()
                        else gameLogic.nextPalette()
                    }
                }

                Connections {
                    target: shell.selectButton
                    function onPressed() { gameLogic.requestFeedback(1); longPressTimer.start() }
                    function onReleased() { if (longPressTimer.running) { longPressTimer.stop(); gameLogic.handleSelect() } }
                }

                Connections {
                    target: shell.startButton
                    function onClicked() { gameLogic.requestFeedback(1); gameLogic.handleStart() }
                }
            }
        }
    }

    Item {
        focus: true
        Keys.onPressed: (event) => {
            if (event.isAutoRepeat) return
            if (event.key === Qt.Key_Up) { shell.dpad.upPressed = true; if (gameLogic.state === 1) screen.showingMedals = true; else gameLogic.move(0, -1) }
            else if (event.key === Qt.Key_Down) { shell.dpad.downPressed = true; if (gameLogic.state === 1 && gameLogic.hasReplay) gameLogic.startReplay(); else gameLogic.move(0, 1) }
            else if (event.key === Qt.Key_Left) { shell.dpad.leftPressed = true; gameLogic.move(-1, 0) }
            else if (event.key === Qt.Key_Right) { shell.dpad.rightPressed = true; gameLogic.move(1, 0) }
            else if (event.key === Qt.Key_S || event.key === Qt.Key_Return) { shell.startButton.isPressed = true; gameLogic.handleStart() }
            else if (event.key === Qt.Key_A || event.key === Qt.Key_Z) { shell.aButton.isPressed = true; gameLogic.handleStart() }
            else if (event.key === Qt.Key_B || event.key === Qt.Key_X) { shell.bButton.isPressed = true; if (gameLogic.state === 1) gameLogic.quit(); else if (gameLogic.state >= 3) gameLogic.quitToMenu(); else gameLogic.nextPalette(); }
            else if (event.key === Qt.Key_Shift) { shell.selectButton.isPressed = true; longPressTimer.start() }
            else if (event.key === Qt.Key_M) gameLogic.toggleMusic()
            else if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q) gameLogic.quit()
            else if (event.key === Qt.Key_Back) { if (screen.showingMedals) screen.showingMedals = false; else if (gameLogic.state === 1) gameLogic.quit(); else gameLogic.quitToMenu(); }
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
