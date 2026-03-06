.pragma library

const _achievements = [
    { id: "gold_medal", title: "Gold Medal", short: "GOLD", hint: "Reach 50 points", glyphKey: "gold_medal" },
    { id: "silver_medal", title: "Silver Medal", short: "SILVER", hint: "Reach 20 points", glyphKey: "silver_medal" },
    { id: "speed_demon", title: "Speed Demon", short: "SPEED", hint: "Hit the top speed tier", glyphKey: "speed_demon" },
    { id: "centurion", title: "Centurion", short: "CENT", hint: "Crash 100 times", glyphKey: "centurion" },
    { id: "gourmet", title: "GOURMET", short: "GOURMET", hint: "Eat 500 food", glyphKey: "gourmet" },
    { id: "pacifist", title: "Pacifist", short: "PACIFIST", hint: "Stay alive 60s without food", glyphKey: "pacifist" },
    { id: "last_stand", title: "Last Stand", short: "LAST", hint: "Survive 20s after shield breaks", glyphKey: "last_stand" },
    { id: "collector", title: "Collector", short: "COLLECT", hint: "Collect 4 different powers in one run", glyphKey: "collector" },
    { id: "power_chain", title: "Power Chain", short: "CHAIN", hint: "Trigger 3 different power effects in one run", glyphKey: "power_chain" },
    { id: "minimalist", title: "Minimalist", short: "MINI", hint: "Score 25 without any special fruit", glyphKey: "minimalist" },
    { id: "steady_nerves", title: "Steady Nerves", short: "STEADY", hint: "Hold high speed for 30s", glyphKey: "steady_nerves" },
    { id: "phase_walker", title: "Phase Walker", short: "PHASE", hint: "Use Ghost or Portal to slip through danger", glyphKey: "phase_walker" }
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

function title(id) {
    const entry = lookup(id)
    return entry ? entry.title : ""
}
