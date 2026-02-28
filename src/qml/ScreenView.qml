import QtQuick
import QtQuick.Controls
import SnakeGB 1.0
import "ThemeCatalog.js" as ThemeCatalog

Item {
    id: root
    property var gameLogic
    property color p0
    property color p1
    property color p2
    property color p3
    property string gameFont
    property real elapsed
    property bool iconDebugMode: false
    property string staticDebugScene: ""
    property int iconLabSelection: 0

    function buffName(type) {
        if (type === 1) return "GHOST"
        if (type === 2) return "SLOW"
        if (type === 3) return "MAGNET"
        if (type === 4) return "SHIELD"
        if (type === 5) return "PORTAL"
        if (type === 6) return "DOUBLE"
        if (type === 7) return "DIAMOND"
        if (type === 8) return "LASER"
        if (type === 9) return "MINI"
        return "NONE"
    }

    function powerGlyph(type) {
        if (type === 1) return "G"
        if (type === 2) return "S"
        if (type === 3) return "M"
        if (type === 4) return "H"
        if (type === 5) return "P"
        if (type === 6) return "2"
        if (type === 7) return "D"
        if (type === 8) return "L"
        if (type === 9) return "m"
        return "?"
    }

    function powerColor(type) {
        return ThemeCatalog.powerAccent(gameLogic.paletteName, type, gameInk)
    }

    function drawFoodSymbol(ctx, w, h) {
        ctx.clearRect(0, 0, w, h)
        ctx.fillStyle = gameFoodCore
        ctx.beginPath()
        ctx.arc(w * 0.50, h * 0.56, Math.max(2, w * 0.30), 0, Math.PI * 2)
        ctx.fill()
        ctx.fillStyle = Qt.rgba(gameFoodHighlight.r, gameFoodHighlight.g, gameFoodHighlight.b, 0.45)
        ctx.beginPath()
        ctx.arc(w * 0.40, h * 0.42, Math.max(1.2, w * 0.12), 0, Math.PI * 2)
        ctx.fill()
        ctx.fillStyle = gameFoodStem
        ctx.fillRect(w * 0.50, h * 0.12, Math.max(1, w * 0.08), Math.max(2, h * 0.22))
        ctx.fillStyle = gameFoodSpark
        ctx.fillRect(w * 0.64, h * 0.22, Math.max(1, w * 0.14), 1)
        ctx.fillRect(w * 0.22, h * 0.74, 1, 1)
        ctx.fillRect(w * 0.72, h * 0.70, 1, 1)
    }

    function drawPowerSymbol(ctx, w, h, type, accent) {
        ctx.clearRect(0, 0, w, h)
        ctx.lineWidth = Math.max(1, Math.floor(w * 0.12))
        ctx.strokeStyle = accent
        ctx.fillStyle = accent

        if (type === 1) { // Ghost
            ctx.strokeRect(2, 2, w - 4, h - 4)
            ctx.clearRect(Math.floor(w * 0.42), Math.floor(h * 0.30), Math.floor(w * 0.16), Math.floor(h * 0.44))
        } else if (type === 2) { // Slow
            ctx.beginPath()
            ctx.arc(w / 2, h / 2, w * 0.34, 0, Math.PI * 2)
            ctx.stroke()
            ctx.fillRect(w * 0.26, h * 0.46, w * 0.48, Math.max(1, h * 0.1))
        } else if (type === 3) { // Magnet
            ctx.beginPath()
            ctx.moveTo(w * 0.25, h * 0.20)
            ctx.lineTo(w * 0.25, h * 0.70)
            ctx.quadraticCurveTo(w * 0.50, h * 0.92, w * 0.75, h * 0.70)
            ctx.lineTo(w * 0.75, h * 0.20)
            ctx.stroke()
        } else if (type === 4) { // Shield
            ctx.beginPath()
            ctx.moveTo(w * 0.50, h * 0.12)
            ctx.lineTo(w * 0.80, h * 0.28)
            ctx.lineTo(w * 0.72, h * 0.72)
            ctx.lineTo(w * 0.50, h * 0.90)
            ctx.lineTo(w * 0.28, h * 0.72)
            ctx.lineTo(w * 0.20, h * 0.28)
            ctx.closePath()
            ctx.stroke()
        } else if (type === 5) { // Portal
            ctx.beginPath()
            ctx.arc(w / 2, h / 2, w * 0.34, 0, Math.PI * 2)
            ctx.stroke()
            ctx.beginPath()
            ctx.arc(w * 0.68, h * 0.34, w * 0.08, 0, Math.PI * 2)
            ctx.fill()
        } else if (type === 6) { // Double
            ctx.save()
            ctx.translate(w * 0.38, h * 0.52)
            ctx.rotate(Math.PI / 4)
            ctx.strokeRect(-w * 0.12, -h * 0.12, w * 0.24, h * 0.24)
            ctx.restore()
            ctx.save()
            ctx.translate(w * 0.62, h * 0.48)
            ctx.rotate(Math.PI / 4)
            ctx.strokeRect(-w * 0.12, -h * 0.12, w * 0.24, h * 0.24)
            ctx.restore()
        } else if (type === 7) { // Diamond
            ctx.save()
            ctx.translate(w / 2, h / 2)
            ctx.rotate(Math.PI / 4)
            ctx.strokeRect(-w * 0.20, -h * 0.20, w * 0.40, h * 0.40)
            ctx.restore()
            ctx.fillRect(w * 0.48, h * 0.05, 1, h * 0.18)
            ctx.fillRect(w * 0.41, h * 0.12, w * 0.14, 1)
        } else if (type === 8) { // Laser
            ctx.beginPath()
            ctx.moveTo(w * 0.26, h * 0.22)
            ctx.lineTo(w * 0.55, h * 0.22)
            ctx.lineTo(w * 0.42, h * 0.52)
            ctx.lineTo(w * 0.70, h * 0.52)
            ctx.lineTo(w * 0.34, h * 0.85)
            ctx.lineTo(w * 0.46, h * 0.60)
            ctx.lineTo(w * 0.24, h * 0.60)
            ctx.closePath()
            ctx.fill()
        } else if (type === 9) { // Mini
            ctx.strokeRect(w * 0.30, h * 0.30, w * 0.40, h * 0.40)
            ctx.fillRect(w * 0.16, h * 0.16, w * 0.10, 1)
            ctx.fillRect(w * 0.16, h * 0.16, 1, h * 0.10)
            ctx.fillRect(w * 0.74, h * 0.74, w * 0.10, 1)
            ctx.fillRect(w * 0.84, h * 0.74, 1, h * 0.10)
        }
    }

    function iconLabMove(dx, dy) {
        const cols = 3
        const idx = iconLabSelection
        const col = idx % cols
        const row = Math.floor(idx / cols)
        const nextCol = Math.max(0, Math.min(cols - 1, col + (dx > 0 ? 1 : (dx < 0 ? -1 : 0))))
        const nextRow = Math.max(0, Math.min(2, row + (dy > 0 ? 1 : (dy < 0 ? -1 : 0))))
        iconLabSelection = nextRow * cols + nextCol
    }

    function choiceGlyph(type) {
        if (type === 1) return "G"
        if (type === 2) return "S"
        if (type === 3) return "M"
        if (type === 4) return "H"
        if (type === 5) return "P"
        if (type === 6) return "2x"
        if (type === 7) return "3x"
        if (type === 8) return "L"
        if (type === 9) return "m"
        return "?"
    }

    function rarityTier(type) {
        if (type === 7) return 4 // Diamond
        if (type === 6 || type === 8) return 3 // Double / Laser
        if (type === 4 || type === 5) return 2 // Shield / Portal
        return 1 // Ghost / Slow / Magnet / Mini
    }

    function rarityName(type) {
        const tier = rarityTier(type)
        if (tier === 4) return "EPIC"
        if (tier === 3) return "RARE"
        if (tier === 2) return "UNCOMMON"
        return "COMMON"
    }

    function rarityColor(type) {
        const tier = rarityTier(type)
        return ThemeCatalog.rarityAccent(gameLogic.paletteName, tier, menuColor("actionInk"))
    }

    function luminance(colorValue) {
        return 0.299 * colorValue.r + 0.587 * colorValue.g + 0.114 * colorValue.b
    }

    function readableText(bgColor) {
        const darkInk = menuColor("titleInk")
        const lightInk = menuColor("actionInk")
        return luminance(bgColor) > 0.54 ? darkInk : lightInk
    }

    function readableMutedText(bgColor) {
        const c = readableText(bgColor)
        return Qt.rgba(c.r, c.g, c.b, 0.9)
    }

    function readableSecondaryText(bgColor) {
        const c = readableText(bgColor)
        return Qt.rgba(c.r, c.g, c.b, 0.78)
    }

    function menuColor(role) {
        return ThemeCatalog.menuColor(gameLogic.paletteName, role)
    }

    readonly property color gameBg: menuColor("cardPrimary")
    // Lift play/replay/choice background so it matches menu brightness after LCD shader.
    readonly property color playBg: gameBg
    readonly property color gamePanel: menuColor("cardSecondary")
    readonly property color gameInk: menuColor("titleInk")
    readonly property color gameSubInk: menuColor("secondaryInk")
    readonly property color gameAccent: menuColor("actionCard")
    readonly property color gameAccentInk: menuColor("actionInk")
    readonly property color gameBorder: menuColor("borderPrimary")
    readonly property color gameGrid: Qt.rgba(menuColor("borderSecondary").r, menuColor("borderSecondary").g, menuColor("borderSecondary").b, 0.012)
    readonly property color gameFoodCore: menuColor("actionCard")
    readonly property color gameFoodHighlight: menuColor("cardPrimary")
    readonly property color gameFoodStem: menuColor("borderPrimary")
    readonly property color gameFoodSpark: menuColor("secondaryInk")

    width: 240
    height: 216

    Rectangle {
        id: screenContainer
        anchors.fill: parent
        color: "black"
        clip: true

        Item {
            id: gameContent
            anchors.fill: parent

            Rectangle {
                anchors.fill: parent
                color: gameBg
                z: -3
            }

            Item {
                id: sceneBase
                anchors.fill: parent
                z: -2
                visible: root.staticDebugScene === "" &&
                         gameLogic.state >= AppState.Playing &&
                         gameLogic.state <= AppState.ChoiceSelection

                Rectangle {
                    anchors.fill: parent
                    color: playBg
                }

                Canvas {
                    anchors.fill: parent
                    onPaint: {
                        const ctx = getContext("2d")
                        ctx.reset()
                        const cw = width / Math.max(1, gameLogic.boardWidth)
                        const ch = height / Math.max(1, gameLogic.boardHeight)
                        ctx.strokeStyle = root.gameGrid
                        ctx.lineWidth = 1
                        for (let x = 0; x <= width; x += cw) {
                            ctx.beginPath()
                            ctx.moveTo(x + 0.5, 0)
                            ctx.lineTo(x + 0.5, height)
                            ctx.stroke()
                        }
                        for (let y = 0; y <= height; y += ch) {
                            ctx.beginPath()
                            ctx.moveTo(0, y + 0.5)
                            ctx.lineTo(width, y + 0.5)
                            ctx.stroke()
                        }
                    }
                    Component.onCompleted: requestPaint()
                    onVisibleChanged: if (visible) requestPaint()
                }
            }

            // --- STATE 0: SPLASH ---
            SplashLayer {
                anchors.fill: parent
                active: gameLogic.state === AppState.Splash
                gameFont: root.gameFont
                menuColor: root.menuColor
            }

            // --- STATE 1: MENU ---
            MenuLayer {
                anchors.fill: parent
                active: gameLogic.state === AppState.StartMenu
                gameFont: root.gameFont
                elapsed: root.elapsed
                menuColor: root.menuColor
                gameLogic: root.gameLogic
            }

            // --- STATE 2, 3, 4, 5, 6: WORLD ---
            WorldLayer {
                active: gameLogic.state >= AppState.Playing && gameLogic.state <= AppState.ChoiceSelection
                gameLogic: root.gameLogic
                elapsed: root.elapsed
                gameFont: root.gameFont
                menuColor: root.menuColor
                gameBg: root.playBg
                gamePanel: root.gamePanel
                gameInk: root.gameInk
                gameSubInk: root.gameSubInk
                gameBorder: root.gameBorder
                drawFoodSymbol: root.drawFoodSymbol
                drawPowerSymbol: root.drawPowerSymbol
                powerColor: root.powerColor
                buffName: root.buffName
                rarityTier: root.rarityTier
                rarityName: root.rarityName
                rarityColor: root.rarityColor
                readableText: root.readableText
            }

            LibraryLayer {
                anchors.fill: parent
                active: gameLogic.state === AppState.Library
                gameLogic: root.gameLogic
                gameFont: root.gameFont
                powerColor: root.powerColor
                menuColor: root.menuColor
                pageTheme: ThemeCatalog.pageTheme(gameLogic.paletteName, "catalog")
            }

            // --- STATE 8: MEDAL ROOM ---
            MedalRoom {
                id: medalRoom
                p0: root.p0
                p1: root.p1
                p2: root.p2
                p3: root.p3
                menuColor: root.menuColor
                pageTheme: ThemeCatalog.pageTheme(gameLogic.paletteName, "achievements")
                gameLogic: root.gameLogic
                gameFont: root.gameFont
                visible: gameLogic.state === AppState.MedalRoom
                z: 900
            }

            StaticDebugLayer {
                anchors.fill: parent
                visible: root.staticDebugScene !== ""
                staticScene: root.staticDebugScene
                gameLogic: root.gameLogic
                gameFont: root.gameFont
                menuColor: root.menuColor
                playBg: root.playBg
                gameGrid: root.gameGrid
                gameInk: root.gameInk
                gameSubInk: root.gameSubInk
                gameBorder: root.gameBorder
                drawFoodSymbol: root.drawFoodSymbol
                buffName: root.buffName
                rarityTier: root.rarityTier
                rarityName: root.rarityName
                rarityColor: root.rarityColor
                readableText: root.readableText
            }

            IconLabLayer {
                anchors.fill: parent
                active: root.iconDebugMode
                gameFont: root.gameFont
                menuColor: root.menuColor
                elapsed: root.elapsed
                iconLabSelection: root.iconLabSelection
                drawFoodSymbol: root.drawFoodSymbol
                drawPowerSymbol: root.drawPowerSymbol
                powerColor: root.powerColor
                buffName: root.buffName
                rarityName: root.rarityName
                powerGlyph: root.powerGlyph
                onResetSelectionRequested: root.iconLabSelection = 0
            }

            HudLayer {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 6
                anchors.rightMargin: 6
                z: 2400
                active: !root.iconDebugMode &&
                        root.staticDebugScene === "" &&
                        (gameLogic.state === AppState.Playing || gameLogic.state === AppState.Replaying)
                gameLogic: root.gameLogic
                gameFont: root.gameFont
                ink: root.gameInk
            }

            OverlayLayer {
                anchors.fill: parent
                z: 2600
                showPausedAndGameOver: false
                showReplayAndChoice: !root.iconDebugMode && root.staticDebugScene === ""
                gameLogic: root.gameLogic
                menuColor: root.menuColor
                gameFont: root.gameFont
                elapsed: root.elapsed
                drawPowerSymbol: root.drawPowerSymbol
                rarityTier: root.rarityTier
                rarityName: root.rarityName
                rarityColor: root.rarityColor
                readableText: root.readableText
                readableSecondaryText: root.readableSecondaryText
            }
        }

        // --- 2. FX layer ---
        ShaderEffect {
            id: lcdShader
            anchors.fill: parent
            z: 20
            property variant source: ShaderEffectSource { sourceItem: gameContent; hideSource: true; live: true }
            property variant history: ShaderEffectSource { sourceItem: lcdShader; live: true; recursive: true }
            property real time: root.elapsed
            property real reflectionX: gameLogic.reflectionOffset.x
            property real reflectionY: gameLogic.reflectionOffset.y
            property bool isPlayScene: gameLogic.state === AppState.Playing || root.staticDebugScene === "game"
            property bool isReplayScene: gameLogic.state === AppState.Replaying || root.staticDebugScene === "replay"
            property bool isChoiceScene: gameLogic.state === AppState.ChoiceSelection
            property real lumaBoost: isPlayScene ? 0.95
                                   : (isReplayScene ? 0.985
                                      : (isChoiceScene ? 1.0 : 1.0))
            property real ghostMix: isPlayScene ? 0.12
                                   : (isReplayScene ? 0.07
                                      : (isChoiceScene ? 0.02 : 0.25))
            property real scanlineStrength: isPlayScene ? 0.045
                                           : (isReplayScene ? 0.028
                                              : (isChoiceScene ? 0.008 : 0.03))
            property real gridStrength: isPlayScene ? 0.07
                                       : (isReplayScene ? 0.045
                                          : (isChoiceScene ? 0.015 : 0.08))
            property real vignetteStrength: isPlayScene ? 0.14
                                           : (isReplayScene ? 0.10
                                              : (isChoiceScene ? 0.08 : 0.15))
            fragmentShader: "qrc:/shaders/src/qml/lcd.frag.qsb"
        }

        OverlayLayer {
            anchors.fill: parent
            z: 30
            showPausedAndGameOver: !root.iconDebugMode && root.staticDebugScene === ""
            showReplayAndChoice: false
            gameLogic: root.gameLogic
            menuColor: root.menuColor
            gameFont: root.gameFont
            elapsed: root.elapsed
            drawPowerSymbol: root.drawPowerSymbol
            rarityTier: root.rarityTier
            rarityName: root.rarityName
            rarityColor: root.rarityColor
            readableText: root.readableText
            readableSecondaryText: root.readableSecondaryText
        }

        Item {
            id: crtLayer
            anchors.fill: parent
            z: 10000
            opacity: 0.06
            Canvas {
                anchors.fill: parent
                onPaint: { 
                    const ctx = getContext("2d")
                    ctx.strokeStyle = Qt.rgba(root.gameBorder.r, root.gameBorder.g, root.gameBorder.b, 0.35)
                    ctx.lineWidth = 1
                    let i = 0
                    while (i < height) {
                        ctx.beginPath(); ctx.moveTo(0, i); ctx.lineTo(width, i); ctx.stroke()
                        i = i + 3
                    }
                }
            }
        }

        OSDLayer { id: osd; bg: root.gameAccent; ink: root.gameAccentInk; gameFont: root.gameFont; z: 11000 }
    }

    function showOSD(t) { osd.show(t) }
    function triggerPowerCycle() { gameLogic.dispatchUiAction("state_splash") }
}
