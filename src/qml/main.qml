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
        handleDirection: uiInputController.handleDirection
        toggleIconLabMode: uiDebugController.toggleIconLabMode
        setStaticScene: uiDebugController.setStaticScene
        cycleStaticScene: uiDebugController.cycleStaticScene
        exitIconLab: uiDebugController.exitIconLab
        performPrimary: uiInputController.handlePrimaryAction
        performSecondary: uiInputController.handleSecondaryAction
        performStart: uiInputController.handleStartAction
        performSelectShort: uiInputController.handleSelectShortAction
        performBack: uiInputController.handleBackAction
        trackEasterToken: uiDebugController.handleEasterInput
        moveIconLabSelection: screen.iconLabMove
        setDirectionPressed: uiInputController.setDpadPressed
        clearDirectionVisuals: uiInputController.clearDirectionVisuals
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
        dispatchAction: uiInputController.dispatchAction
        clearDirectionVisuals: uiInputController.clearDirectionVisuals
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

    UiInputController {
        id: uiInputController
        commandController: commandControllerRef
        actionRouter: uiActionRouter
        inputPressController: inputPressController
        debugController: uiDebugController
        shellBridge: shellBridge
        audioSettingsViewModel: audioSettingsViewModel
        showVolumeOsd: screen.showVolumeOSD
        iconDebugMode: window.iconDebugMode
        actionMap: window.inputAction
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
                uiInputController.cancelSaveClearConfirm(false)
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
            uiInputController.handleShellBridgeDirection(dx, dy)
        }
        function onPrimaryTriggered() { uiInputController.dispatchAction(inputAction.Primary) }
        function onSecondaryTriggered() { uiInputController.dispatchAction(inputAction.Secondary) }
        function onSelectPressed() { inputPressController.onSelectPressed() }
        function onSelectReleased() { inputPressController.onSelectReleased() }
        function onSelectTriggered() { uiInputController.dispatchAction(inputAction.SelectShort) }
        function onStartPressed() { inputPressController.onStartPressed() }
        function onStartReleased() { inputPressController.onStartReleased() }
        function onStartTriggered() { uiInputController.dispatchAction(inputAction.Start) }
        function onShellColorToggleTriggered() { uiInputController.handleShellColorToggle() }
        function onVolumeRequested(value, withHaptic) {
            uiInputController.handleVolumeRequested(value, withHaptic)
        }
    }

    Item {
        focus: true
        Keys.onPressed: (event) => uiInputController.handleKeyPressed(event)
        
        Keys.onReleased: (event) => uiInputController.handleKeyReleased(event)
    }
}
