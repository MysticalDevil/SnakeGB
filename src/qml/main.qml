import QtQuick
import QtQuick.Controls
import SnakeGB 1.0

Window {
    id: window
    readonly property int shellBaseWidth: 350
    readonly property int shellBaseHeight: 570
    readonly property int screenBaseWidth: 240
    readonly property int screenBaseHeight: 216
    readonly property real screenOnlyScale: 3.0
    readonly property string uiMode: typeof appUiMode === "string" ? appUiMode : "full"
    readonly property bool fullUiMode: uiMode === "full"
    readonly property bool screenOnlyUiMode: uiMode === "screen"
    readonly property bool shellOnlyUiMode: uiMode === "shell"

    width: screenOnlyUiMode ? Math.round(screenBaseWidth * screenOnlyScale) : shellBaseWidth
    height: screenOnlyUiMode ? Math.round(screenBaseHeight * screenOnlyScale) : shellBaseHeight
    visible: true
    title: qsTr("Snake GB Edition")
    color: "#1a1a1a"

    readonly property color p0: themeViewModel.palette[0]
    readonly property color p1: themeViewModel.palette[1]
    readonly property color p2: themeViewModel.palette[2]
    readonly property color p3: themeViewModel.palette[3]
    readonly property string gameFont: "Monospace"
    readonly property var themeViewModelRef: themeViewModel
    property real elapsed: 0.0
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

    UiRuntimeState {
        id: uiRuntimeState
    }

    UiActionRouter {
        id: uiActionRouter
        commandController: uiCommandController
        inputController: uiInputController
        debugController: uiDebugController
        screen: window.screenRef
        currentState: window.currentState
        actionMap: window.inputAction
        iconDebugMode: uiRuntimeState.iconDebugMode
        staticDebugScene: uiRuntimeState.staticDebugScene
    }

    UiDebugController {
        id: uiDebugController
        commandController: uiCommandController
        inputInjector: inputInjector
        actionMap: window.inputAction
        currentState: window.currentState
        iconDebugMode: uiRuntimeState.iconDebugMode
        staticDebugScene: uiRuntimeState.staticDebugScene
        staticDebugOptions: uiRuntimeState.staticDebugOptions
        screen: window.screenRef
        inputController: uiInputController
        clearDirectionVisuals: uiInputController.clearDirectionVisuals
        stateOwner: uiRuntimeState
    }

    InputPressController {
        id: inputPressController
        currentState: window.currentState
        hasSave: sessionStatusViewModel.hasSave
        iconDebugMode: uiRuntimeState.iconDebugMode
        actionMap: window.inputAction
        commandController: uiCommandController
        screen: window.screenRef
    }

    UiInputController {
        id: uiInputController
        commandController: uiCommandController
        actionRouter: uiActionRouter
        inputPressController: inputPressController
        debugController: uiDebugController
        shellBridge: shellBridge
        sessionRenderViewModel: sessionRenderViewModel
        audioSettingsViewModel: audioSettingsViewModel
        screen: window.screenRef
        iconDebugMode: uiRuntimeState.iconDebugMode
        actionMap: window.inputAction
    }

    readonly property var screenRef: compositionHost.screenItem

    UiCompositionHost {
        id: compositionHost
        anchors.fill: parent
        fullUiMode: window.fullUiMode
        screenOnlyUiMode: window.screenOnlyUiMode
        shellOnlyUiMode: window.shellOnlyUiMode
        shellBaseWidth: window.shellBaseWidth
        shellBaseHeight: window.shellBaseHeight
        screenBaseWidth: window.screenBaseWidth
        screenBaseHeight: window.screenBaseHeight
        commandController: uiCommandController
        inputController: uiInputController
        themeViewModel: window.themeViewModelRef
        audioSettingsViewModel: audioSettingsViewModel
        uiRuntimeState: uiRuntimeState
        p0: window.p0
        p1: window.p1
        p2: window.p2
        p3: window.p3
        gameFont: window.gameFont
        elapsed: window.elapsed
    }

    readonly property var shellBridge: compositionHost.bridge
}
