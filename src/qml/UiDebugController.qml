import QtQuick
import NenoSerpent 1.0
import "meta/AchievementMeta.js" as AchievementMeta
import "debug/DebugTokenParser.js" as DebugTokenParser
import "debug/DebugStateFactory.js" as DebugStateFactory

QtObject {
    id: controller

    property var commandController
    property var inputInjector
    property var uiLogger
    property var actionMap: ({})
    property int currentState: AppState.Splash
    property bool iconDebugMode: false
    property string staticDebugScene: ""
    property var staticDebugOptions: ({})
    property var screen
    property var inputController
    property var clearDirectionVisuals
    property var stateOwner

    readonly property var konamiSequence: ["U", "U", "D", "D", "L", "R", "L", "R", "B", "A"]
    readonly property var medalIds: AchievementMeta.ids()
    property int konamiIndex: 0

    function resetKonamiProgress() {
        controller.konamiIndex = 0
        konamiResetTimer.stop()
    }

    function toggleIconLabMode() {
        const nextEnabled = !controller.iconDebugMode
        if (controller.stateOwner) {
            controller.stateOwner.iconDebugMode = nextEnabled
            controller.stateOwner.staticDebugScene = ""
            controller.stateOwner.staticDebugOptions = ({})
        }
        controller.resetKonamiProgress()
        if (controller.screen) {
            controller.screen.showOSD(nextEnabled ? "ICON LAB ON" : "ICON LAB OFF")
        }
        if (!nextEnabled && controller.commandController) {
            controller.commandController.dispatch("state_start_menu")
        }
    }

    function setStaticScene(sceneName, options) {
        if (controller.stateOwner) {
            controller.stateOwner.iconDebugMode = false
            controller.stateOwner.staticDebugScene = sceneName
            controller.stateOwner.staticDebugOptions = options ? options : ({})
        }
        controller.resetKonamiProgress()
        if (controller.showOsd) {
            controller.showOsd(sceneName === ""
                ? "STATIC DEBUG OFF"
                : `STATIC DEBUG: ${sceneName.toUpperCase()}`)
        }
        if (controller.uiLogger) {
            controller.uiLogger.routingSummary(sceneName === ""
                ? "static scene cleared"
                : `static scene=${sceneName}`)
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

    function toggleBotDebugPanel() {
        if (!controller.stateOwner) {
            return
        }
        controller.stateOwner.botDebugPanelVisible = !controller.stateOwner.botDebugPanelVisible
        controller.showDebugOsd(controller.stateOwner.botDebugPanelVisible
            ? "BOT PANEL ON"
            : "BOT PANEL OFF")
    }

    function exitIconLab() {
        if (controller.stateOwner) {
            controller.stateOwner.iconDebugMode = false
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
                if (controller.stateOwner) {
                    controller.stateOwner.iconDebugMode = nextEnabled
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
        if (controller.screen) {
            controller.screen.showOSD(text)
        }
    }

    function activateStaticScene(sceneName, rawOptions) {
        const options = rawOptions === undefined
            ? {}
            : DebugTokenParser.parseStaticSceneOptions(sceneName, rawOptions)
        controller.setStaticScene(sceneName, options)
        return true
    }

    function resolveAppState(stateName) {
        if (stateName === "GameOver") return AppState.GameOver
        if (stateName === "Replaying") return AppState.Replaying
        if (stateName === "Library") return AppState.Library
        if (stateName === "MedalRoom") return AppState.MedalRoom
        return AppState.Splash
    }

    function routeParsedToken(parsed) {
        if (parsed.kind === "bot_panel") {
            controller.toggleBotDebugPanel()
            return true
        }
        if (parsed.kind === "catalog") {
            const state = DebugStateFactory.catalogState(parsed)
            if (controller.stateOwner) {
                controller.stateOwner.iconDebugMode = false
                controller.stateOwner.staticDebugScene = state.staticScene
                controller.stateOwner.staticDebugOptions = state.staticDebugOptions
            }
            controller.commandController.requestStateChange(controller.resolveAppState(state.nextState))
            controller.showDebugOsd(state.osdText)
            return true
        }
        if (parsed.kind === "achievements") {
            const state = DebugStateFactory.achievementsState(parsed)
            if (controller.stateOwner) {
                controller.stateOwner.iconDebugMode = false
                controller.stateOwner.staticDebugScene = state.staticScene
                controller.stateOwner.staticDebugOptions = state.staticDebugOptions
            }
            controller.commandController.requestStateChange(controller.resolveAppState(state.nextState))
            controller.showDebugOsd(state.osdText)
            return true
        }
        if (parsed.kind === "bot_mode") {
            controller.commandController.cycleBotMode()
            return true
        }
        if (parsed.kind === "bot_strategy") {
            controller.commandController.cycleBotStrategyMode()
            return true
        }
        if (parsed.kind === "bot_reset") {
            controller.commandController.resetBotModeDefaults()
            return true
        }
        if (parsed.kind === "bot_param") {
            let applied = false
            for (const part of parsed.params) {
                if (controller.commandController.setBotParam(part.key, part.value)) {
                    applied = true
                }
            }
            if (!applied) {
                controller.showDebugOsd("DBG BOT PARAM INVALID")
            }
            return true
        }
        if (parsed.kind === "choice") {
            controller.commandController.seedChoicePreview(parsed.choiceTypes)
            controller.showDebugOsd(parsed.choiceTypes.length > 0
                ? `DBG: CHOICE ${parsed.choiceTypes.join("/")}`
                : "DBG: CHOICE")
            return true
        }
        if (parsed.kind === "menu") {
            if (controller.iconDebugMode) {
                controller.exitIconLab()
            } else {
                controller.commandController.dispatch("state_start_menu")
                controller.showDebugOsd("DBG: MENU")
            }
            return true
        }
        if (parsed.kind === "play") {
            controller.commandController.dispatch("state_start_menu")
            if (controller.inputController) {
                controller.inputController.dispatchAction(controller.actionMap.Start)
            }
            controller.showDebugOsd("DBG: PLAY")
            return true
        }
        if (parsed.kind === "pause") {
            controller.commandController.dispatch("state_start_menu")
            if (controller.inputController) {
                controller.inputController.dispatchAction(controller.actionMap.Start)
                controller.inputController.dispatchAction(controller.actionMap.Start)
            }
            controller.showDebugOsd("DBG: PAUSE")
            return true
        }
        if (parsed.kind === "debug_state") {
            controller.commandController.requestStateChange(controller.resolveAppState(parsed.entry.state))
            controller.showDebugOsd(parsed.entry.osd)
            return true
        }
        if (parsed.kind === "replay_buff") {
            controller.commandController.seedReplayBuffPreview()
            return true
        }
        if (parsed.kind === "icons") {
            if (!controller.iconDebugMode) {
                controller.toggleIconLabMode()
            }
            controller.showDebugOsd("DBG: ICON LAB")
            return true
        }
        if (parsed.kind === "static_scene") {
            const state = DebugStateFactory.staticSceneState(parsed)
            controller.setStaticScene(state.staticScene, state.staticDebugOptions)
            return true
        }
        if (parsed.kind === "action") {
            if (controller.inputController) {
                controller.inputController.dispatchAction(controller.actionMap[parsed.actionKey])
            }
            return true
        }
        if (parsed.kind === "palette") {
            controller.commandController.dispatch("next_palette")
            return true
        }
        return parsed.kind !== "unknown"
    }

    function routeInjectedToken(rawToken) {
        const parsed = DebugTokenParser.parseToken(rawToken, controller.medalIds)
        if (controller.uiLogger) {
            controller.uiLogger.inputDebug(`inject token=${parsed.token}`)
        }
        if (controller.routeParsedToken(parsed)) {
            return true
        }
        controller.showDebugOsd(`UNKNOWN INPUT: ${parsed.token}`)
        if (controller.uiLogger) {
            controller.uiLogger.injectWarning(`unknown token=${parsed.token}`)
        }
        return false
    }

    property Timer konamiResetTimer: Timer {
        interval: 1400
        repeat: false
        onTriggered: controller.konamiIndex = 0
    }

    property var inputInjectorConnection: Connections {
        target: controller.inputInjector

        function onActionInjected(action) {
            controller.routeInjectedToken(action)
        }
    }
}
