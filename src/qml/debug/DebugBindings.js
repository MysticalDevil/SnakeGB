.pragma library

function libraryProps(staticDebugOptions) {
    const options = staticDebugOptions || {}
    return {
        debugDiscoveredTypes: options.discoveredTypes ? options.discoveredTypes : [],
        debugDiscoverAll: options.discoverAllFruits === true
    }
}

function achievementProps(staticDebugOptions) {
    const options = staticDebugOptions || {}
    return {
        debugUnlockedAchievementIds: options.unlockedAchievementIds ? options.unlockedAchievementIds : [],
        debugUnlockAll: options.unlockAllAchievements === true
    }
}
