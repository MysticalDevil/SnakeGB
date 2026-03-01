import QtQuick
import SnakeGB 1.0

QtObject {
    id: controller

    property var commandController
    property var actionMap: ({})
    property int currentState: AppState.Splash
    property bool iconDebugMode: false
    property string staticDebugScene: ""
    property var staticDebugOptions: ({})
    property var showOsd
    property var dispatchAction
    property var clearDirectionVisuals
    property var setIconDebugMode
    property var setStaticDebugSceneValue
    property var setStaticDebugOptionsValue

    readonly property var konamiSequence: ["U", "U", "D", "D", "L", "R", "L", "R", "B", "A"]
    readonly property var debugStateTokens: ({
        DBG_GAMEOVER: { state: AppState.GameOver, osd: "DBG: GAMEOVER" },
        DBG_REPLAY: { state: AppState.Replaying, osd: "DBG: REPLAY" },
        DBG_CATALOG: { state: AppState.Library, osd: "DBG: CATALOG" },
        DBG_ACHIEVEMENTS: { state: AppState.MedalRoom, osd: "DBG: ACHIEVEMENTS" }
    })
    readonly property var staticSceneAliases: ({
        DBG_STATIC_BOOT: "boot",
        DBG_STATIC_GAME: "game",
        DBG_STATIC_REPLAY: "replay",
        DBG_STATIC_CHOICE: "choice",
        DBG_STATIC_OFF: "",
        STATIC_BOOT: "boot",
        STATIC_GAME: "game",
        STATIC_REPLAY: "replay",
        STATIC_CHOICE: "choice",
        STATIC_OFF: ""
    })
    readonly property var injectedActionTokens: ({
        UP: "NavUp",
        U: "NavUp",
        DOWN: "NavDown",
        D: "NavDown",
        LEFT: "NavLeft",
        L: "NavLeft",
        RIGHT: "NavRight",
        R: "NavRight",
        A: "Primary",
        PRIMARY: "Primary",
        OK: "Primary",
        B: "Secondary",
        SECONDARY: "Secondary",
        START: "Start",
        SELECT: "SelectShort",
        BACK: "Back",
        ESC: "Escape",
        ESCAPE: "Escape",
        F6: "ToggleIconLab",
        ICON: "ToggleIconLab",
        COLOR: "ToggleShellColor",
        SHELL: "ToggleShellColor",
        MUSIC: "ToggleMusic"
    })
    property int konamiIndex: 0

    function resetKonamiProgress() {
        controller.konamiIndex = 0
        konamiResetTimer.stop()
    }

    function toggleIconLabMode() {
        const nextEnabled = !controller.iconDebugMode
        if (controller.setIconDebugMode) {
            controller.setIconDebugMode(nextEnabled)
        }
        if (controller.setStaticDebugSceneValue) {
            controller.setStaticDebugSceneValue("")
        }
        if (controller.setStaticDebugOptionsValue) {
            controller.setStaticDebugOptionsValue({})
        }
        controller.resetKonamiProgress()
        if (controller.showOsd) {
            controller.showOsd(nextEnabled ? "ICON LAB ON" : "ICON LAB OFF")
        }
        if (!nextEnabled && controller.commandController) {
            controller.commandController.dispatch("state_start_menu")
        }
    }

    function parseStaticSceneOptions(sceneName, rawOptions) {
        function decodeLabel(value) {
            return String(value || "").replace(/\+/g, " ").replace(/_/g, " ")
        }

        function parsePointList(value) {
            return value
                .split(/[|/]/)
                .map((entry) => entry.trim())
                .filter((entry) => entry.length > 0)
                .map((entry) => {
                    const parts = entry.split(":").map((part) => part.trim())
                    if (parts.length < 2) {
                        return null
                    }
                    const x = Number(parts[0])
                    const y = Number(parts[1])
                    if (!Number.isInteger(x) || !Number.isInteger(y)) {
                        return null
                    }
                    const point = { x, y }
                    if (parts.length >= 3) {
                        const marker = parts[2]
                        point.head = marker === "H" || marker === "h" || marker === "1"
                    }
                    return point
                })
                .filter((entry) => !!entry)
        }

        function parsePowerupList(value) {
            return value
                .split(/[|/]/)
                .map((entry) => entry.trim())
                .filter((entry) => entry.length > 0)
                .map((entry) => {
                    const parts = entry.split(":").map((part) => part.trim())
                    if (parts.length < 2) {
                        return null
                    }
                    const x = Number(parts[0])
                    const y = Number(parts[1])
                    const type = parts.length >= 3 ? Number(parts[2]) : 1
                    if (!Number.isInteger(x) || !Number.isInteger(y) ||
                            !Number.isInteger(type) || type < 1 || type > 9) {
                        return null
                    }
                    return { x, y, type }
                })
                .filter((entry) => !!entry)
        }

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
            } else if (key === "TYPES" || key === "CHOICES") {
                options.choiceTypes = value
                    .split(/[|/]/)
                    .map((entry) => Number(entry.trim()))
                    .filter((entry) => Number.isInteger(entry) && entry >= 1 && entry <= 9)
                    .slice(0, 3)
            } else if (key === "TITLE") {
                if (sceneName === "boot") {
                    options.bootTitle = decodeLabel(value)
                } else if (sceneName === "choice") {
                    options.choiceTitle = decodeLabel(value)
                }
            } else if (key === "SUBTITLE") {
                if (sceneName === "boot") {
                    options.bootSubtitle = decodeLabel(value)
                } else if (sceneName === "choice") {
                    options.choiceSubtitle = decodeLabel(value)
                }
            } else if (key === "LOAD" || key === "LOADLABEL") {
                options.bootLoadLabel = decodeLabel(value)
            } else if (key === "PROGRESS" || key === "LOADPROGRESS") {
                const progress = Number(value)
                if (!Number.isNaN(progress)) {
                    options.bootLoadProgress = progress > 1 ? progress / 100.0 : progress
                }
            } else if (key === "FOOTER" || key === "FOOTERHINT") {
                options.choiceFooterHint = decodeLabel(value)
            } else if (key === "SNAKE") {
                options.snakeSegments = parsePointList(value)
            } else if (key === "FOOD") {
                options.foodCells = parsePointList(value).map((cell) => ({ x: cell.x, y: cell.y }))
            } else if (key === "OBSTACLES") {
                options.obstacleCells = parsePointList(value).map((cell) => (
                    { x: cell.x, y: cell.y }
                ))
            } else if (key === "POWERUPS") {
                options.powerupCells = parsePowerupList(value)
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
        if (controller.setIconDebugMode) {
            controller.setIconDebugMode(false)
        }
        if (controller.setStaticDebugSceneValue) {
            controller.setStaticDebugSceneValue(sceneName)
        }
        if (controller.setStaticDebugOptionsValue) {
            controller.setStaticDebugOptionsValue(options ? options : {})
        }
        controller.resetKonamiProgress()
        if (controller.showOsd) {
            controller.showOsd(sceneName === ""
                ? "STATIC DEBUG OFF"
                : `STATIC DEBUG: ${sceneName.toUpperCase()}`)
        }
    }

    function cycleStaticScene(direction) {
        const scenes = ["boot", "game", "replay", "choice"]
        if (controller.staticDebugScene === "") {
            controller.setStaticScene("boot", {})
            return
        }
        let index = scenes.indexOf(controller.staticDebugScene)
        if (index < 0) {
            index = 0
        }
        index = (index + direction + scenes.length) % scenes.length
        controller.setStaticScene(scenes[index], {})
    }

    function exitIconLab() {
        if (controller.setIconDebugMode) {
            controller.setIconDebugMode(false)
        }
        if (controller.clearDirectionVisuals) {
            controller.clearDirectionVisuals()
        }
        controller.resetKonamiProgress()
        if (controller.commandController) {
            controller.commandController.dispatch("state_start_menu")
        }
        if (controller.showOsd) {
            controller.showOsd("ICON LAB OFF")
        }
    }

    function feedKonamiToken(token) {
        if (token === controller.konamiSequence[controller.konamiIndex]) {
            controller.konamiIndex += 1
            konamiResetTimer.restart()
            if (controller.konamiIndex >= controller.konamiSequence.length) {
                const nextEnabled = !controller.iconDebugMode
                controller.konamiIndex = 0
                konamiResetTimer.stop()
                if (controller.setIconDebugMode) {
                    controller.setIconDebugMode(nextEnabled)
                }
                if (controller.showOsd) {
                    controller.showOsd(nextEnabled ? "ICON LAB ON" : "ICON LAB OFF")
                }
                if (!nextEnabled && controller.commandController) {
                    controller.commandController.dispatch("state_start_menu")
                }
                return "toggle"
            }
            return "progress"
        }
        controller.konamiIndex = token === controller.konamiSequence[0] ? 1 : 0
        if (controller.konamiIndex > 0) {
            konamiResetTimer.restart()
        } else {
            konamiResetTimer.stop()
        }
        return "mismatch"
    }

    function handleEasterInput(token) {
        const trackEaster = controller.iconDebugMode || controller.currentState === AppState.Paused
        if (!trackEaster) {
            return false
        }

        if (controller.iconDebugMode && token === "B" && controller.konamiIndex === 0) {
            controller.exitIconLab()
            return true
        }

        const previousIndex = controller.konamiIndex
        const status = controller.feedKonamiToken(token)
        if (controller.iconDebugMode) {
            return true
        }
        if (status === "toggle") {
            return true
        }
        return previousIndex > 0
    }

    function showDebugOsd(text) {
        if (controller.showOsd) {
            controller.showOsd(text)
        }
    }

    function activateStaticScene(sceneName, rawOptions) {
        const options = rawOptions === undefined
            ? {}
            : controller.parseStaticSceneOptions(sceneName, rawOptions)
        controller.setStaticScene(sceneName, options)
        return true
    }

    function routeMappedDebugStateToken(token) {
        const entry = controller.debugStateTokens[token]
        if (!entry) {
            return false
        }
        controller.commandController.requestStateChange(entry.state)
        controller.showDebugOsd(entry.osd)
        return true
    }

    function routeMappedStaticSceneToken(token, rawOptions) {
        if (!(token in controller.staticSceneAliases)) {
            return false
        }
        const sceneName = controller.staticSceneAliases[token]
        if (rawOptions !== undefined && token.startsWith("DBG_STATIC_") && sceneName !== "") {
            return controller.activateStaticScene(sceneName, rawOptions)
        }
        controller.setStaticScene(sceneName, {})
        return true
    }

    function dispatchInjectedAlias(token) {
        const actionKey = controller.injectedActionTokens[token]
        if (!actionKey) {
            return false
        }
        controller.dispatchAction(controller.actionMap[actionKey])
        return true
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
            controller.commandController.seedChoicePreview(choiceTypes)
            controller.showDebugOsd(choiceTypes.length > 0
                ? `DBG: CHOICE ${choiceTypes.join("/")}`
                : "DBG: CHOICE")
            return true
        }
        if (token === "DBG_MENU") {
            if (controller.iconDebugMode) {
                controller.exitIconLab()
            } else {
                controller.commandController.dispatch("state_start_menu")
                controller.showDebugOsd("DBG: MENU")
            }
            return true
        }
        if (token === "DBG_PLAY") {
            controller.commandController.dispatch("state_start_menu")
            if (controller.dispatchAction) {
                controller.dispatchAction(controller.actionMap.Start)
            }
            controller.showDebugOsd("DBG: PLAY")
            return true
        }
        if (token === "DBG_PAUSE") {
            controller.commandController.dispatch("state_start_menu")
            if (controller.dispatchAction) {
                controller.dispatchAction(controller.actionMap.Start)
                controller.dispatchAction(controller.actionMap.Start)
            }
            controller.showDebugOsd("DBG: PAUSE")
            return true
        }
        if (controller.routeMappedDebugStateToken(token)) {
            return true
        }
        if (token === "DBG_REPLAY_BUFF") {
            controller.commandController.seedReplayBuffPreview()
            return true
        }
        if (token === "DBG_ICONS") {
            if (!controller.iconDebugMode) {
                controller.toggleIconLabMode()
            }
            controller.showDebugOsd("DBG: ICON LAB")
            return true
        }
        if (token.startsWith("DBG_STATIC_")) {
            const separatorIndex = token.indexOf(":")
            const baseToken = separatorIndex >= 0 ? token.slice(0, separatorIndex) : token
            const rawOptions = separatorIndex >= 0 ? token.slice(separatorIndex + 1) : ""
            return controller.routeMappedStaticSceneToken(baseToken, rawOptions)
        }
        return false
    }

    function routeInjectedToken(rawToken) {
        const token = String(rawToken).trim().toUpperCase()
        if (controller.routeDebugToken(token)) {
            return true
        }
        if (controller.dispatchInjectedAlias(token)) {
            return true
        }
        if (token === "PALETTE" || token === "NEXT_PALETTE") {
            controller.commandController.dispatch("next_palette")
            return true
        }
        if (controller.routeMappedStaticSceneToken(token)) {
            return true
        }
        controller.showDebugOsd(`UNKNOWN INPUT: ${token}`)
        return false
    }

    property Timer konamiResetTimer: Timer {
        interval: 1400
        repeat: false
        onTriggered: controller.konamiIndex = 0
    }
}
