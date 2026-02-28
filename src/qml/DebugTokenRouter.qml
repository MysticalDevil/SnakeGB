import QtQuick
import SnakeGB 1.0

QtObject {
    id: router

    property var gameLogic
    property var actionMap: ({})
    property bool iconDebugMode: false
    property string staticDebugScene: ""
    property var showOsd
    property var dispatchAction
    property var clearDirectionVisuals
    property var setIconDebugMode
    property var setStaticDebugSceneValue
    property var resetKonamiProgress

    function toggleIconLabMode() {
        if (router.setIconDebugMode) {
            router.setIconDebugMode(!router.iconDebugMode)
        }
        if (router.resetKonamiProgress) {
            router.resetKonamiProgress()
        }
        if (router.setStaticDebugSceneValue) {
            router.setStaticDebugSceneValue("")
        }
        if (router.showOsd) {
            router.showOsd(router.iconDebugMode ? "ICON LAB OFF" : "ICON LAB ON")
        }
        if (router.iconDebugMode) {
            router.gameLogic.dispatchUiAction("state_start_menu")
        }
    }

    function setStaticScene(sceneName) {
        if (router.setIconDebugMode) {
            router.setIconDebugMode(false)
        }
        if (router.setStaticDebugSceneValue) {
            router.setStaticDebugSceneValue(sceneName)
        }
        if (router.showOsd) {
            if (sceneName === "") {
                router.showOsd("STATIC DEBUG OFF")
            } else {
                router.showOsd(`STATIC DEBUG: ${sceneName.toUpperCase()}`)
            }
        }
    }

    function cycleStaticScene(direction) {
        const scenes = ["boot", "game", "replay"]
        if (router.staticDebugScene === "") {
            setStaticScene("boot")
            return
        }
        let idx = scenes.indexOf(router.staticDebugScene)
        if (idx < 0) {
            idx = 0
        }
        idx = (idx + direction + scenes.length) % scenes.length
        setStaticScene(scenes[idx])
    }

    function exitIconLab() {
        if (router.setIconDebugMode) {
            router.setIconDebugMode(false)
        }
        if (router.resetKonamiProgress) {
            router.resetKonamiProgress()
        }
        if (router.clearDirectionVisuals) {
            router.clearDirectionVisuals()
        }
        router.gameLogic.dispatchUiAction("state_start_menu")
        if (router.showOsd) {
            router.showOsd("ICON LAB OFF")
        }
    }

    function routeDebugToken(token) {
        if (token === "DBG_MENU") {
            if (router.iconDebugMode) {
                exitIconLab()
            } else {
                router.gameLogic.dispatchUiAction("state_start_menu")
                if (router.showOsd) {
                    router.showOsd("DBG: MENU")
                }
            }
            return true
        }
        if (token === "DBG_PLAY") {
            router.gameLogic.dispatchUiAction("state_start_menu")
            if (router.dispatchAction) {
                router.dispatchAction(router.actionMap.Start)
            }
            if (router.showOsd) {
                router.showOsd("DBG: PLAY")
            }
            return true
        }
        if (token === "DBG_PAUSE") {
            router.gameLogic.dispatchUiAction("state_start_menu")
            if (router.dispatchAction) {
                router.dispatchAction(router.actionMap.Start)
                router.dispatchAction(router.actionMap.Start)
            }
            if (router.showOsd) {
                router.showOsd("DBG: PAUSE")
            }
            return true
        }
        if (token === "DBG_GAMEOVER") {
            router.gameLogic.requestStateChange(AppState.GameOver)
            if (router.showOsd) {
                router.showOsd("DBG: GAMEOVER")
            }
            return true
        }
        if (token === "DBG_REPLAY") {
            router.gameLogic.requestStateChange(AppState.Replaying)
            if (router.showOsd) {
                router.showOsd("DBG: REPLAY")
            }
            return true
        }
        if (token === "DBG_REPLAY_BUFF") {
            router.gameLogic.debugSeedReplayBuffPreview()
            return true
        }
        if (token === "DBG_CHOICE") {
            router.gameLogic.requestStateChange(AppState.ChoiceSelection)
            if (router.showOsd) {
                router.showOsd("DBG: CHOICE")
            }
            return true
        }
        if (token === "DBG_CATALOG") {
            router.gameLogic.requestStateChange(AppState.Library)
            if (router.showOsd) {
                router.showOsd("DBG: CATALOG")
            }
            return true
        }
        if (token === "DBG_ACHIEVEMENTS") {
            router.gameLogic.requestStateChange(AppState.MedalRoom)
            if (router.showOsd) {
                router.showOsd("DBG: ACHIEVEMENTS")
            }
            return true
        }
        if (token === "DBG_ICONS") {
            if (!router.iconDebugMode) {
                toggleIconLabMode()
            }
            if (router.showOsd) {
                router.showOsd("DBG: ICON LAB")
            }
            return true
        }
        if (token === "DBG_STATIC_BOOT") {
            setStaticScene("boot")
            return true
        }
        if (token === "DBG_STATIC_GAME") {
            setStaticScene("game")
            return true
        }
        if (token === "DBG_STATIC_REPLAY") {
            setStaticScene("replay")
            return true
        }
        if (token === "DBG_STATIC_OFF") {
            setStaticScene("")
            return true
        }
        return false
    }
}
