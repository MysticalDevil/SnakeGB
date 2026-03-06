.pragma library

function catalogState(parsed) {
    return {
        nextState: "Library",
        staticScene: "",
        staticDebugOptions: {
            discoveredTypes: parsed.discoveredTypes,
            discoverAllFruits: parsed.discoverAllFruits
        },
        osdText: parsed.discoverAllFruits
            ? "DBG: CATALOG ALL"
            : (parsed.discoveredTypes.length > 0 ? `DBG: CATALOG ${parsed.discoveredTypes.join("/")}` : "DBG: CATALOG")
    }
}

function achievementsState(parsed) {
    return {
        nextState: "MedalRoom",
        staticScene: "",
        staticDebugOptions: {
            unlockedAchievementIds: parsed.unlockedAchievementIds,
            unlockAllAchievements: parsed.unlockAllAchievements
        },
        osdText: parsed.unlockAllAchievements
            ? "DBG: ACHIEVEMENTS ALL"
            : (parsed.unlockedAchievementIds.length > 0 ? `DBG: ACH ${parsed.unlockedAchievementIds.length}` : "DBG: ACHIEVEMENTS")
    }
}

function staticSceneState(parsed) {
    return {
        nextState: null,
        staticScene: parsed.sceneName,
        staticDebugOptions: parsed.options,
        osdText: parsed.sceneName === "" ? "STATIC DEBUG OFF" : `STATIC DEBUG: ${String(parsed.sceneName).toUpperCase()}`
    }
}
