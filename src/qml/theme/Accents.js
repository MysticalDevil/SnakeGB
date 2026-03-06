.pragma library

.import "Palette.js" as Palette

function powerAccent(paletteName, type, fallback) {
    if (type === 6) return Palette.menuColor(paletteName, "actionInk", fallback)
    if (type === 7) return Palette.menuColor(paletteName, "borderSecondary", fallback)
    if (type === 9) return Palette.menuColor(paletteName, "hintCard", fallback)
    if (type === 4) return Palette.menuColor(paletteName, "secondaryInk", fallback)
    if (type === 5) return Palette.menuColor(paletteName, "borderPrimary", fallback)
    return Palette.menuColor(paletteName, "titleInk", fallback)
}

function rarityAccent(paletteName, tier, fallback) {
    if (tier === 4) return Palette.menuColor(paletteName, "hintCard", fallback)
    if (tier === 3) return Palette.menuColor(paletteName, "borderPrimary", fallback)
    if (tier === 2) return Palette.menuColor(paletteName, "secondaryInk", fallback)
    return Palette.menuColor(paletteName, "titleInk", fallback)
}
