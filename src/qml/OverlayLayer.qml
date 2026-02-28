import QtQuick
import SnakeGB 1.0

Item {
    id: overlays
    property var gameLogic
    property var menuColor
    property string gameFont: ""
    property real elapsed: 0
    property var drawPowerSymbol
    property var rarityTier
    property var rarityName
    property var rarityColor
    property var readableText
    property var readableSecondaryText
    property bool showPausedAndGameOver: true
    property bool showReplayAndChoice: true
    property var blurSourceItem: null

    readonly property color modalTintColor: Qt.rgba(menuColor("cardPrimary").r, menuColor("cardPrimary").g, menuColor("cardPrimary").b, 0.08)
    readonly property color modalPanelFill: Qt.lighter(menuColor("cardSecondary"), 1.08)
    readonly property color modalPanelBorder: menuColor("borderSecondary")
    readonly property color modalInnerBorder: Qt.rgba(1, 1, 1, 0.08)
    readonly property color modalTitleInk: readableText ? readableText(modalPanelFill) : menuColor("titleInk")
    readonly property color modalSecondaryInk: readableSecondaryText ? readableSecondaryText(modalPanelFill) : menuColor("secondaryInk")
    readonly property color modalMetaInk: Qt.rgba(modalSecondaryInk.r, modalSecondaryInk.g, modalSecondaryInk.b, 0.90)
    readonly property color modalHintInk: Qt.rgba(modalSecondaryInk.r, modalSecondaryInk.g, modalSecondaryInk.b, 0.72)
    readonly property color modalCardFill: Qt.lighter(modalPanelFill, 1.04)
    readonly property color modalCardFillSelected: Qt.lighter(modalPanelFill, 1.10)
    readonly property color modalCardTitleInk: readableText ? readableText(modalCardFill) : menuColor("titleInk")
    readonly property color modalCardDescInk: Qt.rgba(
                                                   (readableSecondaryText ? readableSecondaryText(modalCardFill) : menuColor("secondaryInk")).r,
                                                   (readableSecondaryText ? readableSecondaryText(modalCardFill) : menuColor("secondaryInk")).g,
                                                   (readableSecondaryText ? readableSecondaryText(modalCardFill) : menuColor("secondaryInk")).b,
                                                   0.88)
    readonly property int layerPause: 100
    readonly property int layerReplayBanner: 110
    readonly property int layerGameOver: 120
    readonly property int layerChoiceModal: 200

    anchors.fill: parent

    ModalSurface {
        active: showPausedAndGameOver && gameLogic.state === AppState.Paused
        z: overlays.layerPause
        blurSourceItem: overlays.blurSourceItem
        blurScale: 1.8
        tintColor: overlays.modalTintColor
        panelWidth: 176
        panelHeight: 62
        panelColor: overlays.modalPanelFill
        panelBorderColor: overlays.modalPanelBorder
        panelInnerBorderColor: overlays.modalInnerBorder
        contentMargin: 8

        ModalTextPanel {
            anchors.fill: parent
            titleText: "PAUSED"
            hintText: "START RESUME   SELECT MENU"
            gameFont: overlays.gameFont
            titleColor: overlays.modalTitleInk
            hintColor: overlays.modalHintInk
            titleSize: 20
            hintSize: 8
            hintBold: false
            lineSpacing: 4
        }
    }

    ModalSurface {
        active: showPausedAndGameOver && gameLogic.state === AppState.GameOver
        z: overlays.layerGameOver
        blurSourceItem: overlays.blurSourceItem
        blurScale: 1.8
        tintColor: overlays.modalTintColor
        panelWidth: 184
        panelHeight: 78
        panelColor: overlays.modalPanelFill
        panelBorderColor: overlays.modalPanelBorder
        panelInnerBorderColor: overlays.modalInnerBorder
        contentMargin: 8

        ModalTextPanel {
            anchors.fill: parent
            titleText: "GAME OVER"
            bodyText: `SCORE ${gameLogic.score}`
            hintText: "START RESTART   SELECT MENU"
            gameFont: overlays.gameFont
            titleColor: overlays.modalTitleInk
            bodyColor: overlays.modalMetaInk
            hintColor: overlays.modalHintInk
            titleSize: 20
            bodySize: 9
            bodyBold: false
            hintSize: 8
            hintBold: false
            lineSpacing: 4
        }
    }

    ReplayBanner {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 2
        active: showReplayAndChoice && gameLogic.state === AppState.Replaying
        menuColor: overlays.menuColor
        gameFont: overlays.gameFont
        hintText: "START MENU   SELECT MENU"
        z: overlays.layerReplayBanner
    }

    ModalSurface {
        id: levelUpModal
        active: showReplayAndChoice && gameLogic.state === AppState.ChoiceSelection
        z: overlays.layerChoiceModal
        blurSourceItem: overlays.blurSourceItem
        blurScale: 1.4
        tintColor: overlays.modalTintColor
        panelWidth: Math.max(184, width - 36)
        panelHeight: Math.max(158, height - 36)
        panelColor: overlays.modalPanelFill
        panelBorderColor: overlays.modalPanelBorder
        panelInnerBorderColor: overlays.modalInnerBorder
        contentMargin: 8

        Column {
            id: choiceColumn
            anchors.fill: parent
            spacing: 3
            readonly property int cardHeight: Math.max(
                                                  36,
                                                  Math.min(44, Math.floor((height - headerPanel.height - footerPanel.height - (spacing * 4)) / 3)))

            Rectangle {
                id: headerPanel
                width: parent.width
                height: 26
                radius: 3
                color: overlays.modalPanelFill
                border.color: overlays.modalPanelBorder
                border.width: 1

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 10
                    spacing: -1

                    Text {
                        width: parent.width
                        height: 14
                        text: "LEVEL UP!"
                        color: overlays.modalTitleInk
                        font.family: overlays.gameFont
                        font.pixelSize: 12
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        width: parent.width
                        height: 8
                        text: "CHOOSE 1 POWER"
                        color: overlays.modalHintInk
                        font.family: overlays.gameFont
                        font.pixelSize: 6
                        font.bold: false
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Repeater {
                model: gameLogic.choices

                delegate: ModalChoiceCard {
                    width: parent.width
                    height: choiceColumn.cardHeight
                    gameFont: overlays.gameFont
                    titleText: modelData.name
                    descriptionText: modelData.desc
                    badgeText: overlays.rarityName(Number(modelData.type))
                    powerType: Number(modelData.type)
                    selected: overlays.gameLogic.choiceIndex === index
                    elapsed: overlays.elapsed
                    accent: overlays.rarityColor(powerType)
                    fillColor: overlays.modalCardFill
                    fillSelectedColor: overlays.modalCardFillSelected
                    borderColor: overlays.menuColor("borderSecondary")
                    borderSelectedColor: overlays.modalPanelBorder
                    titleColor: overlays.modalCardTitleInk
                    descriptionColor: overlays.modalCardDescInk
                    iconSocketColor: Qt.lighter(overlays.modalCardFill, 1.02)
                    iconBorderColor: overlays.menuColor("borderSecondary")
                    iconGlyphColor: selected ? Qt.darker(accent, 1.45) : Qt.darker(accent, 1.22)
                    badgeColor: Qt.rgba(accent.r, accent.g, accent.b, selected ? 0.16 : 0.10)
                    badgeBorderColor: selected ? Qt.darker(accent, 1.30) : overlays.menuColor("borderSecondary")
                    badgeTextColor: overlays.modalCardTitleInk
                    drawPowerSymbol: overlays.drawPowerSymbol
                    rarityTier: overlays.rarityTier
                }
            }

            Rectangle {
                id: footerPanel
                width: parent.width
                height: 16
                radius: 3
                color: overlays.modalPanelFill
                border.color: overlays.modalPanelBorder
                border.width: 1

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 4
                    anchors.rightMargin: 4
                    text: "START PICK   SELECT MENU"
                    color: overlays.modalHintInk
                    font.family: overlays.gameFont
                    font.pixelSize: 7
                    font.bold: false
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
