.pragma library

function luminance(colorValue) {
    return 0.299 * colorValue.r + 0.587 * colorValue.g + 0.114 * colorValue.b
}

function readableText(bgColor, darkInk, lightInk) {
    return luminance(bgColor) > 0.54 ? darkInk : lightInk
}

function readableMutedText(bgColor, darkInk, lightInk) {
    const ink = readableText(bgColor, darkInk, lightInk)
    return Qt.rgba(ink.r, ink.g, ink.b, 0.9)
}

function readableSecondaryText(bgColor, darkInk, lightInk) {
    const ink = readableText(bgColor, darkInk, lightInk)
    return Qt.rgba(ink.r, ink.g, ink.b, 0.78)
}
