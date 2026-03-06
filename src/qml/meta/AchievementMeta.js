.pragma library

const _achievements = [
    { id: "Gold Medal (50 Pts)", short: "GOLD", hint: "Score 50 points", glyphKey: "gold_medal" },
    { id: "Silver Medal (20 Pts)", short: "SILVER", hint: "Score 20 points", glyphKey: "silver_medal" },
    { id: "Centurion (100 Crashes)", short: "CENT", hint: "Crash 100 times", glyphKey: "centurion" },
    { id: "Gourmet (500 Food)", short: "GOURMET", hint: "Eat 500 food", glyphKey: "gourmet" },
    { id: "Untouchable", short: "UNTOUCH", hint: "Finish without taking damage", glyphKey: "untouchable" },
    { id: "Speed Demon", short: "SPEED", hint: "Reach a top speed clear", glyphKey: "speed_demon" },
    { id: "Pacifist (60s No Food)", short: "PACIFIST", hint: "Stay alive for 60s without food", glyphKey: "pacifist" }
]

function all() {
    return _achievements.slice()
}

function ids() {
    return _achievements.map((entry) => entry.id)
}

function lookup(id) {
    for (let i = 0; i < _achievements.length; ++i) {
        if (_achievements[i].id === id) {
            return _achievements[i]
        }
    }
    return null
}

function shortLabel(id) {
    const entry = lookup(id)
    return entry ? entry.short : ""
}

function hint(id) {
    const entry = lookup(id)
    return entry ? entry.hint : ""
}
