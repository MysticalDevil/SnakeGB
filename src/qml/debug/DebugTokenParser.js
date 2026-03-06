.pragma library

const debugStateTokens = {
    DBG_GAMEOVER: { state: "GameOver", osd: "DBG: GAMEOVER" },
    DBG_REPLAY: { state: "Replaying", osd: "DBG: REPLAY" },
    DBG_CATALOG: { state: "Library", osd: "DBG: CATALOG" },
    DBG_ACHIEVEMENTS: { state: "MedalRoom", osd: "DBG: ACHIEVEMENTS" }
}

const staticSceneAliases = {
    DBG_STATIC_BOOT: "boot",
    DBG_STATIC_GAME: "game",
    DBG_STATIC_REPLAY: "replay",
    DBG_STATIC_CHOICE: "choice",
    DBG_STATIC_OSD: "osd_text",
    DBG_STATIC_VOL: "osd_volume",
    DBG_STATIC_OFF: "",
    STATIC_BOOT: "boot",
    STATIC_GAME: "game",
    STATIC_REPLAY: "replay",
    STATIC_CHOICE: "choice",
    STATIC_OSD: "osd_text",
    STATIC_VOL: "osd_volume",
    STATIC_OFF: ""
}

const injectedActionTokens = {
    UP: "NavUp", U: "NavUp",
    DOWN: "NavDown", D: "NavDown",
    LEFT: "NavLeft", L: "NavLeft",
    RIGHT: "NavRight", R: "NavRight",
    A: "Primary", PRIMARY: "Primary", OK: "Primary",
    B: "Secondary", SECONDARY: "Secondary",
    START: "Start", SELECT: "SelectShort", BACK: "Back",
    ESC: "Escape", ESCAPE: "Escape",
    F6: "ToggleIconLab", ICON: "ToggleIconLab",
    COLOR: "ToggleShellColor", SHELL: "ToggleShellColor",
    MUSIC: "ToggleMusic", BOTMODE: "ToggleBot",
    BOTSTRAT: "ToggleBotStrategy", BOTPANEL: "ToggleBotPanel"
}

function parseBoundedInt(value, min, max) {
    const parsed = Number(value)
    if (!Number.isInteger(parsed) || parsed < min || (max !== undefined && parsed > max)) {
        return null
    }
    return parsed
}

function decodeLabel(value) {
    return String(value || "").replace(/\+/g, " ").replace(/_/g, " ")
}

function parseChoiceTypes(value) {
    return String(value || "")
        .split(/[|/]/)
        .map((entry) => Number(entry.trim()))
        .filter((entry) => Number.isInteger(entry) && entry >= 1 && entry <= 12)
        .slice(0, 3)
}

function parseProgress(value) {
    const progress = Number(value)
    if (Number.isNaN(progress)) {
        return null
    }
    return progress > 1 ? progress / 100.0 : progress
}

function parsePointList(value) {
    return String(value || "")
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
    return String(value || "")
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
            if (!Number.isInteger(x) || !Number.isInteger(y) || !Number.isInteger(type) || type < 1 || type > 12) {
                return null
            }
            return { x, y, type }
        })
        .filter((entry) => !!entry)
}

function parseInjectedTypeList(rawValue) {
    if (String(rawValue || "").trim().toUpperCase() === "ALL") {
        return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    }
    return String(rawValue || "")
        .split(/[,|/]/)
        .map((part) => Number(part.trim()))
        .filter((value) => Number.isInteger(value) && value >= 1 && value <= 12)
}

function parseAchievementIdList(rawValue, medalIds) {
    const normalized = String(rawValue || "").trim()
    if (normalized.toUpperCase() === "ALL") {
        return medalIds.slice()
    }
    return normalized
        .split(/[|/]/)
        .map((part) => part.trim().replace(/\+/g, " ").replace(/_/g, " "))
        .filter((part) => medalIds.indexOf(part) !== -1)
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
            const buffType = parseBoundedInt(value, 1, 12)
            if (buffType !== null) options.buffType = buffType
        } else if (key === "SCORE") {
            const score = parseBoundedInt(value, 0)
            if (score !== null) options.score = score
        } else if (key === "HI") {
            const highScore = parseBoundedInt(value, 0)
            if (highScore !== null) options.highScore = highScore
        } else if (key === "REMAIN") {
            const remaining = parseBoundedInt(value, 0)
            if (remaining !== null) options.buffRemaining = remaining
        } else if (key === "TOTAL") {
            const total = parseBoundedInt(value, 1)
            if (total !== null) options.buffTotal = total
        } else if (key === "INDEX") {
            const choiceIndex = parseBoundedInt(value, 0)
            if (choiceIndex !== null) options.choiceIndex = choiceIndex
        } else if (key === "TYPES" || key === "CHOICES") {
            options.choiceTypes = parseChoiceTypes(value)
        } else if (key === "TITLE") {
            if (sceneName === "boot") options.bootTitle = decodeLabel(value)
            if (sceneName === "choice") options.choiceTitle = decodeLabel(value)
        } else if (key === "SUBTITLE") {
            if (sceneName === "boot") options.bootSubtitle = decodeLabel(value)
            if (sceneName === "choice") options.choiceSubtitle = decodeLabel(value)
        } else if (key === "LOAD" || key === "LOADLABEL") {
            options.bootLoadLabel = decodeLabel(value)
        } else if (key === "PROGRESS" || key === "LOADPROGRESS") {
            const progress = parseProgress(value)
            if (progress !== null) options.bootLoadProgress = progress
        } else if (key === "FOOTER" || key === "FOOTERHINT") {
            options.choiceFooterHint = decodeLabel(value)
        } else if (key === "OSD" || key === "OSDTEXT") {
            options.osdText = decodeLabel(value)
        } else if (key === "VOLUME") {
            const volume = parseProgress(value)
            if (volume !== null) options.osdVolume = volume
        } else if (key === "SNAKE") {
            options.snakeSegments = parsePointList(value)
        } else if (key === "FOOD") {
            options.foodCells = parsePointList(value).map((cell) => ({ x: cell.x, y: cell.y }))
        } else if (key === "OBSTACLES") {
            options.obstacleCells = parsePointList(value).map((cell) => ({ x: cell.x, y: cell.y }))
        } else if (key === "POWERUPS") {
            options.powerupCells = parsePowerupList(value)
        }
    }
    if (sceneName === "choice") {
        if (!options.choiceTypes || options.choiceTypes.length === 0) {
            options.choiceTypes = bareValues.filter((entry) => Number.isInteger(entry) && entry >= 1 && entry <= 12).slice(0, 3)
        }
    } else if (bareValues.length > 0) {
        const buffType = bareValues[0]
        if (buffType >= 1 && buffType <= 12) {
            options.buffType = buffType
        }
    }
    return options
}

function parseToken(rawToken, medalIds) {
    const token = String(rawToken || "").trim().toUpperCase()
    if (token.length === 0) {
        return { kind: "empty", token: token }
    }
    if (token === "DBG_BOT_PANEL") return { kind: "bot_panel", token: token }
    if (token === "DBG_BOT_MODE") return { kind: "bot_mode", token: token }
    if (token === "DBG_BOT_STRATEGY") return { kind: "bot_strategy", token: token }
    if (token === "DBG_BOT_RESET") return { kind: "bot_reset", token: token }
    if (token.startsWith("DBG_BOT_PARAM:")) {
        const payload = token.slice("DBG_BOT_PARAM:".length)
        const parts = payload.split(",").map((part) => part.trim()).filter((part) => part.length > 0)
        const params = []
        for (const part of parts) {
            const separator = part.indexOf("=")
            if (separator <= 0 || separator >= part.length - 1) continue
            const key = part.slice(0, separator).trim()
            const value = Number(part.slice(separator + 1).trim())
            if (Number.isInteger(value)) params.push({ key, value })
        }
        return { kind: "bot_param", token: token, params: params }
    }
    if (token.startsWith("DBG_CATALOG")) {
        const separatorIndex = token.indexOf(":")
        const payload = separatorIndex >= 0 ? token.slice(separatorIndex + 1) : ""
        return {
            kind: "catalog",
            token: token,
            discoveredTypes: separatorIndex >= 0 ? parseInjectedTypeList(payload) : [],
            discoverAllFruits: String(payload).trim().toUpperCase() === "ALL"
        }
    }
    if (token.startsWith("DBG_ACHIEVEMENTS")) {
        const separatorIndex = token.indexOf(":")
        const payload = separatorIndex >= 0 ? token.slice(separatorIndex + 1) : ""
        return {
            kind: "achievements",
            token: token,
            unlockedAchievementIds: separatorIndex >= 0 ? parseAchievementIdList(payload, medalIds) : [],
            unlockAllAchievements: String(payload).trim().toUpperCase() === "ALL"
        }
    }
    if (token.startsWith("DBG_CHOICE")) {
        const separatorIndex = token.indexOf(":")
        const choiceTypes = separatorIndex >= 0 && separatorIndex + 1 < token.length
            ? token.slice(separatorIndex + 1).split(",").map((part) => Number(part.trim())).filter((value) => Number.isInteger(value) && value >= 1 && value <= 12)
            : []
        return { kind: "choice", token: token, choiceTypes: choiceTypes }
    }
    if (token === "DBG_MENU") return { kind: "menu", token: token }
    if (token === "DBG_PLAY") return { kind: "play", token: token }
    if (token === "DBG_PAUSE") return { kind: "pause", token: token }
    if (token === "DBG_REPLAY_BUFF") return { kind: "replay_buff", token: token }
    if (token === "DBG_ICONS") return { kind: "icons", token: token }
    if (token in debugStateTokens) return { kind: "debug_state", token: token, entry: debugStateTokens[token] }
    if (token.startsWith("DBG_STATIC_")) {
        const separatorIndex = token.indexOf(":")
        const baseToken = separatorIndex >= 0 ? token.slice(0, separatorIndex) : token
        return {
            kind: "static_scene",
            token: token,
            sceneName: staticSceneAliases[baseToken],
            options: parseStaticSceneOptions(staticSceneAliases[baseToken], separatorIndex >= 0 ? token.slice(separatorIndex + 1) : "")
        }
    }
    if (token === "PALETTE" || token === "NEXT_PALETTE") return { kind: "palette", token: token }
    if (token in staticSceneAliases) return { kind: "static_scene", token: token, sceneName: staticSceneAliases[token], options: {} }
    if (token in injectedActionTokens) return { kind: "action", token: token, actionKey: injectedActionTokens[token] }
    return { kind: "unknown", token: token }
}
