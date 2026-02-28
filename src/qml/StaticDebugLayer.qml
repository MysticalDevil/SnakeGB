import QtQuick

Rectangle {
    id: staticSceneLayer
    property string staticScene: ""
    property string gameFont: ""
    property var menuColor
    property int boardWidth: 24
    property int boardHeight: 18
    property color playBg: "black"
    property color gameGrid: "gray"
    property color gameInk: "white"
    property color gameSubInk: "gray"
    property color gameBorder: "gray"
    property var drawFoodSymbol
    property var buffName
    property var rarityTier
    property var rarityName
    property var rarityColor
    property var readableText

    anchors.fill: parent
    visible: staticScene !== ""
    color: (showGame || showReplay) ? playBg : menuColor("cardPrimary")
    clip: true

    readonly property bool showBoot: staticScene === "boot"
    readonly property bool showGame: staticScene === "game"
    readonly property bool showReplay: staticScene === "replay"
    readonly property color panelBg: menuColor("cardSecondary")
    readonly property color panelAccent: menuColor("actionCard")
    readonly property color panelBorder: menuColor("borderPrimary")
    readonly property color panelBorderSoft: menuColor("borderSecondary")
    readonly property color titleInk: menuColor("titleInk")
    readonly property color accentInk: menuColor("actionInk")
    readonly property color secondaryInk: menuColor("secondaryInk")
    readonly property color hintInk: menuColor("hintInk")
    readonly property int layerHud: 60
    readonly property int previewHighScore: 0
    readonly property int previewScore: showReplay ? 42 : 18
    readonly property int previewBuffType: showReplay ? 4 : 3
    readonly property int previewBuffRemaining: showReplay ? 104 : 136
    readonly property int previewBuffTotal: 180

    Rectangle {
        anchors.fill: parent
        anchors.margins: 6
        color: Qt.rgba(staticSceneLayer.panelBg.r, staticSceneLayer.panelBg.g, staticSceneLayer.panelBg.b, 0.18)
        border.color: staticSceneLayer.panelBorder
        border.width: 1
    }

    Rectangle {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 6
        width: parent.width - 12
        height: 24
        radius: 3
        color: Qt.rgba(staticSceneLayer.panelBg.r, staticSceneLayer.panelBg.g, staticSceneLayer.panelBg.b, 0.92)
        border.color: staticSceneLayer.panelBorder
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 0

            Text {
                text: staticSceneLayer.showBoot ? "STATIC DEBUG: BOOT"
                     : (staticSceneLayer.showGame ? "STATIC DEBUG: GAME" : "STATIC DEBUG: REPLAY")
                color: staticSceneLayer.titleInk
                font.family: gameFont
                font.pixelSize: 9
                font.bold: true
            }

            Text {
                text: "STATE SNAPSHOT"
                color: staticSceneLayer.secondaryInk
                font.family: gameFont
                font.pixelSize: 7
                font.bold: true
            }
        }
    }

    Item {
        anchors.fill: parent
        anchors.topMargin: 28
        visible: staticSceneLayer.showBoot

        Text {
            text: "S N A K E"
            anchors.horizontalCenter: parent.horizontalCenter
            y: 64
            font.family: gameFont
            font.pixelSize: 32
            color: staticSceneLayer.titleInk
            font.bold: true
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 112
            width: 154
            height: 24
            radius: 4
            color: Qt.rgba(staticSceneLayer.panelBg.r, staticSceneLayer.panelBg.g, staticSceneLayer.panelBg.b, 0.84)
            border.color: staticSceneLayer.panelBorder
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "MENU LANGUAGE PREVIEW"
                color: staticSceneLayer.secondaryInk
                font.family: gameFont
                font.pixelSize: 8
                font.bold: true
            }
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 148
            width: 132
            height: 10
            color: staticSceneLayer.panelBg
            border.color: staticSceneLayer.panelBorder
            border.width: 1

            Rectangle {
                x: 1
                y: 1
                width: (parent.width - 2) * 0.72
                height: parent.height - 2
                color: staticSceneLayer.panelAccent
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 164
            text: "LOADING 72%"
            font.family: gameFont
            font.pixelSize: 9
            color: staticSceneLayer.accentInk
            opacity: 0.92
        }
    }

    Item {
        anchors.fill: parent
        anchors.topMargin: 28
        visible: staticSceneLayer.showGame || staticSceneLayer.showReplay

        Canvas {
            anchors.fill: parent

            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                const cw = width / Math.max(1, staticSceneLayer.boardWidth)
                const ch = height / Math.max(1, staticSceneLayer.boardHeight)
                ctx.strokeStyle = staticSceneLayer.gameGrid
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
        }

        Rectangle { x: 88; y: 88; width: 10; height: 10; color: staticSceneLayer.gameSubInk }
        Rectangle { x: 98; y: 88; width: 10; height: 10; color: staticSceneLayer.gameSubInk }
        Rectangle { x: 108; y: 88; width: 10; height: 10; radius: 2; color: staticSceneLayer.gameInk }
        Rectangle {
            x: 168
            y: 98
            width: 10
            height: 10
            color: staticSceneLayer.gameSubInk
            border.color: staticSceneLayer.gameBorder
            border.width: 1
        }

        Item {
            x: 138
            y: 118
            width: 10
            height: 10

            Canvas {
                anchors.fill: parent

                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()
                    drawFoodSymbol(ctx, width, height)
                }

                Component.onCompleted: requestPaint()
            }
        }

        BuffStatusPanel {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: staticSceneLayer.showReplay ? 46 : 4
            anchors.leftMargin: 4
            active: staticSceneLayer.showGame || staticSceneLayer.showReplay
            gameFont: staticSceneLayer.gameFont
            menuColor: staticSceneLayer.menuColor
            readableText: staticSceneLayer.readableText
            elapsed: 0
            buffLabel: buffName(previewBuffType)
            rarityLabel: rarityName(previewBuffType)
            accent: rarityColor(previewBuffType)
            buffTier: rarityTier(previewBuffType)
            ticksRemaining: previewBuffRemaining
            ticksTotal: previewBuffTotal
        }

        ReplayBanner {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 4
            active: staticSceneLayer.showReplay
            menuColor: staticSceneLayer.menuColor
            gameFont: staticSceneLayer.gameFont
            hintText: "START EXIT   SELECT EXIT"
        }

        HudLayer {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 4
            anchors.rightMargin: 4
            z: staticSceneLayer.layerHud
            active: staticSceneLayer.showGame || staticSceneLayer.showReplay
            gameFont: staticSceneLayer.gameFont
            ink: staticSceneLayer.gameInk
            highScoreOverride: previewHighScore
            scoreOverride: previewScore
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 4
        width: parent.width - 12
        height: 20
        radius: 3
        color: Qt.rgba(staticSceneLayer.panelBg.r, staticSceneLayer.panelBg.g, staticSceneLayer.panelBg.b, 0.84)
        border.color: staticSceneLayer.panelBorder
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 0

            Text {
                text: "UP/DOWN SCENE   B/SELECT EXIT"
                color: staticSceneLayer.hintInk
                font.family: gameFont
                font.pixelSize: 8
                font.bold: true
            }

            Text {
                text: "PALETTE REVIEW"
                color: staticSceneLayer.secondaryInk
                font.family: gameFont
                font.pixelSize: 7
                font.bold: true
            }
        }
    }
}
