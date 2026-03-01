import QtQuick
import SnakeGB 1.0

QtObject {
    id: router

    property var commandController
    property var inputController
    property var debugController
    property int currentState: AppState.Splash
    property var actionMap: ({})
    property bool iconDebugMode: false
    property string staticDebugScene: ""
    property var moveIconLabSelection

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

    function directionForAction(action) {
        if (action === router.actionMap.NavUp) {
            return { dx: 0, dy: -1, token: "U" }
        }
        if (action === router.actionMap.NavDown) {
            return { dx: 0, dy: 1, token: "D" }
        }
        if (action === router.actionMap.NavLeft) {
            return { dx: -1, dy: 0, token: "L" }
        }
        if (action === router.actionMap.NavRight) {
            return { dx: 1, dy: 0, token: "R" }
        }
        return null
    }

    function routeDirection(action) {
        const direction = router.directionForAction(action)
        if (!direction) {
            return false
        }

        if (router.debugController && router.debugController.handleEasterInput(direction.token)) {
            if (router.inputController) {
                router.inputController.clearDirectionVisuals()
            }
            return true
        }
        if (router.inputController) {
            router.inputController.handleDirection(direction.dx, direction.dy)
        }
        return true
    }

    function routeIconDirection(action) {
        const direction = router.directionForAction(action)
        if (!direction) {
            return false
        }

        if (router.debugController) {
            router.debugController.handleEasterInput(direction.token)
        }
        if (router.moveIconLabSelection) {
            router.moveIconLabSelection(direction.dx, direction.dy)
        }
        if (router.inputController) {
            router.inputController.setDpadPressed(direction.dx, direction.dy)
        }
        return true
    }

    function routeGlobal(action) {
        if (action === router.actionMap.ToggleIconLab) {
            return router.debugController
                ? perform(router.debugController.toggleIconLabMode)
                : false
        }
        if (action === router.actionMap.ToggleShellColor) {
            return dispatch("toggle_shell_color")
        }
        if (action === router.actionMap.ToggleMusic) {
            return dispatch("toggle_music")
        }
        if (action === router.actionMap.Escape) {
            if (router.iconDebugMode) {
                return router.debugController
                    ? perform(router.debugController.exitIconLab)
                    : false
            }
            if (router.staticDebugScene !== "") {
                return router.debugController
                    ? perform(() => router.debugController.setStaticScene("", {}))
                    : false
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
            return router.debugController
                ? perform(router.debugController.exitIconLab)
                : false
        }
        if (action === router.actionMap.Primary) {
            return router.inputController
                ? perform(router.inputController.handlePrimaryAction)
                : false
        }
        if (action === router.actionMap.Start || action === router.actionMap.SelectShort) {
            return true
        }
        return false
    }

    function routeStaticScene(action) {
        if (action === router.actionMap.NavUp || action === router.actionMap.NavLeft) {
            return router.debugController
                ? perform(() => router.debugController.cycleStaticScene(-1))
                : false
        }
        if (action === router.actionMap.NavDown || action === router.actionMap.NavRight) {
            return router.debugController
                ? perform(() => router.debugController.cycleStaticScene(1))
                : false
        }
        if (action === router.actionMap.Primary || action === router.actionMap.Secondary ||
                action === router.actionMap.Start || action === router.actionMap.SelectShort ||
                action === router.actionMap.Back) {
            return router.debugController
                ? perform(() => router.debugController.setStaticScene("", {}))
                : false
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
            return router.inputController
                ? perform(router.inputController.handleStartAction)
                : false
        }
        if (action === router.actionMap.Primary) {
            if (router.currentState === AppState.Paused && router.debugController) {
                router.debugController.handleEasterInput("A")
            }
            return true
        }
        if (action === router.actionMap.Secondary) {
            if (router.currentState === AppState.Paused && router.debugController) {
                router.debugController.handleEasterInput("B")
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
            return router.inputController
                ? perform(router.inputController.handleSecondaryAction)
                : false
        }
        if (action === router.actionMap.Start) {
            return router.inputController
                ? perform(router.inputController.handleStartAction)
                : false
        }
        if (action === router.actionMap.SelectShort) {
            return router.inputController
                ? perform(router.inputController.handleSelectShortAction)
                : false
        }
        if (action === router.actionMap.Back) {
            return router.inputController
                ? perform(router.inputController.handleBackAction)
                : false
        }
        return false
    }

    function routeShellAction(action) {
        if (action === router.actionMap.Primary) {
            if (router.inputController &&
                    router.inputController.inputPressController.saveClearConfirmPending) {
                return perform(router.inputController.handlePrimaryAction)
            }
            return true
        }
        if (action === router.actionMap.Secondary) {
            return router.inputController
                ? perform(router.inputController.handleSecondaryAction)
                : false
        }
        if (action === router.actionMap.Back) {
            return router.inputController
                ? perform(router.inputController.handleBackAction)
                : false
        }
        if (action === router.actionMap.Start) {
            return router.inputController
                ? perform(router.inputController.handleStartAction)
                : false
        }
        if (action === router.actionMap.SelectShort) {
            return router.inputController
                ? perform(router.inputController.handleSelectShortAction)
                : false
        }
        return false
    }
}
