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
    readonly property var gameState: ({
        Splash: 0,
        StartMenu: 1,
        Playing: 2,
        Paused: 3,
        GameOver: 4,
        Replaying: 5,
        ChoiceSelection: 6,
        Library: 7,
        MedalRoom: 8
    })
    readonly property var inputAction: ({
        NavUp: "nav_up",
        NavDown: "nav_down",
        NavLeft: "nav_left",
        NavRight: "nav_right",
        Primary: "primary",
        Secondary: "secondary",
        Start: "start",
        SelectShort: "select_short",
        Back: "back",
        Escape: "escape",
        ToggleIconLab: "toggle_icon_lab",
        ToggleShellColor: "toggle_shell_color",
        ToggleMusic: "toggle_music"
    })
    property var konamiSeq: ["U","U","D","D","L","R","L","R","B","A"]
    property int konamiIndex: 0
    NumberAnimation on elapsed { 
        from: 0
        to: 1000
        duration: 1000000
        loops: Animation.Infinite 
    }

    function handleDirection(dx, dy) {
        var token = ""
        if (dy < 0) token = "U"
        else if (dy > 0) token = "D"
        else if (dx < 0) token = "L"
        else if (dx > 0) token = "R"

        if (token !== "") {
            var consumed = handleEasterInput(token)
            if (iconDebugMode) {
                screen.iconLabMove(dx, dy)
                if (dy < 0) {
                    shell.dpad.upPressed = true
                } else if (dy > 0) {
                    shell.dpad.downPressed = true
                } else if (dx < 0) {
                    shell.dpad.leftPressed = true
                } else if (dx > 0) {
                    shell.dpad.rightPressed = true
                }
                return
            }
            if (consumed) {
                clearDpadVisuals()
                return
            }
        }

        gameLogic.move(dx, dy)
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

    function toggleIconLab() {
        iconDebugMode = !iconDebugMode
        konamiIndex = 0
        screen.showOSD(iconDebugMode ? "ICON LAB ON" : "ICON LAB OFF")
        if (!iconDebugMode) {
            gameLogic.requestStateChange(gameState.StartMenu)
        }
    }

    function dispatchAction(action) {
        if (action === inputAction.NavUp) {
            handleDirection(0, -1)
            return
        }
        if (action === inputAction.NavDown) {
            handleDirection(0, 1)
            return
        }
        if (action === inputAction.NavLeft) {
            handleDirection(-1, 0)
            return
        }
        if (action === inputAction.NavRight) {
            handleDirection(1, 0)
            return
        }
        if (action === inputAction.Primary) {
            handleAButton()
            return
        }
        if (action === inputAction.Secondary) {
            handleBButton()
            return
        }
        if (action === inputAction.Start) {
            handleStartButton()
            return
        }
        if (action === inputAction.SelectShort) {
            handleSelectShortPress()
            return
        }
        if (action === inputAction.Back) {
            handleBackAction()
            return
        }
        if (action === inputAction.Escape) {
            if (iconDebugMode) {
                exitIconLabToMenu()
            } else {
                gameLogic.quit()
            }
            return
        }
        if (action === inputAction.ToggleIconLab) {
            toggleIconLab()
            return
        }
        if (action === inputAction.ToggleShellColor) {
            gameLogic.nextShellColor()
            return
        }
        if (action === inputAction.ToggleMusic) {
            gameLogic.toggleMusic()
        }
    }

    function dispatchInjectedToken(rawToken) {
        var token = String(rawToken).trim().toUpperCase()
        if (token === "UP" || token === "U") {
            dispatchAction(inputAction.NavUp)
            return
        }
        if (token === "DOWN" || token === "D") {
            dispatchAction(inputAction.NavDown)
            return
        }
        if (token === "LEFT" || token === "L") {
            dispatchAction(inputAction.NavLeft)
            return
        }
        if (token === "RIGHT" || token === "R") {
            dispatchAction(inputAction.NavRight)
            return
        }
        if (token === "A" || token === "PRIMARY" || token === "OK") {
            dispatchAction(inputAction.Primary)
            return
        }
        if (token === "B" || token === "SECONDARY") {
            dispatchAction(inputAction.Secondary)
            return
        }
        if (token === "START") {
            dispatchAction(inputAction.Start)
            return
        }
        if (token === "SELECT") {
            dispatchAction(inputAction.SelectShort)
            return
        }
        if (token === "BACK") {
            dispatchAction(inputAction.Back)
            return
        }
        if (token === "ESC" || token === "ESCAPE") {
            dispatchAction(inputAction.Escape)
            return
        }
        if (token === "F6" || token === "ICON") {
            dispatchAction(inputAction.ToggleIconLab)
            return
        }
        if (token === "COLOR" || token === "SHELL") {
            dispatchAction(inputAction.ToggleShellColor)
            return
        }
        if (token === "MUSIC") {
            dispatchAction(inputAction.ToggleMusic)
            return
        }
        screen.showOSD("UNKNOWN INPUT: " + token)
    }

    function clearDpadVisuals() {
        shell.dpad.upPressed = false
        shell.dpad.downPressed = false
        shell.dpad.leftPressed = false
        shell.dpad.rightPressed = false
    }

    function handleBButton() {
        if (handleEasterInput("B")) {
            return
        }
        gameLogic.handleBAction()
    }

    function handleAButton() {
        if (handleEasterInput("A")) {
            return
        }
        gameLogic.handleStart()
    }

    function exitIconLabToMenu() {
        iconDebugMode = false
        konamiIndex = 0
        gameLogic.requestStateChange(gameState.StartMenu)
        screen.showOSD("ICON LAB OFF")
    }

    function feedEasterInput(token) {
        if (token === konamiSeq[konamiIndex]) {
            konamiIndex += 1
            konamiResetTimer.restart()
            if (konamiIndex >= konamiSeq.length) {
                konamiIndex = 0
                konamiResetTimer.stop()
                iconDebugMode = !iconDebugMode
                screen.showOSD(iconDebugMode ? "ICON LAB ON" : "ICON LAB OFF")
                if (!iconDebugMode) {
                    gameLogic.requestStateChange(gameState.StartMenu)
                }
                return "toggle"
            }
            return "progress"
        }
        konamiIndex = (token === konamiSeq[0]) ? 1 : 0
        if (konamiIndex > 0) {
            konamiResetTimer.restart()
        } else {
            konamiResetTimer.stop()
        }
        return "mismatch"
    }

    function handleEasterInput(token) {
        var trackEaster = iconDebugMode || gameLogic.state !== gameState.Splash
        if (!trackEaster) {
            return false
        }

        // Quick exit in icon lab: B always returns to main menu.
        if (iconDebugMode && token === "B" && konamiIndex === 0) {
            exitIconLabToMenu()
            return true
        }

        var beforeIndex = konamiIndex
        var status = feedEasterInput(token)
        if (iconDebugMode) {
            if (status === "toggle") {
                gameLogic.requestStateChange(gameState.StartMenu)
            }
            return true
        }
        if (status === "toggle") {
            return true
        }
        // Let the first token pass through for normal controls; consume the rest
        // of a potential Konami sequence to avoid gameplay/menu side effects.
        return beforeIndex > 0
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
        if (iconDebugMode) {
            return
        }
        if (selectLongPressConsumed) {
            selectLongPressConsumed = false
            return
        }
        gameLogic.handleSelect()
    }

    function handleStartButton() {
        if (iconDebugMode) {
            return
        }
        gameLogic.handleStart()
    }

    function handleBackAction() {
        if (iconDebugMode) {
            exitIconLabToMenu()
            return
        }
        if (gameLogic.state === gameState.Paused || gameLogic.state === gameState.GameOver ||
            gameLogic.state === gameState.Replaying || gameLogic.state === gameState.ChoiceSelection ||
            gameLogic.state === gameState.Library || gameLogic.state === gameState.MedalRoom) {
            gameLogic.quitToMenu()
        } else if (gameLogic.state === gameState.StartMenu) {
            gameLogic.quit()
        }
    }

    Connections {
        target: gameLogic
        function onPaletteChanged() { 
            if (gameLogic.state === gameState.Splash) return
            screen.showOSD(gameLogic.paletteName) 
        }
        function onShellColorChanged() { 
            if (gameLogic.state !== gameState.Splash) {
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

    Connections {
        target: inputInjector
        function onActionInjected(action) {
            dispatchInjectedToken(action)
        }
    }

    Timer {
        id: selectHoldTimer
        interval: 700
        repeat: false
        onTriggered: {
            if (!window.selectPressActive || window.selectLongPressConsumed) return
            if (gameLogic.state === gameState.StartMenu && gameLogic.hasSave) {
                window.selectLongPressConsumed = true
                gameLogic.deleteSave()
                gameLogic.requestFeedback(8)
                screen.showOSD("SAVE CLEARED")
            }
        }
    }

    Timer {
        id: konamiResetTimer
        interval: 1400
        repeat: false
        onTriggered: {
            konamiIndex = 0
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
                    function onUpClicked() { dispatchAction(inputAction.NavUp) }
                    function onDownClicked() { dispatchAction(inputAction.NavDown) }
                    function onLeftClicked() { dispatchAction(inputAction.NavLeft) }
                    function onRightClicked() { dispatchAction(inputAction.NavRight) }
                }

                Connections { 
                    target: shell.aButton
                    function onClicked() { dispatchAction(inputAction.Primary) } 
                }

                Connections { 
                    target: shell.bButton
                    function onClicked() {
                        dispatchAction(inputAction.Secondary)
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
                        dispatchAction(inputAction.SelectShort)
                    } 
                }

                Connections { 
                    target: shell.startButton
                    function onClicked() { dispatchAction(inputAction.Start) } 
                }
            }
        }
    }

    Item {
        focus: true
        Keys.onPressed: (event) => {
            if (event.isAutoRepeat) return
            if (event.key === Qt.Key_Up) dispatchAction(inputAction.NavUp)
            else if (event.key === Qt.Key_Down) dispatchAction(inputAction.NavDown)
            else if (event.key === Qt.Key_Left) dispatchAction(inputAction.NavLeft)
            else if (event.key === Qt.Key_Right) dispatchAction(inputAction.NavRight)
            else if (event.key === Qt.Key_S || event.key === Qt.Key_Return) {
                shell.startButton.isPressed = true
                dispatchAction(inputAction.Start)
            }
            else if (event.key === Qt.Key_A || event.key === Qt.Key_Z) {
                shell.aButton.isPressed = true
                dispatchAction(inputAction.Primary)
            }
            else if (event.key === Qt.Key_F6) {
                dispatchAction(inputAction.ToggleIconLab)
            }
            else if (event.key === Qt.Key_B || event.key === Qt.Key_X) {
                shell.bButton.isPressed = true
                dispatchAction(inputAction.Secondary)
            }
            else if (event.key === Qt.Key_C || event.key === Qt.Key_Y) {
                dispatchAction(inputAction.ToggleShellColor)
            }
            else if (event.key === Qt.Key_Shift) {
                if (selectKeyDown) return
                selectKeyDown = true
                shell.selectButton.isPressed = true
                beginSelectPress()
            }
            else if (event.key === Qt.Key_M) dispatchAction(inputAction.ToggleMusic)
            else if (event.key === Qt.Key_Back) {
                dispatchAction(inputAction.Back)
            }
            else if (event.key === Qt.Key_Escape) {
                dispatchAction(inputAction.Escape)
            }
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
                dispatchAction(inputAction.SelectShort)
            }
        }
    }
}
