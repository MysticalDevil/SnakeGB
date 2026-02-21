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
    property bool selectPressActive: false
    property bool selectLongPressConsumed: false
    property bool selectKeyDown: false
    property bool iconDebugMode: false
    property var konamiSeq: ["U","U","D","D","L","R","L","R","B","A"]
    property int konamiIndex: 0
    NumberAnimation on elapsed { 
        from: 0
        to: 1000
        duration: 1000000
        loops: Animation.Infinite 
    }

    function handleDirection(dx, dy) {
        gameLogic.move(dx, dy)
        if (dy < 0) feedEasterInput("U")
        else if (dy > 0) feedEasterInput("D")
        else if (dx < 0) feedEasterInput("L")
        else if (dx > 0) feedEasterInput("R")
        if (dy < 0) {
            shell.dpad.upPressed = true
        } else if (dy > 0) {
            shell.dpad.downPressed = true
        } else if (dx < 0) {
            shell.dpad.leftPressed = true
        } else if (dx > 0) {
            shell.dpad.rightPressed = true
        }
    }

    function clearDpadVisuals() {
        shell.dpad.upPressed = false
        shell.dpad.downPressed = false
        shell.dpad.leftPressed = false
        shell.dpad.rightPressed = false
    }

    function handleBButton() {
        feedEasterInput("B")
        gameLogic.handleBAction()
    }

    function handleAButton() {
        feedEasterInput("A")
        gameLogic.handleStart()
    }

    function feedEasterInput(token) {
        if (token === konamiSeq[konamiIndex]) {
            konamiIndex += 1
            if (konamiIndex >= konamiSeq.length) {
                konamiIndex = 0
                iconDebugMode = !iconDebugMode
                screen.showOSD(iconDebugMode ? "ICON LAB ON" : "ICON LAB OFF")
            }
            return
        }
        konamiIndex = (token === konamiSeq[0]) ? 1 : 0
    }

    function beginSelectPress() {
        selectPressActive = true
        selectLongPressConsumed = false
        selectHoldTimer.restart()
    }

    function endSelectPress() {
        selectPressActive = false
        selectHoldTimer.stop()
    }

    function handleSelectShortPress() {
        if (selectLongPressConsumed) {
            selectLongPressConsumed = false
            return
        }
        gameLogic.handleSelect()
    }

    function handleBackAction() {
        if (gameLogic.state === 3 || gameLogic.state === 4 ||
            gameLogic.state === 5 || gameLogic.state === 6 ||
            gameLogic.state === 7 || gameLogic.state === 8) {
            gameLogic.quitToMenu()
        } else if (gameLogic.state === 1) {
            gameLogic.quit()
        }
    }

    Connections {
        target: gameLogic
        function onPaletteChanged() { 
            if (gameLogic.state === 0) return
            screen.showOSD(gameLogic.paletteName) 
        }
        function onShellColorChanged() { 
            if (gameLogic.state !== 0) {
                screen.triggerPowerCycle()
            }
        }
        function onAchievementEarned(title) { 
            screen.showOSD("UNLOCKED: " + title) 
        }
        function onEventPrompt(text) {
            screen.showOSD(">> " + text + " <<")
        }
    }

    Timer {
        id: selectHoldTimer
        interval: 700
        repeat: false
        onTriggered: {
            if (!window.selectPressActive || window.selectLongPressConsumed) return
            if (gameLogic.state === 1 && gameLogic.hasSave) {
                window.selectLongPressConsumed = true
                gameLogic.deleteSave()
                gameLogic.requestFeedback(8)
                screen.showOSD("SAVE CLEARED")
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
                shellColor: gameLogic.shellColor
                shellThemeName: gameLogic.shellName
                volume: gameLogic.volume

                onShellColorToggleRequested: {
                    gameLogic.requestFeedback(5)
                    gameLogic.nextShellColor()
                }

                onVolumeRequested: (value, withHaptic) => {
                    gameLogic.volume = value
                    if (withHaptic) {
                        gameLogic.requestFeedback(1)
                    }
                }
                
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
                    iconDebugMode: window.iconDebugMode
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
                    function onClicked() { handleAButton() } 
                }

                Connections { 
                    target: shell.bButton
                    function onClicked() {
                        handleBButton()
                    }
                }

                Connections { 
                    target: shell.selectButton
                    function onPressed() { 
                        shell.selectButton.isPressed = true
                        beginSelectPress()
                    }
                    function onReleased() { 
                        shell.selectButton.isPressed = false
                        endSelectPress()
                    }
                    function onClicked() {
                        handleSelectShortPress()
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
                handleAButton()
            }
            else if (event.key === Qt.Key_F6) {
                iconDebugMode = !iconDebugMode
                screen.showOSD(iconDebugMode ? "ICON LAB ON" : "ICON LAB OFF")
            }
            else if (event.key === Qt.Key_B || event.key === Qt.Key_X) {
                shell.bButton.isPressed = true
                handleBButton()
            }
            else if (event.key === Qt.Key_C || event.key === Qt.Key_Y) {
                gameLogic.nextShellColor()
            }
            else if (event.key === Qt.Key_Shift) {
                if (selectKeyDown) return
                selectKeyDown = true
                shell.selectButton.isPressed = true
                beginSelectPress()
            }
            else if (event.key === Qt.Key_M) gameLogic.toggleMusic()
            else if (event.key === Qt.Key_Back) {
                handleBackAction()
            }
            else if (event.key === Qt.Key_Escape) gameLogic.quit()
        }
        
        Keys.onReleased: (event) => {
            if (event.isAutoRepeat) return
            clearDpadVisuals()
            if (event.key === Qt.Key_S || event.key === Qt.Key_Return) shell.startButton.isPressed = false
            else if (event.key === Qt.Key_A || event.key === Qt.Key_Z) shell.aButton.isPressed = false
            else if (event.key === Qt.Key_B || event.key === Qt.Key_X) shell.bButton.isPressed = false
            else if (event.key === Qt.Key_Shift) {
                selectKeyDown = false
                shell.selectButton.isPressed = false
                endSelectPress()
                handleSelectShortPress()
            }
        }
    }
}
