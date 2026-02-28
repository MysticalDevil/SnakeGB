.pragma library

const _catalog = {
    menu: {
        "Original DMG": {cardPrimary:"#d7e7b2",cardSecondary:"#c7d99d",actionCard:"#4e7a39",hintCard:"#92b65a",borderPrimary:"#39582a",borderSecondary:"#577d3e",titleInk:"#213319",secondaryInk:"#253a1b",actionInk:"#f2f8e4",hintInk:"#1d2d15"},
        "Pocket B&W": {cardPrimary:"#e3e5dd",cardSecondary:"#d4d8cc",actionCard:"#5a6250",hintCard:"#b8bead",borderPrimary:"#4f5648",borderSecondary:"#646b5b",titleInk:"#1d211b",secondaryInk:"#242822",actionInk:"#edf1e8",hintInk:"#22261f"},
        "Sunset Glow": {cardPrimary:"#f5cf5d",cardSecondary:"#e9bf45",actionCard:"#825118",hintCard:"#c89030",borderPrimary:"#6d4412",borderSecondary:"#89591b",titleInk:"#2a1a06",secondaryInk:"#342109",actionInk:"#fff4c5",hintInk:"#2d1d0a"},
        "Pixel Heat": {cardPrimary:"#d44f4f",cardSecondary:"#c53f3f",actionCard:"#4e1111",hintCard:"#7a2626",borderPrimary:"#6c2424",borderSecondary:"#8f3939",titleInk:"#2b0a0a",secondaryInk:"#320d0d",actionInk:"#ffe7df",hintInk:"#f9e3dc"},
        "Neon Ice": {cardPrimary:"#78d9df",cardSecondary:"#67c1c8",actionCard:"#1e5f68",hintCard:"#327f87",borderPrimary:"#184c53",borderSecondary:"#2c747b",titleInk:"#08272d",secondaryInk:"#0d3138",actionInk:"#dcfbff",hintInk:"#e6fcff"}
    },
    pages: {
        catalog: {},
        achievements: {}
    },
    shells: {
        "Matte Silver": {shellBase:"#c0c0c0",shellBorder:"#7e8288",shellHighlight:"#f2f4f6",shellShade:"#adb1b8",brandInk:"#50545d",subtitleInk:"#747a84",bezelBase:"#3f4652",bezelEdge:"#21262d",bezelInner:"#12161d",bezelInnerBorder:"#5d6470",labelInk:"#9097a5",grillInk:"#4c515b",wheelTrackA:"#2b3a48",wheelTrackB:"#22303d",wheelBody:"#657284",wheelBodyDark:"#4a5567",wheelBodyLight:"#78859b"},
        "Cloud White": {shellBase:"#f0f0f0",shellBorder:"#a6acb6",shellHighlight:"#ffffff",shellShade:"#e2e4e8",brandInk:"#535862",subtitleInk:"#777d86",bezelBase:"#414854",bezelEdge:"#21262d",bezelInner:"#11151c",bezelInnerBorder:"#5f6671",labelInk:"#8f97a5",grillInk:"#5a5f69",wheelTrackA:"#314151",wheelTrackB:"#263543",wheelBody:"#6d7990",wheelBodyDark:"#515d72",wheelBodyLight:"#8592ab"},
        "Lavender": {shellBase:"#9370db",shellBorder:"#5d4790",shellHighlight:"#b69ae8",shellShade:"#7d5fc2",brandInk:"#2c1f45",subtitleInk:"#453463",bezelBase:"#3e4350",bezelEdge:"#1f242b",bezelInner:"#111419",bezelInnerBorder:"#5a6270",labelInk:"#8f95a2",grillInk:"#393d47",wheelTrackA:"#293848",wheelTrackB:"#243241",wheelBody:"#667286",wheelBodyDark:"#4b5668",wheelBodyLight:"#808ba0"},
        "Crimson": {shellBase:"#ff0000",shellBorder:"#8a2020",shellHighlight:"#ff5a5a",shellShade:"#d72828",brandInk:"#3a0909",subtitleInk:"#5a1313",bezelBase:"#404651",bezelEdge:"#22272d",bezelInner:"#12161b",bezelInnerBorder:"#5e646f",labelInk:"#9196a1",grillInk:"#3f434a",wheelTrackA:"#2c3b49",wheelTrackB:"#263443",wheelBody:"#687488",wheelBodyDark:"#4d586a",wheelBodyLight:"#828ea5"},
        "Teal": {shellBase:"#008080",shellBorder:"#0d5a5f",shellHighlight:"#22a2a2",shellShade:"#0b6e73",brandInk:"#093639",subtitleInk:"#155054",bezelBase:"#3c4350",bezelEdge:"#1f252d",bezelInner:"#10151b",bezelInnerBorder:"#59616f",labelInk:"#8f97a4",grillInk:"#29474d",wheelTrackA:"#253542",wheelTrackB:"#1f2d38",wheelBody:"#5e6b7f",wheelBodyDark:"#475466",wheelBodyLight:"#748199"},
        "Sunburst": {shellBase:"#ffd700",shellBorder:"#9f7f16",shellHighlight:"#ffe870",shellShade:"#e3be1f",brandInk:"#4a3907",subtitleInk:"#6f5a0d",bezelBase:"#424850",bezelEdge:"#24272d",bezelInner:"#13161a",bezelInnerBorder:"#61666f",labelInk:"#9197a1",grillInk:"#5d4d13",wheelTrackA:"#36434f",wheelTrackB:"#2e3b47",wheelBody:"#738095",wheelBodyDark:"#566276",wheelBodyLight:"#8a97ae"},
        "Graphite": {shellBase:"#2f4f4f",shellBorder:"#1d2f30",shellHighlight:"#4a6b6b",shellShade:"#284444",brandInk:"#101919",subtitleInk:"#1a2a2a",bezelBase:"#4a4f56",bezelEdge:"#292d33",bezelInner:"#14181c",bezelInnerBorder:"#676d75",labelInk:"#9aa0a8",grillInk:"#172324",wheelTrackA:"#3b4652",wheelTrackB:"#333e4a",wheelBody:"#7a8598",wheelBodyDark:"#5d6778",wheelBodyLight:"#939db2"}
    }
};

const menuColor = (paletteName, role, fallback) => {
    const table = _catalog.menu[paletteName];
    if (table && Object.prototype.hasOwnProperty.call(table, role)) return table[role];
    if (fallback !== undefined) return fallback;
    return _catalog.menu["Original DMG"][role] || "#cadc9f";
};

const pageTheme = (paletteName, page) => {
    const base = {
        pageBg: menuColor(paletteName, "cardPrimary"),
        title: menuColor(paletteName, "titleInk"),
        divider: menuColor(paletteName, "borderPrimary"),
        cardNormal: menuColor(paletteName, "hintCard"),
        cardSelected: menuColor(paletteName, "actionCard"),
        cardBorder: menuColor(paletteName, "borderPrimary"),
        primaryText: menuColor(paletteName, "titleInk"),
        secondaryText: menuColor(paletteName, "secondaryInk"),
        iconStroke: menuColor(paletteName, "titleInk"),
        iconFill: menuColor(paletteName, "cardPrimary"),
        unknownText: menuColor(paletteName, "secondaryInk"),
        badgeFill: menuColor(paletteName, "actionCard"),
        badgeText: menuColor(paletteName, "actionInk"),
        scrollbarHandle: menuColor(paletteName, "borderPrimary"),
        scrollbarTrack: menuColor(paletteName, "hintCard")
    };

    const overrides = _catalog.pages[page] ? _catalog.pages[page][paletteName] : undefined;
    if (!overrides) return base;

    for (const key of Object.keys(overrides)) {
        base[key] = overrides[key];
    }
    return base;
};

const pageColor = (paletteName, page, role, fallback) => {
    const t = pageTheme(paletteName, page);
    if (Object.prototype.hasOwnProperty.call(t, role)) return t[role];
    return fallback;
};

const _hexToRgb = (value) => {
    const hex = String(value || "").replace("#", "");
    if (hex.length !== 6) return {r: 0, g: 0, b: 0};
    return {
        r: parseInt(hex.slice(0, 2), 16),
        g: parseInt(hex.slice(2, 4), 16),
        b: parseInt(hex.slice(4, 6), 16)
    };
};

const _rgbToHex = (rgb) => {
    const ch = (n) => {
        const v = Math.max(0, Math.min(255, Math.round(n)));
        const s = v.toString(16);
        return s.length === 1 ? `0${s}` : s;
    };
    return `#${ch(rgb.r)}${ch(rgb.g)}${ch(rgb.b)}`;
};

const _mix = (a, b, amount) => {
    const t = Math.max(0, Math.min(1, amount));
    return {
        r: (a.r * (1 - t)) + (b.r * t),
        g: (a.g * (1 - t)) + (b.g * t),
        b: (a.b * (1 - t)) + (b.b * t)
    };
};

const _linearize = (channel) => {
    const s = channel / 255;
    return s <= 0.04045 ? (s / 12.92) : Math.pow((s + 0.055) / 1.055, 2.4);
};

const _luminance = (value) => {
    const rgb = _hexToRgb(value);
    const r = _linearize(rgb.r);
    const g = _linearize(rgb.g);
    const b = _linearize(rgb.b);
    return (0.2126 * r) + (0.7152 * g) + (0.0722 * b);
};

const _contrast = (fg, bg) => {
    const l1 = _luminance(fg);
    const l2 = _luminance(bg);
    const hi = Math.max(l1, l2);
    const lo = Math.min(l1, l2);
    return (hi + 0.05) / (lo + 0.05);
};

const _readableInk = (background, darkInk, lightInk) => {
    return _contrast(darkInk, background) >= _contrast(lightInk, background) ? darkInk : lightInk;
};

const _ensureContrast = (candidate, background, minimum, darkInk, lightInk) => {
    if (candidate && _contrast(candidate, background) >= minimum) return candidate;
    return _readableInk(background, darkInk, lightInk);
};

const _softenInk = (ink, background, amount, minimum, darkInk, lightInk) => {
    const mixed = _rgbToHex(_mix(_hexToRgb(ink), _hexToRgb(background), amount));
    return _ensureContrast(mixed, background, minimum, darkInk, lightInk);
};

const shellTheme = (shellName, shellColor) => {
    const t = _catalog.shells[shellName];
    const base = shellColor || "#4aa3a8";
    const theme = t ? Object.assign({}, t) : {
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
    };

    const shellPrimaryInk = _ensureContrast(theme.brandInk, theme.shellBase, 4.6, "#1b1724", "#f4f1fb");
    const shellSecondaryInk = _softenInk(shellPrimaryInk, theme.shellBase, 0.24, 3.4, shellPrimaryInk, "#ece8f5");
    const buttonLabelInk = _ensureContrast(shellPrimaryInk, theme.shellBase, 5.0, "#16131d", "#faf7ff");
    const bezelLabelInk = _ensureContrast(theme.labelInk, theme.bezelBase, 4.3, "#121820", "#dce4ee");
    const logoAccent = _ensureContrast("#4f477b", theme.shellBase, 3.2, shellPrimaryInk, "#6f63a6");
    const logoSecondary = _softenInk(logoAccent, theme.shellBase, 0.42, 2.7, shellPrimaryInk, "#8377ba");

    theme.brandInk = shellPrimaryInk;
    theme.subtitleInk = shellSecondaryInk;
    theme.buttonLabelInk = buttonLabelInk;
    theme.labelInk = bezelLabelInk;
    theme.logoAccent = logoAccent;
    theme.logoSecondary = logoSecondary;
    return theme;
};

const powerAccent = (paletteName, type, fallback) => {
    if (type === 6) return menuColor(paletteName, "actionInk", fallback);        // Double
    if (type === 7) return menuColor(paletteName, "hintCard", fallback);         // Diamond
    if (type === 8) return menuColor(paletteName, "borderSecondary", fallback);  // Laser
    if (type === 4) return menuColor(paletteName, "secondaryInk", fallback);     // Shield
    if (type === 5) return menuColor(paletteName, "borderPrimary", fallback);    // Portal
    return menuColor(paletteName, "titleInk", fallback);                          // Common
};

const rarityAccent = (paletteName, tier, fallback) => {
    if (tier === 4) return menuColor(paletteName, "hintCard", fallback);
    if (tier === 3) return menuColor(paletteName, "borderPrimary", fallback);
    if (tier === 2) return menuColor(paletteName, "secondaryInk", fallback);
    return menuColor(paletteName, "titleInk", fallback);
};
