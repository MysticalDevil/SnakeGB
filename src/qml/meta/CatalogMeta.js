.pragma library

.import "PowerMeta.js" as PowerMeta

function isDebugDiscovered(type, debugDiscoveredTypes) {
    return !!debugDiscoveredTypes && debugDiscoveredTypes.indexOf(Number(type)) !== -1
}

function isDiscovered(entry, debugDiscoveredTypes, debugDiscoverAll) {
    return !!entry && (debugDiscoverAll || entry.discovered || isDebugDiscovered(entry.type, debugDiscoveredTypes))
}

function discoveredCount(entries, debugDiscoveredTypes, debugDiscoverAll) {
    if (!entries) {
        return 0
    }
    let count = 0
    for (let i = 0; i < entries.length; ++i) {
        if (isDiscovered(entries[i], debugDiscoveredTypes, debugDiscoverAll)) {
            count += 1
        }
    }
    return count
}

function resolveEntry(entry, debugDiscoveredTypes, debugDiscoverAll) {
    if (!entry) {
        return {
            discovered: false,
            name: "??????",
            description: ""
        }
    }
    const discovered = isDiscovered(entry, debugDiscoveredTypes, debugDiscoverAll)
    return {
        discovered: discovered,
        name: discovered ? PowerMeta.choiceName(Number(entry.type)).toUpperCase() : "??????",
        description: discovered
            ? PowerMeta.choiceDescription(Number(entry.type))
            : "Eat this fruit in-game to unlock its data."
    }
}
