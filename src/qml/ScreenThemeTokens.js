.pragma library

.import "ThemeCatalog.js" as ThemeCatalog

function menuColor(paletteName, role) {
    return ThemeCatalog.menuColor(paletteName, role)
}

function powerAccent(paletteName, type, fallbackInk) {
    return ThemeCatalog.powerAccent(paletteName, type, fallbackInk)
}

function rarityAccent(paletteName, tier, fallbackInk) {
    return ThemeCatalog.rarityAccent(paletteName, tier, fallbackInk)
}
