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
            if (controller.showOsd) {
                controller.showOsd(choiceTypes.length > 0
                    ? `DBG: CHOICE ${choiceTypes.join("/")}`
                    : "DBG: CHOICE")
            }
            return true
        }
        if (token === "DBG_MENU") {
            if (controller.iconDebugMode) {
                controller.exitIconLab()
            } else {
                controller.commandController.dispatch("state_start_menu")
                if (controller.showOsd) {
                    controller.showOsd("DBG: MENU")
                }
            }
            return true
        }
        if (token === "DBG_PLAY") {
            controller.commandController.dispatch("state_start_menu")
            if (controller.dispatchAction) {
                controller.dispatchAction(controller.actionMap.Start)
            }
            if (controller.showOsd) {
                controller.showOsd("DBG: PLAY")
            }
            return true
        }
        if (token === "DBG_PAUSE") {
            controller.commandController.dispatch("state_start_menu")
            if (controller.dispatchAction) {
                controller.dispatchAction(controller.actionMap.Start)
                controller.dispatchAction(controller.actionMap.Start)
            }
            if (controller.showOsd) {
                controller.showOsd("DBG: PAUSE")
            }
            return true
        }
        if (token === "DBG_GAMEOVER") {
            controller.commandController.requestStateChange(AppState.GameOver)
            if (controller.showOsd) {
                controller.showOsd("DBG: GAMEOVER")
            }
            return true
        }
        if (token === "DBG_REPLAY") {
            controller.commandController.requestStateChange(AppState.Replaying)
            if (controller.showOsd) {
                controller.showOsd("DBG: REPLAY")
            }
            return true
        }
        if (token === "DBG_REPLAY_BUFF") {
            controller.commandController.seedReplayBuffPreview()
            return true
        }
        if (token === "DBG_CATALOG") {
            controller.commandController.requestStateChange(AppState.Library)
            if (controller.showOsd) {
                controller.showOsd("DBG: CATALOG")
            }
            return true
        }
        if (token === "DBG_ACHIEVEMENTS") {
            controller.commandController.requestStateChange(AppState.MedalRoom)
            if (controller.showOsd) {
                controller.showOsd("DBG: ACHIEVEMENTS")
            }
            return true
        }
        if (token === "DBG_ICONS") {
            if (!controller.iconDebugMode) {
                controller.toggleIconLabMode()
            }
            if (controller.showOsd) {
                controller.showOsd("DBG: ICON LAB")
            }
            return true
        }
        if (token.startsWith("DBG_STATIC_")) {
            const separatorIndex = token.indexOf(":")
            const baseToken = separatorIndex >= 0 ? token.slice(0, separatorIndex) : token
            const rawOptions = separatorIndex >= 0 ? token.slice(separatorIndex + 1) : ""
            if (baseToken === "DBG_STATIC_BOOT") {
                controller.setStaticScene(
                    "boot",
                    controller.parseStaticSceneOptions("boot", rawOptions))
                return true
            }
            if (baseToken === "DBG_STATIC_GAME") {
                controller.setStaticScene(
                    "game",
                    controller.parseStaticSceneOptions("game", rawOptions))
                return true
            }
            if (baseToken === "DBG_STATIC_REPLAY") {
                controller.setStaticScene(
                    "replay",
                    controller.parseStaticSceneOptions("replay", rawOptions))
                return true
            }
            if (baseToken === "DBG_STATIC_CHOICE") {
                controller.setStaticScene(
                    "choice",
                    controller.parseStaticSceneOptions("choice", rawOptions))
                return true
            }
            if (baseToken === "DBG_STATIC_OFF") {
                controller.setStaticScene("", {})
                return true
            }
            return true
        }
        return false
    }

    function routeInjectedToken(rawToken) {
        const token = String(rawToken).trim().toUpperCase()
        if (controller.routeDebugToken(token)) {
            return true
        }
        if (token === "UP" || token === "U") {
            controller.dispatchAction(controller.actionMap.NavUp)
            return true
        }
        if (token === "DOWN" || token === "D") {
            controller.dispatchAction(controller.actionMap.NavDown)
            return true
        }
        if (token === "LEFT" || token === "L") {
            controller.dispatchAction(controller.actionMap.NavLeft)
            return true
        }
        if (token === "RIGHT" || token === "R") {
            controller.dispatchAction(controller.actionMap.NavRight)
            return true
        }
        if (token === "A" || token === "PRIMARY" || token === "OK") {
            controller.dispatchAction(controller.actionMap.Primary)
            return true
        }
        if (token === "B" || token === "SECONDARY") {
            controller.dispatchAction(controller.actionMap.Secondary)
            return true
        }
        if (token === "START") {
            controller.dispatchAction(controller.actionMap.Start)
            return true
        }
        if (token === "SELECT") {
            controller.dispatchAction(controller.actionMap.SelectShort)
            return true
        }
        if (token === "BACK") {
            controller.dispatchAction(controller.actionMap.Back)
            return true
        }
        if (token === "ESC" || token === "ESCAPE") {
            controller.dispatchAction(controller.actionMap.Escape)
            return true
        }
        if (token === "F6" || token === "ICON") {
            controller.dispatchAction(controller.actionMap.ToggleIconLab)
            return true
        }
        if (token === "COLOR" || token === "SHELL") {
            controller.dispatchAction(controller.actionMap.ToggleShellColor)
            return true
        }
        if (token === "PALETTE" || token === "NEXT_PALETTE") {
            controller.commandController.dispatch("next_palette")
            return true
        }
        if (token === "MUSIC") {
            controller.dispatchAction(controller.actionMap.ToggleMusic)
            return true
        }
        if (token === "STATIC_BOOT") {
            controller.setStaticScene("boot", {})
            return true
        }
        if (token === "STATIC_GAME") {
            controller.setStaticScene("game", {})
            return true
        }
        if (token === "STATIC_REPLAY") {
            controller.setStaticScene("replay", {})
            return true
        }
        if (token === "STATIC_CHOICE") {
            controller.setStaticScene("choice", {})
            return true
        }
        if (token === "STATIC_OFF") {
            controller.setStaticScene("", {})
            return true
        }
        if (controller.showOsd) {
            controller.showOsd(`UNKNOWN INPUT: ${token}`)
        }
        return false
    }

    property Timer konamiResetTimer: Timer {
        interval: 1400
        repeat: false
        onTriggered: controller.konamiIndex = 0
    }
}
