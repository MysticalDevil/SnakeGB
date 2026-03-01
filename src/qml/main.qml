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

    UiActionRouter {
        id: uiActionRouter
        commandController: uiCommandController
        inputController: uiInputController
        debugController: uiDebugController
        currentState: window.currentState
        actionMap: window.inputAction
        iconDebugMode: window.iconDebugMode
        staticDebugScene: window.staticDebugScene
        moveIconLabSelection: screen.iconLabMove
    }

    UiDebugController {
        id: uiDebugController
        commandController: uiCommandController
        inputInjector: inputInjector
        actionMap: window.inputAction
        currentState: window.currentState
        iconDebugMode: window.iconDebugMode
        staticDebugScene: window.staticDebugScene
        staticDebugOptions: window.staticDebugOptions
        showOsd: screen.showOSD
        inputController: uiInputController
        clearDirectionVisuals: uiInputController.clearDirectionVisuals
        stateOwner: window
    }

    InputPressController {
        id: inputPressController
        currentState: window.currentState
        hasSave: sessionStatusViewModel.hasSave
        iconDebugMode: window.iconDebugMode
        actionMap: window.inputAction
        commandController: uiCommandController
        showOsd: screen.showOSD
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
        showVolumeOsd: screen.showVolumeOSD
        iconDebugMode: window.iconDebugMode
        actionMap: window.inputAction
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
                commandController: uiCommandController
                shellColor: themeViewModel.shellColor
                shellThemeName: themeViewModel.shellName
                volume: audioSettingsViewModel.volume
                
                ScreenView {
                    id: screen
                    anchors.fill: parent
                    commandController: uiCommandController
                    themeViewModel: themeViewModel
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

    Item {
        focus: true
        Keys.onPressed: (event) => uiInputController.handleKeyPressed(event)
        
        Keys.onReleased: (event) => uiInputController.handleKeyReleased(event)
    }
}
