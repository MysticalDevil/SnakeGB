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

    function handleDirection(dx, dy) {
        gameLogic.move(dx, dy)
        if (dy < 0) shell.dpad.upPressed = true
        else if (dy > 0) shell.dpad.downPressed = true
        else if (dx < 0) shell.dpad.leftPressed = true
        else if (dx > 0) shell.dpad.rightPressed = true
    }

    function clearDpadVisuals() {
        shell.dpad.upPressed = false
        shell.dpad.downPressed = false
        shell.dpad.leftPressed = false
        shell.dpad.rightPressed = false
    }

    Timer {
        id: longPressTimer
        interval: 1000
        onTriggered: { 
            if (gameLogic.state === 1) { 
                gameLogic.deleteSave()
                screen.showOSD(qsTr("Save Cleared")) 
            } 
        }
    }

    Connections {
        target: gameLogic
        function onPaletteChanged() { 
            screen.showOSD(gameLogic.paletteName) 
        }
        function onShellColorChanged() { 
            screen.triggerPowerCycle() 
        }
        function onAchievementEarned(title) { 
            screen.showOSD("UNLOCKED: " + title) 
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

                Connections {
                    target: shell.dpad
                    function onUpClicked() { handleDirection(0, -1) }
                    function onDownClicked() { handleDirection(0, 1) }
                    function onLeftClicked() { handleDirection(-1, 0) }
                    function onRightClicked() { handleDirection(1, 0) }
                }

                Connections { 
                    target: shell.aButton
                    function onClicked() { gameLogic.handleStart() } 
                }

                Connections { 
                    target: shell.bButton
                    function onClicked() { 
                        if (gameLogic.state === 1) gameLogic.quit()
                        else if (gameLogic.state >= 3) gameLogic.quitToMenu()
                        else gameLogic.nextPalette()
                    } 
                }

                Connections { 
                    target: shell.selectButton
                    function onPressed() { longPressTimer.start() }
                    function onReleased() { 
                        if (longPressTimer.running) { 
                            longPressTimer.stop()
                            gameLogic.handleSelect() 
                        } 
                    } 
                }

                Connections { 
                    target: shell.startButton
                    function onClicked() { gameLogic.handleStart() } 
                }
            }
        }
    }

    Item {
        focus: true
        Keys.onPressed: (event) => {
            if (event.isAutoRepeat) return
            if (event.key === Qt.Key_Up) handleDirection(0, -1)
            else if (event.key === Qt.Key_Down) handleDirection(0, 1)
            else if (event.key === Qt.Key_Left) handleDirection(-1, 0)
            else if (event.key === Qt.Key_Right) handleDirection(1, 0)
            else if (event.key === Qt.Key_S || event.key === Qt.Key_Return) {
                shell.startButton.isPressed = true
                gameLogic.handleStart()
            }
            else if (event.key === Qt.Key_A || event.key === Qt.Key_Z) {
                shell.aButton.isPressed = true
                gameLogic.handleStart()
            }
            else if (event.key === Qt.Key_B || event.key === Qt.Key_X) {
                shell.bButton.isPressed = true
                if (gameLogic.state === 1) gameLogic.quit()
                else if (gameLogic.state >= 3) gameLogic.quitToMenu()
                else gameLogic.nextPalette()
            }
            else if (event.key === Qt.Key_Shift) {
                shell.selectButton.isPressed = true
                longPressTimer.start()
            }
            else if (event.key === Qt.Key_M) gameLogic.toggleMusic()
            else if (event.key === Qt.Key_Escape) gameLogic.quit()
        }
        
        Keys.onReleased: (event) => {
            if (event.isAutoRepeat) return
            clearDpadVisuals()
            if (event.key === Qt.Key_S || event.key === Qt.Key_Return) shell.startButton.isPressed = false
            else if (event.key === Qt.Key_A || event.key === Qt.Key_Z) shell.aButton.isPressed = false
            else if (event.key === Qt.Key_B || event.key === Qt.Key_X) shell.bButton.isPressed = false
            else if (event.key === Qt.Key_Shift) {
                shell.selectButton.isPressed = false
                if (longPressTimer.running) {
                    longPressTimer.stop()
                    gameLogic.handleSelect()
                }
            }
        }
    }
}
