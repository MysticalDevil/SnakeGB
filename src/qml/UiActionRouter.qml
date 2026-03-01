import QtQuick
import SnakeGB 1.0

QtObject {
    id: router

    property var commandController
    property int currentState: AppState.Splash
    property var actionMap: ({})
    property bool iconDebugMode: false
    property string staticDebugScene: ""
    property bool saveClearConfirmPending: false
    property var handleDirection
    property var toggleIconLabMode
    property var setStaticScene
    property var cycleStaticScene
    property var exitIconLab
    property var performPrimary
    property var performSecondary
    property var performStart
    property var performSelectShort
    property var performBack
    property var trackEasterToken
    property var moveIconLabSelection
    property var setDirectionPressed
    property var clearDirectionVisuals

    readonly property string modeOverlay: "overlay"
    readonly property string modePage: "page"
    readonly property string modeGame: "game"
    readonly property string modeShell: "shell"

    function route(action) {
        if (routeGlobal(action)) {
            return true
        }
        if (router.staticDebugScene !== "") {
            return routeStaticScene(action)
        }
        if (router.iconDebugMode) {
            return routeIconDebug(action)
        }
        return routeMode(router.modeForState(router.currentState), action)
    }

    function modeForState(state) {
        if (state === AppState.Paused || state === AppState.GameOver ||
                state === AppState.Replaying || state === AppState.ChoiceSelection) {
            return router.modeOverlay
        }
        if (state === AppState.Library || state === AppState.MedalRoom) {
            return router.modePage
        }
        if (state === AppState.Playing) {
            return router.modeGame
        }
        return router.modeShell
    }

    function perform(callback) {
        if (callback) {
            callback()
        }
        return true
    }

    function dispatch(action) {
        router.commandController.dispatch(action)
        return true
    }

    function dispatchBack() {
        return dispatch(router.actionMap.Back)
    }

    function routeDirection(action) {
        let dx = 0
        let dy = 0
        let token = ""
        if (action === router.actionMap.NavUp) {
            dy = -1
            token = "U"
        } else if (action === router.actionMap.NavDown) {
            dy = 1
            token = "D"
        } else if (action === router.actionMap.NavLeft) {
            dx = -1
            token = "L"
        } else if (action === router.actionMap.NavRight) {
            dx = 1
            token = "R"
        } else {
            return false
        }

        if (router.trackEasterToken && router.trackEasterToken(token)) {
            if (router.clearDirectionVisuals) {
                router.clearDirectionVisuals()
            }
            return true
        }
        if (router.handleDirection) {
            router.handleDirection(dx, dy)
        }
        return true
    }

    function routeIconDirection(action) {
        let dx = 0
        let dy = 0
        let token = ""
        if (action === router.actionMap.NavUp) {
            dy = -1
            token = "U"
        } else if (action === router.actionMap.NavDown) {
            dy = 1
            token = "D"
        } else if (action === router.actionMap.NavLeft) {
            dx = -1
            token = "L"
        } else if (action === router.actionMap.NavRight) {
            dx = 1
            token = "R"
        } else {
            return false
        }

        if (router.trackEasterToken) {
            router.trackEasterToken(token)
        }
        if (router.moveIconLabSelection) {
            router.moveIconLabSelection(dx, dy)
        }
        if (router.setDirectionPressed) {
            router.setDirectionPressed(dx, dy)
        }
        return true
    }

    function routeGlobal(action) {
        if (action === router.actionMap.ToggleIconLab) {
            return perform(router.toggleIconLabMode)
        }
        if (action === router.actionMap.ToggleShellColor) {
            return dispatch("toggle_shell_color")
        }
        if (action === router.actionMap.ToggleMusic) {
            return dispatch("toggle_music")
        }
        if (action === router.actionMap.Escape) {
            if (router.iconDebugMode) {
                return perform(router.exitIconLab)
            }
            if (router.staticDebugScene !== "") {
                return perform(() => router.setStaticScene(""))
            }
            return dispatch("quit")
        }
        return false
    }

    function routeIconDebug(action) {
        if (routeIconDirection(action)) {
            return true
        }
        if (action === router.actionMap.Secondary || action === router.actionMap.Back) {
            return perform(router.exitIconLab)
        }
        if (action === router.actionMap.Primary) {
            return perform(router.performPrimary)
        }
        if (action === router.actionMap.Start || action === router.actionMap.SelectShort) {
            return true
        }
        return false
    }

    function routeStaticScene(action) {
        if (action === router.actionMap.NavUp || action === router.actionMap.NavLeft) {
            return perform(() => router.cycleStaticScene(-1))
        }
        if (action === router.actionMap.NavDown || action === router.actionMap.NavRight) {
            return perform(() => router.cycleStaticScene(1))
        }
        if (action === router.actionMap.Primary || action === router.actionMap.Secondary ||
                action === router.actionMap.Start || action === router.actionMap.SelectShort ||
                action === router.actionMap.Back) {
            return perform(() => router.setStaticScene(""))
        }
        return true
    }

    function routeMode(mode, action) {
        if (routeDirection(action)) {
            return true
        }

        if (mode === router.modeOverlay) {
            return routeOverlayAction(action)
        }
        if (mode === router.modePage) {
            return routePageAction(action)
        }
        if (mode === router.modeGame) {
            return routeGameAction(action)
        }
        return routeShellAction(action)
    }

    function routeOverlayAction(action) {
        if (action === router.actionMap.Start) {
            return perform(router.performStart)
        }
        if (action === router.actionMap.Primary) {
            if (router.currentState === AppState.Paused && router.trackEasterToken) {
                router.trackEasterToken("A")
            }
            return true
        }
        if (action === router.actionMap.Secondary) {
            if (router.currentState === AppState.Paused && router.trackEasterToken) {
                router.trackEasterToken("B")
            }
            return true
        }
        if (action === router.actionMap.SelectShort || action === router.actionMap.Back) {
            return dispatchBack()
        }
        return false
    }

    function routePageAction(action) {
        if (action === router.actionMap.Secondary || action === router.actionMap.Back) {
            return dispatchBack()
        }
        if (action === router.actionMap.Primary || action === router.actionMap.Start ||
                action === router.actionMap.SelectShort) {
            return true
        }
        return false
    }

    function routeGameAction(action) {
        if (action === router.actionMap.Primary) {
            return true
        }
        if (action === router.actionMap.Secondary) {
            return perform(router.performSecondary)
        }
        if (action === router.actionMap.Start) {
            return perform(router.performStart)
        }
        if (action === router.actionMap.SelectShort) {
            return perform(router.performSelectShort)
        }
        if (action === router.actionMap.Back) {
            return perform(router.performBack)
        }
        return false
    }

    function routeShellAction(action) {
        if (action === router.actionMap.Primary) {
            if (router.saveClearConfirmPending) {
                return perform(router.performPrimary)
            }
            return true
        }
        if (action === router.actionMap.Secondary) {
            return perform(router.performSecondary)
        }
        if (action === router.actionMap.Back) {
            return perform(router.performBack)
        }
        if (action === router.actionMap.Start) {
            return perform(router.performStart)
        }
        if (action === router.actionMap.SelectShort) {
            return perform(router.performSelectShort)
        }
        return false
    }
}
