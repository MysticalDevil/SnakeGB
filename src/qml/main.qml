import QtQuick
import QtQuick.Controls
import SnakeGB 1.0

Window {
    id: window
    readonly property int shellBaseWidth: 350
    readonly property int shellBaseHeight: 570

    width: shellBaseWidth
    height: shellBaseHeight
    visible: true
    title: qsTr("Snake GB Edition")
    color: "#1a1a1a"

    readonly property color p0: themeViewModel.palette[0]
    readonly property color p1: themeViewModel.palette[1]
    readonly property color p2: themeViewModel.palette[2]
    readonly property color p3: themeViewModel.palette[3]
    readonly property string gameFont: "Monospace"
    property var commandControllerRef: uiCommandController

    property real elapsed: 0.0
    property bool iconDebugMode: false
    property string staticDebugScene: ""
    property var staticDebugOptions: ({})
    readonly property int currentState: sessionRenderViewModel.state
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
            uiCommandController.dispatch(inputAction.NavUp)
        } else if (dy > 0) {
            uiCommandController.dispatch(inputAction.NavDown)
        } else if (dx < 0) {
            uiCommandController.dispatch(inputAction.NavLeft)
        } else if (dx > 0) {
            uiCommandController.dispatch(inputAction.NavRight)
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

    function dispatchRuntimeAction(action) {
        uiCommandController.dispatch(action)
    }

    UiActionRouter {
        id: uiActionRouter
        commandController: commandControllerRef
        currentState: window.currentState
        actionMap: window.inputAction
        iconDebugMode: window.iconDebugMode
        staticDebugScene: window.staticDebugScene
        saveClearConfirmPending: inputPressController.saveClearConfirmPending
        handleDirection: window.handleDirection
        toggleIconLabMode: uiDebugController.toggleIconLabMode
        setStaticScene: uiDebugController.setStaticScene
        cycleStaticScene: uiDebugController.cycleStaticScene
        exitIconLab: uiDebugController.exitIconLab
        performPrimary: window.handleAButton
        performSecondary: window.handleBButton
        performStart: window.handleStartButton
        performSelectShort: window.handleSelectShortPress
        performBack: window.handleBackAction
        trackEasterToken: uiDebugController.handleEasterInput
        moveIconLabSelection: screen.iconLabMove
        setDirectionPressed: window.setDpadPressed
        clearDirectionVisuals: window.clearDpadVisuals
    }

    UiDebugController {
        id: uiDebugController
        commandController: commandControllerRef
        actionMap: window.inputAction
        currentState: window.currentState
        iconDebugMode: window.iconDebugMode
        staticDebugScene: window.staticDebugScene
        staticDebugOptions: window.staticDebugOptions
        showOsd: screen.showOSD
        dispatchAction: window.dispatchAction
        clearDirectionVisuals: window.clearDpadVisuals
        setIconDebugMode: window.setIconDebugMode
        setStaticDebugSceneValue: window.setStaticDebugSceneValue
        setStaticDebugOptionsValue: window.setStaticDebugOptionsValue
    }

    InputPressController {
        id: inputPressController
        currentState: window.currentState
        hasSave: sessionStatusViewModel.hasSave
        iconDebugMode: window.iconDebugMode
        actionMap: window.inputAction
        showOsd: screen.showOSD
        dispatchUiAction: window.dispatchRuntimeAction
    }

    function dispatchAction(action) {
        inputPressController.beforeDispatch(action)
        uiActionRouter.route(action)
    }

    function clearDpadVisuals() {
        shellBridge.clearDirectionPressed()
    }

    function handleBButton() {
        if (uiDebugController.handleEasterInput("B")) {
            return
        }
        uiCommandController.dispatch(inputAction.Secondary)
    }

    function handleAButton() {
        if (inputPressController.confirmSaveClear()) {
            return
        }
        if (uiDebugController.handleEasterInput("A")) {
            return
        }
        uiCommandController.dispatch(inputAction.Primary)
    }

    function handleSelectShortPress() {
        inputPressController.triggerSelectShort()
    }

    function handleStartButton() {
        if (iconDebugMode) {
            return
        }
        uiCommandController.dispatch(inputAction.Start)
    }

    function cancelSaveClearConfirm(showToast) {
        inputPressController.cancelSaveClearConfirm(showToast)
    }

    function handleBackAction() {
        if (iconDebugMode) {
            uiDebugController.exitIconLab()
            return
        }
        uiCommandController.dispatch(inputAction.Back)
    }

    Connections {
        target: uiCommandController
        function onPaletteChanged() { 
            if (window.currentState === AppState.Splash) return
            screen.showOSD(themeViewModel.paletteName)
        }
        function onShellChanged() { 
            if (window.currentState !== AppState.Splash) {
                screen.triggerPowerCycle()
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
        target: sessionRenderViewModel
        function onStateChanged() {
            if (window.currentState !== AppState.StartMenu) {
                cancelSaveClearConfirm(false)
            }
        }
    }

    Connections {
        target: inputInjector
        function onActionInjected(action) {
            uiDebugController.routeInjectedToken(action)
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
            width: window.shellBaseWidth
            height: window.shellBaseHeight
            anchors.centerIn: parent
            scale: Math.min(window.width / window.shellBaseWidth,
                            window.height / window.shellBaseHeight)
            
            Shell {
                id: shell
                anchors.fill: parent
                bridge: shellBridge
                commandController: commandControllerRef
                shellColor: themeViewModel.shellColor
                shellThemeName: themeViewModel.shellName
                volume: audioSettingsViewModel.volume
                
                ScreenView {
                    id: screen
                    anchors.fill: parent
                    commandController: commandControllerRef
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
            uiCommandController.dispatch("feedback_ui")
            uiCommandController.dispatch("toggle_shell_color")
        }
        function onVolumeRequested(value, withHaptic) {
            audioSettingsViewModel.volume = value
            screen.showVolumeOSD(value)
            if (withHaptic) {
                uiCommandController.dispatch("feedback_light")
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
                uiDebugController.cycleStaticScene(1)
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
            if (event.key === Qt.Key_S || event.key === Qt.Key_Return) {
                inputPressController.onStartReleased()
            }
            else if (event.key === Qt.Key_A || event.key === Qt.Key_Z) {
                shellBridge.primaryPressed = false
            }
            else if (event.key === Qt.Key_B || event.key === Qt.Key_X) {
                shellBridge.secondaryPressed = false
            }
            else if (event.key === Qt.Key_Shift) {
                inputPressController.selectKeyDown = false
                shellBridge.selectHeld = false
                inputPressController.onSelectReleased()
                dispatchAction(inputAction.SelectShort)
            }
        }
    }
}
