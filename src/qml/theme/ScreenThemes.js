.pragma library

.import "Palette.js" as Palette

function pageTheme(paletteName, page) {
    const base = {
        pageBg: Palette.menuColor(paletteName, "cardPrimary"),
        title: Palette.menuColor(paletteName, "titleInk"),
        divider: Palette.menuColor(paletteName, "borderPrimary"),
        cardNormal: Palette.menuColor(paletteName, "hintCard"),
        cardSelected: Palette.menuColor(paletteName, "actionCard"),
        cardBorder: Palette.menuColor(paletteName, "borderPrimary"),
        primaryText: Palette.menuColor(paletteName, "titleInk"),
        secondaryText: Palette.menuColor(paletteName, "secondaryInk"),
        iconStroke: Palette.menuColor(paletteName, "titleInk"),
        iconFill: Palette.menuColor(paletteName, "cardPrimary"),
        unknownText: Palette.menuColor(paletteName, "secondaryInk"),
        badgeFill: Palette.menuColor(paletteName, "actionCard"),
        badgeText: Palette.menuColor(paletteName, "actionInk"),
        scrollbarHandle: Palette.menuColor(paletteName, "borderPrimary"),
        scrollbarTrack: Palette.menuColor(paletteName, "hintCard")
    }
    const overrides = Palette.pageOverrides(page, paletteName)
    if (!overrides) {
        return base
    }
    for (const key of Object.keys(overrides)) {
        base[key] = overrides[key]
    }
    return base
}

function _hexToRgb(value) {
    const hex = String(value || "").replace("#", "")
    if (hex.length !== 6) {
        return { r: 0, g: 0, b: 0 }
    }
    return {
        r: parseInt(hex.slice(0, 2), 16),
        g: parseInt(hex.slice(2, 4), 16),
        b: parseInt(hex.slice(4, 6), 16)
    }
}

function _rgbToHex(rgb) {
    const ch = (n) => {
        const v = Math.max(0, Math.min(255, Math.round(n)))
        const s = v.toString(16)
        return s.length === 1 ? `0${s}` : s
    }
    return `#${ch(rgb.r)}${ch(rgb.g)}${ch(rgb.b)}`
}

function _mix(a, b, amount) {
    const t = Math.max(0, Math.min(1, amount))
    return {
        r: (a.r * (1 - t)) + (b.r * t),
        g: (a.g * (1 - t)) + (b.g * t),
        b: (a.b * (1 - t)) + (b.b * t)
    }
}

function _linearize(channel) {
    const s = channel / 255
    return s <= 0.04045 ? (s / 12.92) : Math.pow((s + 0.055) / 1.055, 2.4)
}

function _luminance(value) {
    const rgb = _hexToRgb(value)
    const r = _linearize(rgb.r)
    const g = _linearize(rgb.g)
    const b = _linearize(rgb.b)
    return (0.2126 * r) + (0.7152 * g) + (0.0722 * b)
}

function _contrast(fg, bg) {
    const l1 = _luminance(fg)
    const l2 = _luminance(bg)
    const hi = Math.max(l1, l2)
    const lo = Math.min(l1, l2)
    return (hi + 0.05) / (lo + 0.05)
}

function _readableInk(background, darkInk, lightInk) {
    return _contrast(darkInk, background) >= _contrast(lightInk, background) ? darkInk : lightInk
}

function _ensureContrast(candidate, background, minimum, darkInk, lightInk) {
    if (candidate && _contrast(candidate, background) >= minimum) {
        return candidate
    }
    return _readableInk(background, darkInk, lightInk)
}

function _softenInk(ink, background, amount, minimum, darkInk, lightInk) {
    const mixed = _rgbToHex(_mix(_hexToRgb(ink), _hexToRgb(background), amount))
    return _ensureContrast(mixed, background, minimum, darkInk, lightInk)
}

function shellTheme(shellName, shellColor) {
    const spec = Palette.shellSpec(shellName)
    const base = shellColor || "#4aa3a8"
    const theme = spec ? Object.assign({}, spec) : {
        shellBase: base,
        shellBorder: "#4b5a66",
        shellHighlight: "#6f7f8e",
        shellShade: "#465562",
        brandInk: "#1e2830",
        subtitleInk: "#2c3640",
        bezelBase: "#3f4652",
        bezelEdge: "#21262d",
        bezelInner: "#12161d",
        bezelInnerBorder: "#5d6470",
        labelInk: "#9097a5",
        grillInk: "#4c515b",
        wheelTrackA: "#2b3a48",
        wheelTrackB: "#22303d",
        wheelBody: "#657284",
        wheelBodyDark: "#4a5567",
        wheelBodyLight: "#78859b"
    }
    const shellPrimaryInk = _ensureContrast(theme.brandInk, theme.shellBase, 4.6, "#1b1724", "#f4f1fb")
    const shellSecondaryInk = _softenInk(shellPrimaryInk, theme.shellBase, 0.24, 3.4, shellPrimaryInk, "#ece8f5")
    const buttonLabelInk = _ensureContrast(shellPrimaryInk, theme.shellBase, 5.0, "#16131d", "#faf7ff")
    const bezelLabelInk = _ensureContrast(theme.labelInk, theme.bezelBase, 4.3, "#121820", "#dce4ee")
    const logoAccent = _ensureContrast("#4f477b", theme.shellBase, 3.2, shellPrimaryInk, "#6f63a6")
    const logoSecondary = _softenInk(logoAccent, theme.shellBase, 0.42, 2.7, shellPrimaryInk, "#8377ba")
    theme.brandInk = shellPrimaryInk
    theme.subtitleInk = shellSecondaryInk
    theme.buttonLabelInk = buttonLabelInk
    theme.labelInk = bezelLabelInk
    theme.logoAccent = logoAccent
    theme.logoSecondary = logoSecondary
    return theme
}
