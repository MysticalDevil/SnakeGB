import QtQuick
import SnakeGB 1.0

QtObject {
    id: router

    property var gameLogic
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

    function route(action) {
        if (routeGlobal(action)) return true
        if (router.staticDebugScene !== "") return routeStaticLayer(action)
        if (router.iconDebugMode) return routeIconLayer(action)

        const state = router.gameLogic.state
        if (isOverlayState(state)) return routeOverlayLayer(action)
        if (isPageState(state)) return routePageLayer(action)
        if (isGameplayState(state)) return routeGameLayer(action)
        return routeShellLayer(action)
    }

    function isOverlayState(state) {
        return state === AppState.Paused || state === AppState.GameOver ||
               state === AppState.Replaying || state === AppState.ChoiceSelection
    }

    function isPageState(state) {
        return state === AppState.Library || state === AppState.MedalRoom
    }

    function isGameplayState(state) {
        return state === AppState.Playing
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

    function routeGlobal(action) {
        if (action === router.actionMap.ToggleIconLab) {
            if (router.toggleIconLabMode) {
                router.toggleIconLabMode()
            }
            return true
        }
        if (action === router.actionMap.ToggleShellColor) {
            router.gameLogic.dispatchUiAction("toggle_shell_color")
            return true
        }
        if (action === router.actionMap.ToggleMusic) {
            router.gameLogic.dispatchUiAction("toggle_music")
            return true
        }
        if (action === router.actionMap.Escape) {
            if (router.iconDebugMode) {
                if (router.exitIconLab) {
                    router.exitIconLab()
                }
            } else if (router.staticDebugScene !== "") {
                if (router.setStaticScene) {
                    router.setStaticScene("")
                }
            } else {
                router.gameLogic.dispatchUiAction("quit")
            }
            return true
        }
        return false
    }

    function routeIconLayer(action) {
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
        }
        if (token !== "") {
            if (router.trackEasterToken) {
                router.trackEasterToken(token)
            }
            if (router.iconDebugMode) {
                if (router.moveIconLabSelection) {
                    router.moveIconLabSelection(dx, dy)
                }
                if (router.setDirectionPressed) {
                    router.setDirectionPressed(dx, dy)
                }
            }
            return true
        }
        if (action === router.actionMap.Secondary || action === router.actionMap.Back) {
            if (router.exitIconLab) {
                router.exitIconLab()
            }
            return true
        }
        if (action === router.actionMap.Primary) {
            if (router.performPrimary) {
                router.performPrimary()
            }
            return true
        }
        if (action === router.actionMap.Start || action === router.actionMap.SelectShort) {
            return true
        }
        return false
    }

    function routeStaticLayer(action) {
        if (action === router.actionMap.NavUp || action === router.actionMap.NavLeft) {
            if (router.cycleStaticScene) {
                router.cycleStaticScene(-1)
            }
            return true
        }
        if (action === router.actionMap.NavDown || action === router.actionMap.NavRight) {
            if (router.cycleStaticScene) {
                router.cycleStaticScene(1)
            }
            return true
        }
        if (action === router.actionMap.SelectShort || action === router.actionMap.Back ||
                action === router.actionMap.Secondary || action === router.actionMap.Start ||
                action === router.actionMap.Primary) {
            if (router.setStaticScene) {
                router.setStaticScene("")
            }
            return true
        }
        return true
    }

    function routeOverlayLayer(action) {
        if (routeDirection(action)) return true
        if (action === router.actionMap.Start) {
            if (router.performStart) {
                router.performStart()
            }
            return true
        }
        if (action === router.actionMap.Primary) {
            if (router.gameLogic.state === AppState.Paused && router.trackEasterToken) {
                router.trackEasterToken("A")
            }
            return true
        }
        if (action === router.actionMap.Secondary) {
            if (router.gameLogic.state === AppState.Paused && router.trackEasterToken) {
                router.trackEasterToken("B")
            }
            return true
        }
        if (action === router.actionMap.SelectShort) {
            router.gameLogic.dispatchUiAction(router.actionMap.Back)
            return true
        }
        if (action === router.actionMap.Back) {
            router.gameLogic.dispatchUiAction(router.actionMap.Back)
            return true
        }
        return false
    }

    function routePageLayer(action) {
        if (routeDirection(action)) return true
        if (action === router.actionMap.Secondary || action === router.actionMap.Back) {
            router.gameLogic.dispatchUiAction(router.actionMap.Back)
            return true
        }
        if (action === router.actionMap.Primary) return true
        if (action === router.actionMap.Start) return true
        if (action === router.actionMap.SelectShort) return true
        return false
    }

    function routeGameLayer(action) {
        if (routeDirection(action)) return true
        if (action === router.actionMap.Primary) return true
        if (action === router.actionMap.Secondary) {
            if (router.performSecondary) {
                router.performSecondary()
            }
            return true
        }
        if (action === router.actionMap.Start) {
            if (router.performStart) {
                router.performStart()
            }
            return true
        }
        if (action === router.actionMap.SelectShort) {
            if (router.performSelectShort) {
                router.performSelectShort()
            }
            return true
        }
        if (action === router.actionMap.Back) {
            if (router.performBack) {
                router.performBack()
            }
            return true
        }
        return false
    }

    function routeShellLayer(action) {
        if (routeDirection(action)) return true
        if (action === router.actionMap.Primary) {
            if (router.saveClearConfirmPending && router.performPrimary) {
                router.performPrimary()
            }
            return true
        }
        if (action === router.actionMap.Secondary) {
            if (router.performSecondary) {
                router.performSecondary()
            }
            return true
        }
        if (action === router.actionMap.Back) {
            if (router.performBack) {
                router.performBack()
            }
            return true
        }
        if (action === router.actionMap.Start) {
            if (router.performStart) {
                router.performStart()
            }
            return true
        }
        if (action === router.actionMap.SelectShort) {
            if (router.performSelectShort) {
                router.performSelectShort()
            }
            return true
        }
        return false
    }
}
