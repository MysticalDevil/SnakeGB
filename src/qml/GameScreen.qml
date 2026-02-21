import QtQuick
import QtQuick.Controls
import "ThemeCatalog.js" as ThemeCatalog

Item {
    id: root
    property color p0
    property color p1
    property color p2
    property color p3
    property string gameFont
    property real elapsed
    property bool iconDebugMode: false
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
        if (type === 6) return "#ffd700"
        if (type === 7) return "#7ee7ff"
        if (type === 8) return "#ff6666"
        if (type === 4) return "#8aff8a"
        if (type === 5) return "#b78bff"
        return p3
    }

    function drawFoodSymbol(ctx, w, h) {
        ctx.clearRect(0, 0, w, h)
        ctx.fillStyle = p3
        ctx.beginPath()
        ctx.arc(w * 0.50, h * 0.56, Math.max(2, w * 0.30), 0, Math.PI * 2)
        ctx.fill()
        ctx.fillStyle = Qt.rgba(p0.r, p0.g, p0.b, 0.45)
        ctx.beginPath()
        ctx.arc(w * 0.40, h * 0.42, Math.max(1.2, w * 0.12), 0, Math.PI * 2)
        ctx.fill()
        ctx.fillStyle = p2
        ctx.fillRect(w * 0.50, h * 0.12, Math.max(1, w * 0.08), Math.max(2, h * 0.22))
        ctx.fillStyle = p1
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
        var cols = 3
        var idx = iconLabSelection
        var col = idx % cols
        var row = Math.floor(idx / cols)
        var nextCol = Math.max(0, Math.min(cols - 1, col + (dx > 0 ? 1 : (dx < 0 ? -1 : 0))))
        var nextRow = Math.max(0, Math.min(2, row + (dy > 0 ? 1 : (dy < 0 ? -1 : 0))))
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
        var tier = rarityTier(type)
        if (tier === 4) return "EPIC"
        if (tier === 3) return "RARE"
        if (tier === 2) return "UNCOMMON"
        return "COMMON"
    }

    function rarityColor(type) {
        var tier = rarityTier(type)
        if (tier === 4) return "#7ee7ff"
        if (tier === 3) return "#ffd700"
        if (tier === 2) return "#9ef58a"
        return p3
    }

    function luminance(colorValue) {
        return 0.299 * colorValue.r + 0.587 * colorValue.g + 0.114 * colorValue.b
    }

    function readableText(bgColor) {
        return luminance(bgColor) > 0.54 ? p0 : p3
    }

    function readableMutedText(bgColor) {
        var c = readableText(bgColor)
        return Qt.rgba(c.r, c.g, c.b, 0.9)
    }

    function readableSecondaryText(bgColor) {
        var c = readableText(bgColor)
        return Qt.rgba(c.r, c.g, c.b, 0.78)
    }

    function blendColor(a, b, t) {
        var k = Math.max(0.0, Math.min(1.0, t))
        return Qt.rgba(
            a.r * (1.0 - k) + b.r * k,
            a.g * (1.0 - k) + b.g * k,
            a.b * (1.0 - k) + b.b * k,
            1.0
        )
    }

    function tonedColor(c, amount) {
        var l = luminance(c)
        var gray = Qt.rgba(l, l, l, 1.0)
        return blendColor(c, gray, amount)
    }

    function clampedSurface(a, b, mix, desat, minL, maxL) {
        var c = tonedColor(blendColor(a, b, mix), desat)
        var l = luminance(c)
        if (l < minL) {
            c = blendColor(c, Qt.rgba(1, 1, 1, 1), Math.min(1.0, (minL - l) * 1.4))
        } else if (l > maxL) {
            c = blendColor(c, Qt.rgba(0, 0, 0, 1), Math.min(1.0, (l - maxL) * 1.4))
        }
        return c
    }

    function menuColor(role) {
        if (role === "cardPrimary") return ThemeCatalog.menuColor(gameLogic.paletteName, role, clampedSurface(p0, p1, 0.78, 0.28, 0.52, 0.80))
        if (role === "cardSecondary") return ThemeCatalog.menuColor(gameLogic.paletteName, role, clampedSurface(p0, p1, 0.64, 0.24, 0.46, 0.76))
        if (role === "actionCard") return ThemeCatalog.menuColor(gameLogic.paletteName, role, clampedSurface(p2, p3, 0.58, 0.22, 0.30, 0.52))
        if (role === "hintCard") return ThemeCatalog.menuColor(gameLogic.paletteName, role, clampedSurface(p1, p2, 0.40, 0.30, 0.34, 0.60))
        if (role === "borderPrimary") return ThemeCatalog.menuColor(gameLogic.paletteName, role, blendColor(p2, p3, 0.55))
        if (role === "borderSecondary") return ThemeCatalog.menuColor(gameLogic.paletteName, role, blendColor(p2, p3, 0.35))
        if (role === "titleInk" || role === "secondaryInk") {
            return ThemeCatalog.menuColor(gameLogic.paletteName, role, readableText(menuColor("cardPrimary")))
        }
        if (role === "actionInk") return ThemeCatalog.menuColor(gameLogic.paletteName, role, readableText(menuColor("actionCard")))
        if (role === "hintInk") return ThemeCatalog.menuColor(gameLogic.paletteName, role, readableText(menuColor("hintCard")))
        return ThemeCatalog.menuColor(gameLogic.paletteName, role, p3)
    }

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
                color: p0
                z: -1 
            }

            // --- STATE 0: SPLASH ---
            Rectangle {
                id: splashLayer
                anchors.fill: parent
                color: p0
                visible: gameLogic.state === 0
                z: 1000
                property real logoY: -56
                property int fakeLoad: 0

                onVisibleChanged: {
                    if (visible) {
                        logoY = -56
                        fakeLoad = 0
                        dropAnim.restart()
                        loadTimer.start()
                    } else {
                        dropAnim.stop()
                        loadTimer.stop()
                    }
                }

                SequentialAnimation {
                    id: dropAnim
                    running: splashLayer.visible
                    NumberAnimation { target: splashLayer; property: "logoY"; to: 82; duration: 480; easing.type: Easing.OutQuad }
                    NumberAnimation { target: splashLayer; property: "logoY"; to: 90; duration: 80; easing.type: Easing.OutQuad }
                    NumberAnimation { target: splashLayer; property: "logoY"; to: 76; duration: 95; easing.type: Easing.OutQuad }
                    NumberAnimation { target: splashLayer; property: "logoY"; to: 82; duration: 85; easing.type: Easing.OutQuad }
                }

                Timer {
                    id: loadTimer
                    interval: 75
                    repeat: true
                    running: splashLayer.visible
                    onTriggered: {
                        if (splashLayer.fakeLoad < 100) {
                            splashLayer.fakeLoad += 5
                        } else {
                            stop()
                        }
                    }
                }

                Text {
                    id: bootText
                    text: "S N A K E"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: gameFont
                    font.pixelSize: 32
                    color: p3
                    font.bold: true
                    y: splashLayer.logoY
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 156
                    width: 120
                    height: 8
                    color: p1
                    border.color: p3
                    border.width: 1
                    Rectangle {
                        x: 1
                        y: 1
                        width: (parent.width - 2) * (splashLayer.fakeLoad / 100.0)
                        height: parent.height - 2
                        color: p3
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 170
                    text: "LOADING " + splashLayer.fakeLoad + "%"
                    font.family: gameFont
                    font.pixelSize: 8
                    color: p3
                    opacity: 0.92
                }
            }

            // --- STATE 1: MENU ---
            Rectangle {
                id: menuLayer
                anchors.fill: parent
                color: p0
                visible: gameLogic.state === 1
                z: 500
                readonly property color cardPrimary: root.menuColor("cardPrimary")
                readonly property color cardSecondary: root.menuColor("cardSecondary")
                readonly property color actionCard: root.menuColor("actionCard")
                readonly property color hintCard: root.menuColor("hintCard")
                readonly property color borderPrimary: root.menuColor("borderPrimary")
                readonly property color borderSecondary: root.menuColor("borderSecondary")
                readonly property color titleInk: root.menuColor("titleInk")
                readonly property color secondaryInk: root.menuColor("secondaryInk")
                readonly property color actionInk: root.menuColor("actionInk")
                readonly property color hintInk: root.menuColor("hintInk")

                Column {
                    width: parent.width - 24
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 7

                    Rectangle {
                        width: parent.width
                        height: 44
                        radius: 4
                        color: menuLayer.cardPrimary
                        border.color: menuLayer.borderPrimary
                        border.width: 1

                        Column {
                            anchors.centerIn: parent
                            spacing: 1
                            Text {
                                text: "S N A K E"
                                font.family: gameFont
                                font.pixelSize: 24
                                color: menuLayer.titleInk
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: gameLogic.hasSave ? "CONTINUE READY" : "NEW RUN READY"
                                font.family: gameFont
                                font.pixelSize: 7
                                color: Qt.rgba(menuLayer.titleInk.r, menuLayer.titleInk.g, menuLayer.titleInk.b, 0.68)
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 30
                        radius: 3
                        color: menuLayer.cardSecondary
                        border.color: menuLayer.borderSecondary
                        border.width: 1

                        Row {
                            anchors.centerIn: parent
                            spacing: 16
                            Text {
                                text: "HI " + gameLogic.highScore
                                font.family: gameFont
                                font.pixelSize: 11
                                font.bold: true
                                color: menuLayer.secondaryInk
                            }
                            Text {
                                text: "LEVEL " + gameLogic.currentLevelName
                                font.family: gameFont
                                font.pixelSize: 11
                                font.bold: true
                                color: menuLayer.secondaryInk
                            }
                        }
                    }

                    Item {
                        width: parent.width
                        height: 34
                        Rectangle {
                            anchors.centerIn: parent
                            width: 170
                            height: 30
                            radius: 3
                            color: menuLayer.actionCard
                            border.color: Qt.rgba(menuLayer.actionInk.r, menuLayer.actionInk.g, menuLayer.actionInk.b, 0.74)
                            border.width: 1
                            Text {
                                text: gameLogic.hasSave ? "START  CONTINUE" : "START  NEW GAME"
                                color: menuLayer.actionInk
                                font.pixelSize: 11
                                font.bold: true
                                anchors.centerIn: parent
                                opacity: (Math.floor(elapsed * 4) % 2 === 0) ? 1.0 : 0.86
                            }
                        }
                    }

                    Item { width: 1; height: 3 }

                    Rectangle {
                        width: parent.width - 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: 36
                        radius: 4
                        color: menuLayer.hintCard
                        border.color: menuLayer.borderSecondary
                        border.width: 1

                        Column {
                            anchors.fill: parent
                            anchors.margins: 7
                            spacing: 1
                            Text {
                                text: "UP: MEDALS   DOWN: REPLAY"
                                color: Qt.rgba(menuLayer.hintInk.r, menuLayer.hintInk.g, menuLayer.hintInk.b, 0.93)
                                font.pixelSize: 8
                                font.bold: true
                            }
                            Text {
                                text: "LEFT: CATALOG   SELECT: LEVEL"
                                color: Qt.rgba(menuLayer.hintInk.r, menuLayer.hintInk.g, menuLayer.hintInk.b, 0.93)
                                font.pixelSize: 8
                                font.bold: true
                            }
                        }
                    }
                }
            }

            // --- STATE 2, 3, 4, 5, 6: WORLD ---
            Item {
                id: gameWorld
                anchors.fill: parent
                z: 10
                visible: gameLogic.state >= 2 && gameLogic.state <= 6
                readonly property real cellW: width / gameLogic.boardWidth
                readonly property real cellH: height / gameLogic.boardHeight

                Canvas {
                    id: boardGrid
                    anchors.fill: parent
                    z: 1
                    visible: gameWorld.visible
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        var cw = width / gameLogic.boardWidth
                        var ch = height / gameLogic.boardHeight
                        ctx.strokeStyle = Qt.rgba(root.p2.r, root.p2.g, root.p2.b, 0.22)
                        ctx.lineWidth = 1
                        var x = 0
                        while (x <= width) {
                            ctx.beginPath()
                            ctx.moveTo(x + 0.5, 0)
                            ctx.lineTo(x + 0.5, height)
                            ctx.stroke()
                            x += cw
                        }
                        var y = 0
                        while (y <= height) {
                            ctx.beginPath()
                            ctx.moveTo(0, y + 0.5)
                            ctx.lineTo(width, y + 0.5)
                            ctx.stroke()
                            y += ch
                        }
                    }
                    Component.onCompleted: requestPaint()
                    onVisibleChanged: if (visible) requestPaint()
                }
                
                Repeater {
                    model: gameLogic.ghost
                    visible: gameLogic.state === 2
                    delegate: Rectangle {
                        x: modelData.x * gameWorld.cellW
                        y: modelData.y * gameWorld.cellH
                        width: gameWorld.cellW
                        height: gameWorld.cellH
                        color: p3
                        opacity: 0.2
                    }
                }

                Repeater {
                    model: gameLogic.snakeModel
                    delegate: Rectangle {
                        x: model.pos.x * gameWorld.cellW
                        y: model.pos.y * gameWorld.cellH
                        width: gameWorld.cellW
                        height: gameWorld.cellH
                        color: gameLogic.activeBuff === 6 ? (Math.floor(elapsed * 10) % 2 === 0 ? "#ffd700" : p3) : (index === 0 ? p3 : p2)
                        radius: index === 0 ? 2 : 0
                        Rectangle { anchors.fill: parent; anchors.margins: -2; border.color: "#00ffff"; border.width: 1; radius: parent.radius + 2; visible: index === 0 && gameLogic.shieldActive }
                    }
                }

                Repeater {
                    model: gameLogic.obstacles
                    delegate: Rectangle {
                        x: modelData.x * gameWorld.cellW
                        y: modelData.y * gameWorld.cellH
                        width: gameWorld.cellW
                        height: gameWorld.cellH
                        color: gameLogic.currentLevelName === "Dynamic Pulse" || gameLogic.currentLevelName === "Crossfire" || gameLogic.currentLevelName === "Shifting Box"
                               ? ((Math.floor(elapsed * 8) % 2 === 0) ? p3 : p2)
                               : p2
                        border.color: p3
                        border.width: 1
                        z: 12
                    }
                }
                
                Item {
                    x: gameLogic.food.x * gameWorld.cellW
                    y: gameLogic.food.y * gameWorld.cellH
                    width: gameWorld.cellW
                    height: gameWorld.cellH
                    z: 20

                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            root.drawFoodSymbol(ctx, width, height)
                        }
                        Component.onCompleted: requestPaint()
                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()
                    }
                }

                // PowerUp Icon
                Item {
                    visible: gameLogic.powerUpPos.x !== -1
                    x: gameLogic.powerUpPos.x * gameWorld.cellW
                    y: gameLogic.powerUpPos.y * gameWorld.cellH
                    width: gameWorld.cellW
                    height: gameWorld.cellH
                    z: 30

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width + 2
                        height: parent.height + 2
                        radius: width / 2
                        color: "transparent"
                        border.color: p3
                        border.width: 1
                        opacity: 0.75
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width - 1
                        height: parent.height - 1
                        radius: 2
                        color: Qt.rgba(p0.r, p0.g, p0.b, 0.78)
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width + 6
                        height: parent.height + 6
                        radius: width / 2
                        color: "transparent"
                        border.color: p3
                        border.width: 1
                        opacity: (Math.floor(elapsed * 8) % 2 === 0) ? 0.45 : 0.1
                    }

                    Canvas {
                        id: worldPowerIcon
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            root.drawPowerSymbol(ctx, width, height, gameLogic.powerUpType, powerColor(gameLogic.powerUpType))
                        }
                        Component.onCompleted: requestPaint()
                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()
                        Connections {
                            target: gameLogic
                            function onPowerUpChanged() { worldPowerIcon.requestPaint() }
                        }
                    }
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: 4
                    anchors.leftMargin: 4
                    width: 110
                    height: 24
                    property int buffTier: rarityTier(gameLogic.activeBuff)
                    property color accent: rarityColor(gameLogic.activeBuff)
                    color: gameLogic.activeBuff === 7
                           ? Qt.rgba(0.10, 0.20, 0.24, 0.92)
                           : Qt.rgba(p1.r, p1.g, p1.b, 0.95)
                    border.color: accent
                    border.width: 1
                    z: 40
                    visible: (gameLogic.state === 2 || gameLogic.state === 5) &&
                             gameLogic.activeBuff !== 0 && gameLogic.buffTicksTotal > 0

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 4
                        anchors.top: parent.top
                        anchors.topMargin: 1
                        text: buffName(gameLogic.activeBuff)
                        color: parent.accent
                        font.family: gameFont
                        font.pixelSize: 7
                        font.bold: true
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 4
                        anchors.top: parent.top
                        anchors.topMargin: 1
                        text: rarityName(gameLogic.activeBuff)
                        color: parent.accent
                        font.family: gameFont
                        font.pixelSize: 7
                        font.bold: true
                        opacity: 0.96
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 3
                        anchors.rightMargin: 3
                        anchors.bottomMargin: 3
                        height: 5
                        color: p0
                        border.color: parent.accent
                        border.width: 1

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: parent.width * (gameLogic.buffTicksRemaining / Math.max(1, gameLogic.buffTicksTotal))
                            color: parent.parent.accent
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.color: parent.parent.accent
                            border.width: 1
                            opacity: parent.parent.buffTier >= 3
                                     ? ((Math.floor(elapsed * 8) % 2 === 0) ? 0.35 : 0.1)
                                     : 0.0
                        }
                    }
                }
            }

            // --- STATE 3: PAUSED ---
            Rectangle {
                id: pausedLayer
                anchors.fill: parent
                color: Qt.rgba(p0.r, p0.g, p0.b, 0.7)
                visible: gameLogic.state === 3
                z: 600
                Column {
                    anchors.centerIn: parent
                    spacing: 6
                    Text { text: "PAUSED"; font.family: gameFont; font.pixelSize: 20; color: p3; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: "START: RESUME   B: MENU"; color: p3; font.family: gameFont; font.pixelSize: 8; anchors.horizontalCenter: parent.horizontalCenter }
                }
            }

            // --- STATE 4: GAME OVER ---
            Rectangle {
                id: gameOverLayer
                anchors.fill: parent
                color: Qt.rgba(p3.r, p3.g, p3.b, 0.95)
                visible: gameLogic.state === 4
                z: 700
                Column {
                    anchors.centerIn: parent
                    spacing: 10
                    Text { text: "GAME OVER"; color: p0; font.family: gameFont; font.pixelSize: 24; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: "SCORE: " + gameLogic.score; color: p0; font.family: gameFont; font.pixelSize: 14; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: "START: RESTART   B: MENU"; color: p0; font.family: gameFont; font.pixelSize: 8; anchors.horizontalCenter: parent.horizontalCenter }
                }
            }

            // --- STATE 5: REPLAYING (Overlay) ---
            Rectangle {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: 100
                height: 20
                color: p3
                visible: gameLogic.state === 5
                z: 600
                Text { text: "REPLAY"; color: p0; anchors.centerIn: parent; font.bold: true }
            }

            // --- STATE 6: CHOICE SELECTION ---
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(p0.r, p0.g, p0.b, 0.95)
                visible: gameLogic.state === 6
                z: 650
                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    width: parent.width - 40
                    Text { text: "LEVEL UP!"; color: p3; font.pixelSize: 18; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    Repeater {
                        model: gameLogic.choices
                        delegate: Rectangle {
                            id: choiceCard
                            width: parent.width
                            height: 46
                            property int powerType: Number(modelData.type)
                            property color accent: rarityColor(powerType)
                            color: gameLogic.choiceIndex === index
                                   ? Qt.rgba(p2.r, p2.g, p2.b, 0.98)
                                   : Qt.rgba(p1.r, p1.g, p1.b, 0.95)
                            border.color: accent
                            border.width: gameLogic.choiceIndex === index ? 2 : 1
                            Row {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 8
                                Rectangle {
                                    width: 28
                                    height: 28
                                    radius: 6
                                    color: p0
                                    border.color: parent.parent.accent
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter

                                    Item {
                                        id: choiceIcon
                                        anchors.centerIn: parent
                                        width: 22
                                        height: 22
                                        property color accent: choiceCard.accent
                                        Canvas {
                                            anchors.fill: parent
                                            onPaint: {
                                                var ctx = getContext("2d")
                                                ctx.reset()
                                                root.drawPowerSymbol(ctx, width, height, powerType, choiceIcon.accent)
                                            }
                                            Component.onCompleted: requestPaint()
                                            onWidthChanged: requestPaint()
                                            onHeightChanged: requestPaint()
                                        }
                                    }
                                }
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 44
                                    Text { text: modelData.name; color: root.readableText(choiceCard.color); font.bold: true; font.pixelSize: 9 }
                                    Text { text: modelData.desc; color: root.readableSecondaryText(choiceCard.color); font.pixelSize: 7; opacity: 1.0; width: parent.width; wrapMode: Text.WordWrap }
                                }
                            }

                            Rectangle {
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.rightMargin: 4
                                anchors.topMargin: 3
                                height: 10
                                width: 44
                                radius: 3
                                color: Qt.rgba(p0.r, p0.g, p0.b, 0.85)
                                border.color: parent.accent
                                border.width: 1
                                Text {
                                    anchors.centerIn: parent
                                    text: rarityName(choiceCard.powerType)
                                    color: choiceCard.accent
                                    font.family: gameFont
                                    font.pixelSize: 7
                                    font.bold: true
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: parent.accent
                                border.width: 1
                                opacity: rarityTier(parent.powerType) >= 3
                                         ? ((Math.floor(elapsed * 6) % 2 === 0) ? 0.35 : 0.08)
                                         : 0.0
                            }
                        }
                    }
                }
            }

            // --- STATE 7: LIBRARY ---
            Rectangle {
                anchors.fill: parent
                readonly property var catalogTheme: ThemeCatalog.pageTheme(gameLogic.paletteName, "catalog")
                color: catalogTheme.pageBg
                visible: gameLogic.state === 7
                z: 800
                Column {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    Text { text: "CATALOG"; color: parent.parent.catalogTheme.title; font.family: gameFont; font.pixelSize: 20; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    ListView {
                        id: libraryList
                        readonly property var catalogTheme: parent.parent.catalogTheme
                        width: parent.width
                        height: parent.height - 60
                        model: gameLogic.fruitLibrary
                        property bool syncingFromLogic: false
                        currentIndex: -1
                        spacing: 6
                        clip: true
                        interactive: true
                        boundsBehavior: Flickable.StopAtBounds
                        Component.onCompleted: {
                            syncingFromLogic = true
                            currentIndex = gameLogic.libraryIndex
                            syncingFromLogic = false
                        }
                        onCurrentIndexChanged: {
                            if (syncingFromLogic) {
                                return
                            }
                            positionViewAtIndex(currentIndex, ListView.Contain)
                            if (currentIndex !== gameLogic.libraryIndex) {
                                gameLogic.setLibraryIndex(currentIndex)
                            }
                        }
                        Connections {
                            target: gameLogic
                            function onLibraryIndexChanged() {
                                if (libraryList.currentIndex !== gameLogic.libraryIndex) {
                                    libraryList.syncingFromLogic = true
                                    libraryList.currentIndex = gameLogic.libraryIndex
                                    libraryList.syncingFromLogic = false
                                    libraryList.positionViewAtIndex(libraryList.currentIndex, ListView.Contain)
                                }
                            }
                        }
                        WheelHandler {
                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                            onWheel: (event) => {
                                libraryList.contentY = Math.max(0, Math.min(
                                    libraryList.contentHeight - libraryList.height,
                                    libraryList.contentY - event.angleDelta.y
                                ))
                            }
                        }
                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                            width: 6
                            contentItem: Rectangle {
                                implicitWidth: 6
                                radius: 3
                                color: parent.parent.catalogTheme.scrollbarHandle
                            }
                            background: Rectangle {
                                radius: 3
                                color: parent.parent.catalogTheme.scrollbarTrack
                                opacity: 0.35
                            }
                        }
                        delegate: Rectangle {
                            id: libraryCard
                            width: parent.width
                            height: 46
                            color: libraryList.currentIndex === index ? libraryList.catalogTheme.cardSelected : libraryList.catalogTheme.cardNormal
                            border.color: libraryList.catalogTheme.cardBorder
                            border.width: libraryList.currentIndex === index ? 2 : 1
                            readonly property bool selected: libraryList.currentIndex === index
                            readonly property color labelColor: selected ? libraryList.catalogTheme.badgeText : libraryList.catalogTheme.primaryText
                            readonly property color descColor: selected
                                                               ? Qt.rgba(libraryList.catalogTheme.badgeText.r, libraryList.catalogTheme.badgeText.g, libraryList.catalogTheme.badgeText.b, 0.86)
                                                               : libraryList.catalogTheme.secondaryText
                            Row {
                                anchors.fill: parent
                                anchors.margins: 5
                                spacing: 12
                                Item {
                                    width: 24
                                    height: 24
                                    anchors.verticalCenter: parent.verticalCenter
                                    Item {
                                        anchors.centerIn: parent
                                        width: 20
                                        height: 20
                                        Rectangle { anchors.fill: parent; color: "transparent"; border.color: libraryList.catalogTheme.iconStroke; border.width: 1; visible: modelData.discovered && modelData.type === 1 }
                                        Rectangle { anchors.fill: parent; radius: 10; color: "transparent"; border.color: libraryList.catalogTheme.iconStroke; border.width: 2; visible: modelData.discovered && modelData.type === 2
                                            Rectangle { width: 10; height: 2; color: libraryList.catalogTheme.iconStroke; anchors.centerIn: parent }
                                        }
                                        Rectangle { anchors.fill: parent; color: libraryList.catalogTheme.iconStroke; visible: modelData.discovered && modelData.type === 3; clip: true
                                            Rectangle { width: 20; height: 20; rotation: 45; y: 10; color: libraryList.catalogTheme.iconFill }
                                        }
                                        Rectangle { anchors.fill: parent; radius: 10; color: "transparent"; border.color: libraryList.catalogTheme.iconStroke; border.width: 2; visible: modelData.discovered && modelData.type === 4 }
                                        Rectangle { anchors.fill: parent; radius: 10; color: "transparent"; border.color: libraryList.catalogTheme.iconStroke; border.width: 1; visible: modelData.discovered && modelData.type === 5
                                            Rectangle { anchors.centerIn: parent; width: 10; height: 10; radius: 5; border.color: libraryList.catalogTheme.iconStroke; border.width: 1 }
                                        }
                                        Rectangle { anchors.centerIn: parent; width: 16; height: 16; rotation: 45; color: "#ffd700"; visible: modelData.discovered && modelData.type === 6 }
                                        Rectangle { anchors.centerIn: parent; width: 16; height: 16; rotation: 45; color: "#00ffff"; visible: modelData.discovered && modelData.type === 7 }
                                        Rectangle { anchors.fill: parent; color: "transparent"; border.color: "#ff0000"; border.width: 2; visible: modelData.discovered && modelData.type === 8 }
                                        Rectangle { anchors.fill: parent; color: "transparent"; border.color: libraryList.catalogTheme.iconStroke; border.width: 1; visible: modelData.discovered && modelData.type === 9
                                            Rectangle { anchors.centerIn: parent; width: 4; height: 4; color: libraryList.catalogTheme.iconFill }
                                        }
                                        Text { text: "?"; color: libraryList.catalogTheme.unknownText; visible: !modelData.discovered; anchors.centerIn: parent; font.bold: true; font.pixelSize: 12 }
                                    }
                                }
                                Column {
                                    width: parent.width - 50
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text { text: modelData.name; color: libraryCard.labelColor; font.family: gameFont; font.pixelSize: 11; font.bold: true }
                                    Text { text: modelData.desc; color: libraryCard.descColor; font.family: gameFont; font.pixelSize: 9; opacity: 1.0; width: parent.width; wrapMode: Text.WordWrap }
                                }
                            }
                        }
                    }
                }
            }

            // --- STATE 8: MEDAL ROOM ---
            MedalRoom {
                id: medalRoom
                p0: root.p0
                p1: root.p1
                p2: root.p2
                p3: root.p3
                visualTheme: ThemeCatalog.pageTheme(gameLogic.paletteName, "achievements")
                gameFont: root.gameFont
                visible: gameLogic.state === 8
                z: 900
            }

            Rectangle {
                id: iconLabLayer
                visible: root.iconDebugMode
                anchors.fill: parent
                color: p0
                z: 1600
                readonly property int contentMargin: 8
                readonly property int contentSpacing: 4
                readonly property int headerHeight: 28
                readonly property int infoHeight: 32
                readonly property int footerHeight: 16
                onVisibleChanged: {
                    if (visible) {
                        iconLabSelection = 0
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 6
                    color: Qt.rgba(p1.r, p1.g, p1.b, 0.36)
                    border.color: p2
                    border.width: 1
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: iconLabLayer.contentMargin
                    spacing: iconLabLayer.contentSpacing

                    Rectangle {
                        width: parent.width
                        height: iconLabLayer.headerHeight
                        radius: 3
                        color: Qt.rgba(p1.r, p1.g, p1.b, 0.66)
                        border.color: p3
                        border.width: 1

                        Column {
                            anchors.centerIn: parent
                            spacing: 0
                            Text {
                                text: "ICON LAB"
                                color: p3
                                font.family: gameFont
                                font.pixelSize: 12
                                font.bold: true
                            }
                            Text {
                                text: "F6 / KONAMI TO EXIT"
                                color: Qt.rgba(p3.r, p3.g, p3.b, 0.82)
                                font.family: gameFont
                                font.pixelSize: 6
                                font.bold: true
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: iconLabLayer.contentSpacing
                        Rectangle {
                            width: 90
                            height: iconLabLayer.infoHeight
                            radius: 3
                            color: Qt.rgba(p1.r, p1.g, p1.b, 0.62)
                            border.color: p3
                            border.width: 1

                            Row {
                                anchors.centerIn: parent
                                spacing: 8
                                Rectangle {
                                    width: 20
                                    height: 20
                                    radius: 3
                                    color: Qt.rgba(p0.r, p0.g, p0.b, 0.72)
                                    border.color: p3
                                    border.width: 1
                                    Canvas {
                                        anchors.fill: parent
                                        onPaint: {
                                            var ctx = getContext("2d")
                                            ctx.reset()
                                            root.drawFoodSymbol(ctx, width, height)
                                        }
                                        Component.onCompleted: requestPaint()
                                        onWidthChanged: requestPaint()
                                        onHeightChanged: requestPaint()
                                    }
                                }
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text { text: "FOOD"; color: p3; font.family: gameFont; font.pixelSize: 7; font.bold: true }
                                    Text { text: "BASE"; color: Qt.rgba(p3.r, p3.g, p3.b, 0.82); font.family: gameFont; font.pixelSize: 6; font.bold: true }
                                }
                            }
                        }

                        Rectangle {
                            width: Math.max(64, parent.width - 90 - iconLabLayer.contentSpacing)
                            height: iconLabLayer.infoHeight
                            radius: 3
                            color: Qt.rgba(p1.r, p1.g, p1.b, 0.62)
                            border.color: p3
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: "POWERUP ICON SUITE"
                                color: p3
                                font.family: gameFont
                                font.pixelSize: 8
                                font.bold: true
                            }
                        }
                    }

                    Grid {
                        id: iconLabGrid
                        width: parent.width
                        height: parent.height - iconLabLayer.headerHeight - iconLabLayer.infoHeight
                                - iconLabLayer.footerHeight - (iconLabLayer.contentSpacing * 3)
                        columns: 3
                        columnSpacing: iconLabLayer.contentSpacing
                        rowSpacing: iconLabLayer.contentSpacing

                        Repeater {
                            model: [1,2,3,4,5,6,7,8,9]
                            delegate: Rectangle {
                                width: (iconLabGrid.width - (iconLabGrid.columnSpacing * 2)) / 3
                                height: (iconLabGrid.height - (iconLabGrid.rowSpacing * 2)) / 3
                                radius: 3
                                property int iconIdx: index
                                color: Qt.rgba(p1.r, p1.g, p1.b, 0.62)
                                border.color: powerColor(modelData)
                                border.width: root.iconLabSelection === iconIdx ? 2 : 1

                                Rectangle {
                                    anchors.fill: parent
                                    color: "transparent"
                                    border.color: Qt.rgba(p3.r, p3.g, p3.b, 0.9)
                                    border.width: 1
                                    visible: root.iconLabSelection === iconIdx
                                    opacity: (Math.floor(elapsed * 8) % 2 === 0) ? 0.9 : 0.5
                                }

                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.rightMargin: 3
                                    anchors.topMargin: 3
                                    width: 20
                                    height: 9
                                    radius: 2
                                    visible: root.iconLabSelection === iconIdx
                                    color: p3
                                    border.color: p0
                                    border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: "SEL"
                                        color: p0
                                        font.family: gameFont
                                        font.pixelSize: 6
                                        font.bold: true
                                    }
                                }

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    spacing: 4

                                    Rectangle {
                                        width: Math.max(16, parent.height - 10)
                                        height: width
                                        radius: 4
                                        color: Qt.rgba(p0.r, p0.g, p0.b, 0.72)
                                        border.color: p3
                                        border.width: 1
                                        anchors.verticalCenter: parent.verticalCenter

                                        Canvas {
                                            anchors.fill: parent
                                            onPaint: {
                                                var ctx = getContext("2d")
                                                ctx.reset()
                                                root.drawPowerSymbol(ctx, width, height, modelData, powerColor(modelData))
                                            }
                                            Component.onCompleted: requestPaint()
                                            onWidthChanged: requestPaint()
                                            onHeightChanged: requestPaint()
                                        }
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 0
                                        Text {
                                            text: buffName(modelData)
                                            color: p3
                                            font.family: gameFont
                                            font.pixelSize: 7
                                            font.bold: true
                                        }
                                        Text {
                                            text: rarityName(modelData)
                                            color: powerColor(modelData)
                                            font.family: gameFont
                                            font.pixelSize: 6
                                            font.bold: true
                                        }
                                        Text {
                                            text: "GLYPH " + powerGlyph(modelData)
                                            color: Qt.rgba(p3.r, p3.g, p3.b, 0.72)
                                            font.family: gameFont
                                            font.pixelSize: 6
                                            font.bold: true
                                            visible: parent.parent.height >= 42
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: iconLabLayer.footerHeight
                        radius: 3
                        color: Qt.rgba(p1.r, p1.g, p1.b, 0.62)
                        border.color: p3
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: "SELECTED: " + buffName(root.iconLabSelection + 1)
                            color: p3
                            font.family: gameFont
                            font.pixelSize: 7
                            font.bold: true
                        }
                    }
                }
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
            fragmentShader: "qrc:/shaders/src/qml/lcd.frag.qsb"
        }

        Item {
            id: crtLayer
            anchors.fill: parent
            z: 10000
            opacity: 0.1
            Canvas {
                anchors.fill: parent
                onPaint: { 
                    var ctx = getContext("2d")
                    ctx.strokeStyle = Qt.rgba(root.p0.r, root.p0.g, root.p0.b, 0.65)
                    ctx.lineWidth = 1
                    var i = 0
                    while (i < height) {
                        ctx.beginPath(); ctx.moveTo(0, i); ctx.lineTo(width, i); ctx.stroke()
                        i = i + 3
                    }
                }
            }
        }

        // --- 3. HUD ---
        Column {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 10
            z: 500
            visible: gameLogic.state >= 2 && gameLogic.state <= 6
            Text { text: "HI " + gameLogic.highScore; color: p3; font.family: gameFont; font.pixelSize: 8; anchors.right: parent.right }
            Text { text: "SC " + gameLogic.score; color: p3; font.family: gameFont; font.pixelSize: 12; font.bold: true; anchors.right: parent.right }
        }
        
        OSDLayer { id: osd; p0: root.p0; p3: root.p3; gameFont: root.gameFont; z: 3000 }
    }

    function showOSD(t) { osd.show(t) }
    function triggerPowerCycle() { gameLogic.requestStateChange(0) }
}
