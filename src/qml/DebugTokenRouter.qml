import QtQuick
import SnakeGB 1.0

QtObject {
    id: router

    property var gameLogic
    property var actionMap: ({})
    property bool iconDebugMode: false
    property string staticDebugScene: ""
    property var staticDebugOptions: ({})
    property var showOsd
    property var dispatchAction
    property var clearDirectionVisuals
    property var setIconDebugMode
    property var setStaticDebugSceneValue
    property var setStaticDebugOptionsValue
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

    function parseStaticSceneOptions(sceneName, rawOptions) {
        const options = {}
        const raw = String(rawOptions || "").trim()
        if (raw.length === 0) {
            return options
        }

        const parts = raw.split(",").map((part) => part.trim()).filter((part) => part.length > 0)
        const bareValues = []

        for (const part of parts) {
            const separatorIndex = part.indexOf("=")
            if (separatorIndex < 0) {
                const bareInt = Number(part)
                if (Number.isInteger(bareInt)) {
                    bareValues.push(bareInt)
                }
                continue
            }

            const key = part.slice(0, separatorIndex).trim().toUpperCase()
            const value = part.slice(separatorIndex + 1).trim()
            if (key === "BUFF") {
                const buffType = Number(value)
                if (Number.isInteger(buffType) && buffType >= 1 && buffType <= 9) {
                    options.buffType = buffType
                }
            } else if (key === "SCORE") {
                const score = Number(value)
                if (Number.isInteger(score) && score >= 0) {
                    options.score = score
                }
            } else if (key === "HI") {
                const highScore = Number(value)
                if (Number.isInteger(highScore) && highScore >= 0) {
                    options.highScore = highScore
                }
            } else if (key === "REMAIN") {
                const remaining = Number(value)
                if (Number.isInteger(remaining) && remaining >= 0) {
                    options.buffRemaining = remaining
                }
            } else if (key === "TOTAL") {
                const total = Number(value)
                if (Number.isInteger(total) && total >= 1) {
                    options.buffTotal = total
                }
            } else if (key === "INDEX") {
                const choiceIndex = Number(value)
                if (Number.isInteger(choiceIndex) && choiceIndex >= 0) {
                    options.choiceIndex = choiceIndex
                }
            } else if (key === "TYPES") {
                options.choiceTypes = value
                    .split(/[|/]/)
                    .map((entry) => Number(entry.trim()))
                    .filter((entry) => Number.isInteger(entry) && entry >= 1 && entry <= 9)
                    .slice(0, 3)
            }
        }

        if (sceneName === "choice") {
            if (!options.choiceTypes || options.choiceTypes.length === 0) {
                options.choiceTypes = bareValues
                    .filter((entry) => Number.isInteger(entry) && entry >= 1 && entry <= 9)
                    .slice(0, 3)
            }
        } else if (bareValues.length > 0) {
            const buffType = bareValues[0]
            if (buffType >= 1 && buffType <= 9) {
                options.buffType = buffType
            }
        }

        return options
    }

    function setStaticScene(sceneName, options) {
        if (router.setIconDebugMode) {
            router.setIconDebugMode(false)
        }
        if (router.setStaticDebugSceneValue) {
            router.setStaticDebugSceneValue(sceneName)
        }
        if (router.setStaticDebugOptionsValue) {
            router.setStaticDebugOptionsValue(options ? options : {})
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
        const scenes = ["boot", "game", "replay", "choice"]
        if (router.staticDebugScene === "") {
            setStaticScene("boot", {})
            return
        }
        let idx = scenes.indexOf(router.staticDebugScene)
        if (idx < 0) {
            idx = 0
        }
        idx = (idx + direction + scenes.length) % scenes.length
        setStaticScene(scenes[idx], {})
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
        if (token.startsWith("DBG_CHOICE")) {
            let choiceTypes = []
            const separatorIndex = token.indexOf(":")
            if (separatorIndex >= 0 && separatorIndex + 1 < token.length) {
                choiceTypes = token
                    .slice(separatorIndex + 1)
                    .split(",")
                    .map((part) => Number(part.trim()))
                    .filter((value) => Number.isInteger(value) && value >= 1 && value <= 9)
            }
            router.gameLogic.debugSeedChoicePreview(choiceTypes)
            if (router.showOsd) {
                router.showOsd(choiceTypes.length > 0
                    ? `DBG: CHOICE ${choiceTypes.join("/")}`
                    : "DBG: CHOICE")
            }
            return true
        }
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
        if (token.startsWith("DBG_STATIC_")) {
            const separatorIndex = token.indexOf(":")
            const baseToken = separatorIndex >= 0 ? token.slice(0, separatorIndex) : token
            const rawOptions = separatorIndex >= 0 ? token.slice(separatorIndex + 1) : ""
            if (baseToken === "DBG_STATIC_BOOT") {
                setStaticScene("boot", parseStaticSceneOptions("boot", rawOptions))
                return true
            }
            if (baseToken === "DBG_STATIC_GAME") {
                setStaticScene("game", parseStaticSceneOptions("game", rawOptions))
                return true
            }
            if (baseToken === "DBG_STATIC_REPLAY") {
                setStaticScene("replay", parseStaticSceneOptions("replay", rawOptions))
                return true
            }
            if (baseToken === "DBG_STATIC_CHOICE") {
                setStaticScene("choice", parseStaticSceneOptions("choice", rawOptions))
                return true
            }
            if (baseToken === "DBG_STATIC_OFF") {
                setStaticScene("", {})
                return true
            }
            return true
        }
        return false
    }
}
