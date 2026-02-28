import QtQuick
import "PowerMeta.js" as PowerMeta

Rectangle {
    id: staticSceneLayer
    property string staticScene: ""
    property var staticDebugOptions: ({})
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
    property var drawPowerSymbol
    property var buffName
    property var rarityTier
    property var rarityName
    property var rarityColor
    property var readableText

    function staticOption(name, fallback) {
        if (staticDebugOptions && staticDebugOptions[name] !== undefined) {
            return staticDebugOptions[name]
        }
        return fallback
    }

    anchors.fill: parent
    visible: staticScene !== ""
    color: (showGame || showReplay || showChoice) ? playBg : menuColor("cardPrimary")
    clip: true

    readonly property bool showBoot: staticScene === "boot"
    readonly property bool showGame: staticScene === "game"
    readonly property bool showReplay: staticScene === "replay"
    readonly property bool showChoice: staticScene === "choice"
    readonly property color panelBg: menuColor("cardSecondary")
    readonly property color panelAccent: menuColor("actionCard")
    readonly property color panelBorder: menuColor("borderPrimary")
    readonly property color panelBorderSoft: menuColor("borderSecondary")
    readonly property color titleInk: menuColor("titleInk")
    readonly property color accentInk: menuColor("actionInk")
    readonly property color secondaryInk: menuColor("secondaryInk")
    readonly property color hintInk: menuColor("hintInk")
    readonly property color bootMetaFill: Qt.rgba(panelBg.r, panelBg.g, panelBg.b, 0.88)
    readonly property string sceneBadgeText: showBoot ? "DBG BOOT"
                                                      : (showGame ? "DBG GAME"
                                                                  : (showReplay ? "DBG REPLAY" : "DBG CHOICE"))
    readonly property int layerHud: 60
    readonly property int previewHighScore: staticOption("highScore", 0)
    readonly property int previewScore: staticOption("score", showReplay ? 42 : 18)
    readonly property int previewBuffType: staticOption("buffType", showReplay ? 4 : 3)
    readonly property int previewBuffRemaining: staticOption("buffRemaining", showReplay ? 104 : 136)
    readonly property int previewBuffTotal: staticOption("buffTotal", 180)
    readonly property var previewChoiceTypes: {
        const raw = staticOption("choiceTypes", [7, 4, 1])
        if (!raw || raw.length === 0) {
            return [7, 4, 1]
        }
        return raw
    }
    readonly property int previewChoiceIndex: Math.max(
                                                0,
                                                Math.min(2, staticOption("choiceIndex", 0)))
    readonly property var previewChoices: previewChoiceTypes.map((type) => {
        const spec = PowerMeta.choiceSpec(type)
        return {
            type: spec.type,
            name: spec.name,
            desc: spec.description
        }
    })

    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 4
        anchors.rightMargin: 4
        width: 58
        height: 12
        radius: 3
        color: Qt.rgba(staticSceneLayer.panelBg.r, staticSceneLayer.panelBg.g, staticSceneLayer.panelBg.b, 0.80)
        border.color: staticSceneLayer.panelBorderSoft
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: staticSceneLayer.sceneBadgeText
            color: staticSceneLayer.titleInk
            font.family: gameFont
            font.pixelSize: 7
            font.bold: true
        }
    }

    Item {
        anchors.fill: parent
        visible: staticSceneLayer.showBoot

        Text {
            id: bootTitle
            text: "S N A K E"
            anchors.horizontalCenter: parent.horizontalCenter
            y: 46
            font.family: gameFont
            font.pixelSize: 32
            color: staticSceneLayer.titleInk
            font.bold: true
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: bootTitle.y + 35
            text: "PORTABLE ARCADE SURVIVAL"
            font.family: gameFont
            font.pixelSize: 10
            font.bold: true
            color: staticSceneLayer.titleInk
            style: Text.Outline
            styleColor: Qt.rgba(staticSceneLayer.panelBg.r, staticSceneLayer.panelBg.g, staticSceneLayer.panelBg.b, 0.92)
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 102
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
            y: 138
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

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 152
            width: 92
            height: 14
            radius: 3
            color: staticSceneLayer.bootMetaFill
            border.color: staticSceneLayer.panelBorder
            border.width: 1

            Text {
                anchors.fill: parent
                text: "LOADING 72%"
                font.family: gameFont
                font.pixelSize: 9
                font.bold: true
                color: staticSceneLayer.titleInk
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    Item {
        anchors.fill: parent
        id: scenePreview
        visible: staticSceneLayer.showGame || staticSceneLayer.showReplay || staticSceneLayer.showChoice

        Item {
            id: previewBackdrop
            anchors.fill: parent

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
                hintText: ""
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

        LevelUpModal {
            anchors.fill: parent
            active: staticSceneLayer.showChoice
            choices: staticSceneLayer.previewChoices
            choiceIndex: staticSceneLayer.previewChoiceIndex
            gameFont: staticSceneLayer.gameFont
            elapsed: 0
            drawPowerSymbol: staticSceneLayer.drawPowerSymbol
            rarityTier: staticSceneLayer.rarityTier
            rarityName: staticSceneLayer.rarityName
            rarityColor: staticSceneLayer.rarityColor
            blurSourceItem: previewBackdrop
            blurScale: 1.4
            tintColor: Qt.rgba(staticSceneLayer.panelBg.r, staticSceneLayer.panelBg.g, staticSceneLayer.panelBg.b, 0.08)
            modalPanelFill: Qt.lighter(staticSceneLayer.panelBg, 1.08)
            modalPanelBorder: staticSceneLayer.panelBorderSoft
            modalInnerBorder: Qt.rgba(1, 1, 1, 0.08)
            modalTitleInk: staticSceneLayer.titleInk
            modalHintInk: staticSceneLayer.hintInk
            modalCardFill: Qt.lighter(staticSceneLayer.panelBg, 1.04)
            modalCardFillSelected: Qt.lighter(staticSceneLayer.panelBg, 1.10)
            modalCardTitleInk: staticSceneLayer.titleInk
            modalCardDescInk: Qt.rgba(staticSceneLayer.secondaryInk.r, staticSceneLayer.secondaryInk.g, staticSceneLayer.secondaryInk.b, 0.88)
            cardBorderColor: staticSceneLayer.panelBorderSoft
        }
    }

}
