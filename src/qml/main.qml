import QtQuick
import QtQuick.Controls
import SnakeGB 1.0

Window {
    id: window
    width: 350
    height: 550
    visible: true
    title: qsTr("Snake GB Edition")
    color: "#1a1a1a"

    readonly property color p0: themeViewModel.palette[0]
    readonly property color p1: themeViewModel.palette[1]
    readonly property color p2: themeViewModel.palette[2]
    readonly property color p3: themeViewModel.palette[3]
    readonly property string gameFont: "Monospace"
    property var engineAdapterRef: engineAdapter

    property real elapsed: 0.0
    property bool iconDebugMode: false
    property string staticDebugScene: ""
    property var staticDebugOptions: ({})
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

    function setDpadPressed(dx, dy) {
        shellBridge.setDirectionPressed(dx, dy)
    }

    function handleDirection(dx, dy) {
        if (dy < 0) {
            engineAdapter.dispatchUiAction(inputAction.NavUp)
        } else if (dy > 0) {
            engineAdapter.dispatchUiAction(inputAction.NavDown)
        } else if (dx < 0) {
            engineAdapter.dispatchUiAction(inputAction.NavLeft)
        } else if (dx > 0) {
            engineAdapter.dispatchUiAction(inputAction.NavRight)
        }
        setDpadPressed(dx, dy)
    }

    function setIconDebugMode(enabled) {
        iconDebugMode = enabled
    }

    function setStaticDebugSceneValue(sceneName) {
        staticDebugScene = sceneName
    }

    function setStaticDebugOptionsValue(options) {
        staticDebugOptions = options ? options : ({})
    }

    function resetKonamiProgress() {
        konamiIndex = 0
    }

    function dispatchRuntimeAction(action) {
        engineAdapter.dispatchUiAction(action)
    }

    UiActionRouter {
        id: uiActionRouter
        engineAdapter: engineAdapterRef
        actionMap: window.inputAction
        iconDebugMode: window.iconDebugMode
        staticDebugScene: window.staticDebugScene
        saveClearConfirmPending: inputPressController.saveClearConfirmPending
        handleDirection: window.handleDirection
        toggleIconLabMode: debugTokenRouter.toggleIconLabMode
        setStaticScene: debugTokenRouter.setStaticScene
        cycleStaticScene: debugTokenRouter.cycleStaticScene
        exitIconLab: debugTokenRouter.exitIconLab
        performPrimary: window.handleAButton
        performSecondary: window.handleBButton
        performStart: window.handleStartButton
        performSelectShort: window.handleSelectShortPress
        performBack: window.handleBackAction
        trackEasterToken: window.handleEasterInput
        moveIconLabSelection: screen.iconLabMove
        setDirectionPressed: window.setDpadPressed
        clearDirectionVisuals: window.clearDpadVisuals
    }

    DebugTokenRouter {
        id: debugTokenRouter
        engineAdapter: engineAdapterRef
        actionMap: window.inputAction
        iconDebugMode: window.iconDebugMode
        staticDebugScene: window.staticDebugScene
        staticDebugOptions: window.staticDebugOptions
        showOsd: screen.showOSD
        dispatchAction: window.dispatchAction
        clearDirectionVisuals: window.clearDpadVisuals
        setIconDebugMode: window.setIconDebugMode
        setStaticDebugSceneValue: window.setStaticDebugSceneValue
        setStaticDebugOptionsValue: window.setStaticDebugOptionsValue
        resetKonamiProgress: window.resetKonamiProgress
    }

    InputPressController {
        id: inputPressController
        currentState: engineAdapter.state
        hasSave: engineAdapter.hasSave
        iconDebugMode: window.iconDebugMode
        actionMap: window.inputAction
        showOsd: screen.showOSD
        dispatchUiAction: window.dispatchRuntimeAction
    }

    function dispatchAction(action) {
        inputPressController.beforeDispatch(action)
        uiActionRouter.route(action)
    }

    function dispatchInjectedToken(rawToken) {
        const token = String(rawToken).trim().toUpperCase()
        if (debugTokenRouter.routeDebugToken(token)) {
            return
        }
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
        if (token === "PALETTE" || token === "NEXT_PALETTE") {
            engineAdapter.dispatchUiAction("next_palette")
            return
        }
        if (token === "MUSIC") {
            dispatchAction(inputAction.ToggleMusic)
            return
        }
        if (token === "STATIC_BOOT") {
            debugTokenRouter.setStaticScene("boot")
            return
        }
        if (token === "STATIC_GAME") {
            debugTokenRouter.setStaticScene("game")
            return
        }
        if (token === "STATIC_REPLAY") {
            debugTokenRouter.setStaticScene("replay")
            return
        }
        if (token === "STATIC_OFF") {
            debugTokenRouter.setStaticScene("")
            return
        }
        screen.showOSD(`UNKNOWN INPUT: ${token}`)
    }

    function clearDpadVisuals() {
        shellBridge.clearDirectionPressed()
    }

    function handleBButton() {
        if (handleEasterInput("B")) {
            return
        }
        engineAdapter.dispatchUiAction(inputAction.Secondary)
    }

    function handleAButton() {
        if (inputPressController.confirmSaveClear()) {
            return
        }
        if (handleEasterInput("A")) {
            return
        }
        engineAdapter.dispatchUiAction(inputAction.Primary)
    }

    function exitIconLabToMenu() {
        iconDebugMode = false
        konamiIndex = 0
        clearDpadVisuals()
        engineAdapter.dispatchUiAction("state_start_menu")
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
                    engineAdapter.dispatchUiAction("state_start_menu")
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
        // Keep Konami isolated from normal navigation:
        // only allow entering sequence from paused overlay (or while already in icon lab).
        const trackEaster = iconDebugMode || engineAdapter.state === AppState.Paused
        if (!trackEaster) {
            return false
        }

        // Quick exit in icon lab: B always returns to main menu.
        if (iconDebugMode && token === "B" && konamiIndex === 0) {
            exitIconLabToMenu()
            return true
        }

        const beforeIndex = konamiIndex
        const status = feedEasterInput(token)
        if (iconDebugMode) {
            if (status === "toggle") {
                engineAdapter.dispatchUiAction("state_start_menu")
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

    function handleSelectShortPress() {
        inputPressController.triggerSelectShort()
    }

    function handleStartButton() {
        if (iconDebugMode) {
            return
        }
        engineAdapter.dispatchUiAction(inputAction.Start)
    }

    function cancelSaveClearConfirm(showToast) {
        inputPressController.cancelSaveClearConfirm(showToast)
    }

    function handleBackAction() {
        if (iconDebugMode) {
            exitIconLabToMenu()
            return
        }
        engineAdapter.dispatchUiAction(inputAction.Back)
    }

    Connections {
        target: engineAdapter
        function onPaletteChanged() { 
            if (engineAdapter.state === AppState.Splash) return
            screen.showOSD(themeViewModel.paletteName)
        }
        function onShellColorChanged() { 
            if (engineAdapter.state !== AppState.Splash) {
                screen.triggerPowerCycle()
            }
        }
        function onStateChanged() {
            if (engineAdapter.state !== AppState.StartMenu) {
                cancelSaveClearConfirm(false)
            }
        }
        function onAchievementEarned(title) { 
            screen.showOSD(`UNLOCKED: ${title}`) 
        }
        function onEventPrompt(text) {
            screen.showOSD(`>> ${text} <<`)
        }
    }

    Connections {
        target: inputInjector
        function onActionInjected(action) {
            dispatchInjectedToken(action)
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

        ShellBridge {
            id: shellBridge
        }

        Item {
            id: scaledWrapper
            width: 350
            height: 550
            anchors.centerIn: parent
            scale: Math.min(window.width / 350, window.height / 550)
            
            Shell {
                id: shell
                anchors.fill: parent
                bridge: shellBridge
                shellColor: themeViewModel.shellColor
                shellThemeName: themeViewModel.shellName
                volume: engineAdapter.volume
                
                ScreenView {
                    id: screen
                    anchors.fill: parent
                    engineAdapter: engineAdapterRef
                    p0: window.p0
                    p1: window.p1
                    p2: window.p2
                    p3: window.p3
                    gameFont: window.gameFont
                    elapsed: window.elapsed
                    iconDebugMode: window.iconDebugMode
                    staticDebugScene: window.staticDebugScene
                    staticDebugOptions: window.staticDebugOptions
                }
            }
        }
    }

    Connections {
        target: shellBridge
        function onDirectionTriggered(dx, dy) {
            if (dy < 0) dispatchAction(inputAction.NavUp)
            else if (dy > 0) dispatchAction(inputAction.NavDown)
            else if (dx < 0) dispatchAction(inputAction.NavLeft)
            else if (dx > 0) dispatchAction(inputAction.NavRight)
        }
        function onPrimaryTriggered() { dispatchAction(inputAction.Primary) }
        function onSecondaryTriggered() { dispatchAction(inputAction.Secondary) }
        function onSelectPressed() { inputPressController.onSelectPressed() }
        function onSelectReleased() { inputPressController.onSelectReleased() }
        function onSelectTriggered() { dispatchAction(inputAction.SelectShort) }
        function onStartPressed() { inputPressController.onStartPressed() }
        function onStartReleased() { inputPressController.onStartReleased() }
        function onStartTriggered() { dispatchAction(inputAction.Start) }
        function onShellColorToggleTriggered() {
            engineAdapter.dispatchUiAction("feedback_ui")
            engineAdapter.dispatchUiAction("toggle_shell_color")
        }
        function onVolumeRequested(value, withHaptic) {
            engineAdapter.volume = value
            if (withHaptic) {
                engineAdapter.dispatchUiAction("feedback_light")
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
                shellBridge.startHeld = true
                inputPressController.onStartPressed()
                dispatchAction(inputAction.Start)
            }
            else if (event.key === Qt.Key_A || event.key === Qt.Key_Z) {
                shellBridge.primaryPressed = true
                dispatchAction(inputAction.Primary)
            }
            else if (event.key === Qt.Key_F6) {
                dispatchAction(inputAction.ToggleIconLab)
            }
            else if (event.key === Qt.Key_F7) {
                debugTokenRouter.cycleStaticScene(1)
            }
            else if (event.key === Qt.Key_B || event.key === Qt.Key_X) {
                shellBridge.secondaryPressed = true
                dispatchAction(inputAction.Secondary)
            }
            else if (event.key === Qt.Key_C || event.key === Qt.Key_Y) {
                dispatchAction(inputAction.ToggleShellColor)
            }
            else if (event.key === Qt.Key_Shift) {
                if (inputPressController.selectKeyDown) return
                inputPressController.selectKeyDown = true
                shellBridge.selectHeld = true
                inputPressController.onSelectPressed()
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
            if (event.key === Qt.Key_S || event.key === Qt.Key_Return) shellBridge.startHeld = false
            if (event.key === Qt.Key_S || event.key === Qt.Key_Return) inputPressController.onStartReleased()
            else if (event.key === Qt.Key_A || event.key === Qt.Key_Z) shellBridge.primaryPressed = false
            else if (event.key === Qt.Key_B || event.key === Qt.Key_X) shellBridge.secondaryPressed = false
            else if (event.key === Qt.Key_Shift) {
                inputPressController.selectKeyDown = false
                shellBridge.selectHeld = false
                inputPressController.onSelectReleased()
                dispatchAction(inputAction.SelectShort)
            }
        }
    }
}
