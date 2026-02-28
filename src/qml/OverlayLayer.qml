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
    property int overlayZBase: 800
    property int overlayZModal: 900
    property bool showPausedAndGameOver: true
    property bool showReplayAndChoice: true

    anchors.fill: parent

    Rectangle {
        id: pausedLayer
        anchors.fill: parent
        color: Qt.rgba(menuColor("cardPrimary").r, menuColor("cardPrimary").g, menuColor("cardPrimary").b, 0.9)
        visible: showPausedAndGameOver && gameLogic.state === AppState.Paused
        z: overlayZBase
        Column {
            anchors.centerIn: parent
            spacing: 6
            Text { text: "PAUSED"; font.family: gameFont; font.pixelSize: 20; color: menuColor("titleInk"); font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
            Text { text: "START RESUME   SELECT MENU"; color: menuColor("hintInk"); font.family: gameFont; font.pixelSize: 9; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
        }
    }

    Rectangle {
        id: gameOverLayer
        anchors.fill: parent
        color: Qt.rgba(menuColor("cardPrimary").r, menuColor("cardPrimary").g, menuColor("cardPrimary").b, 0.94)
        visible: showPausedAndGameOver && gameLogic.state === AppState.GameOver
        z: overlayZBase + 20
        Column {
            anchors.centerIn: parent
            spacing: 10
            Text { text: "GAME OVER"; color: menuColor("titleInk"); font.family: gameFont; font.pixelSize: 24; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
            Text { text: `SCORE: ${gameLogic.score}`; color: menuColor("secondaryInk"); font.family: gameFont; font.pixelSize: 14; anchors.horizontalCenter: parent.horizontalCenter }
            Text { text: "START RESTART   SELECT MENU"; color: menuColor("hintInk"); font.family: gameFont; font.pixelSize: 9; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
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
        z: overlayZBase + 10
    }

    Rectangle {
        anchors.fill: parent
        color: menuColor("cardPrimary")
        opacity: 1.0
        visible: showReplayAndChoice && gameLogic.state === AppState.ChoiceSelection
        z: overlayZModal
        Column {
            anchors.centerIn: parent
            spacing: 6
            width: parent.width - 34

            Rectangle {
                width: parent.width
                height: 24
                radius: 3
                color: Qt.rgba(menuColor("cardPrimary").r, menuColor("cardPrimary").g, menuColor("cardPrimary").b, 0.96)
                border.color: menuColor("borderPrimary")
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 0

                    Text {
                        text: "LEVEL UP!"
                        color: readableText ? readableText(parent.parent.color) : menuColor("titleInk")
                        font.pixelSize: 16
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "CHOOSE 1 POWER"
                        color: readableSecondaryText ? readableSecondaryText(parent.parent.color) : menuColor("secondaryInk")
                        font.pixelSize: 7
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
            Repeater {
                model: gameLogic.choices
                delegate: Rectangle {
                    id: choiceCard
                    width: parent.width
                    height: 52
                    radius: 4
                    property int powerType: Number(modelData.type)
                    property color accent: rarityColor(powerType)
                    readonly property bool selected: gameLogic.choiceIndex === index
                    color: Qt.rgba(menuColor("cardPrimary").r, menuColor("cardPrimary").g, menuColor("cardPrimary").b, selected ? 0.98 : 0.92)
                    border.color: selected ? menuColor("borderPrimary") : menuColor("borderSecondary")
                    border.width: 1

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: accent
                        opacity: selected ? 0.14 : 0.04
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        radius: 3
                        color: "transparent"
                        border.color: selected ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)
                        border.width: 1
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 4
                        radius: 3
                        color: accent
                        opacity: selected ? 1.0 : 0.72
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 8
                        Rectangle {
                            width: 28
                            height: 28
                            radius: 6
                            color: menuColor("cardPrimary")
                            border.color: selected ? accent : menuColor("borderSecondary")
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                anchors.centerIn: parent
                                width: 22
                                height: 22
                                property color accent: choiceCard.accent
                                Canvas {
                                    anchors.fill: parent
                                    onPaint: {
                                        const ctx = getContext("2d")
                                        ctx.reset()
                                        drawPowerSymbol(ctx, width, height, powerType, choiceCard.accent)
                                    }
                                    Component.onCompleted: requestPaint()
                                    onWidthChanged: requestPaint()
                                    onHeightChanged: requestPaint()
                                }
                            }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 54
                            spacing: 1
                            Text {
                                text: modelData.name
                                color: readableText ? readableText(choiceCard.color) : menuColor("titleInk")
                                font.bold: true
                                font.pixelSize: 11
                            }
                            Text {
                                text: modelData.desc
                                color: readableSecondaryText ? readableSecondaryText(choiceCard.color) : menuColor("secondaryInk")
                                font.pixelSize: 8
                                font.bold: true
                                opacity: 0.94
                                width: parent.width
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.rightMargin: 5
                        anchors.topMargin: 3
                        height: 11
                        width: 48
                        radius: 3
                        color: Qt.rgba(parent.accent.r, parent.accent.g, parent.accent.b, selected ? 0.92 : 0.18)
                        border.color: selected ? menuColor("borderPrimary") : parent.accent
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: rarityName(choiceCard.powerType)
                            color: selected ? menuColor("actionInk") : parent.accent
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
                                 ? ((Math.floor(overlays.elapsed * 6) % 2 === 0) ? 0.35 : 0.08)
                                 : 0.0
                    }
                }
            }
            Rectangle {
                width: parent.width
                height: 16
                radius: 3
                color: Qt.rgba(menuColor("cardPrimary").r, menuColor("cardPrimary").g, menuColor("cardPrimary").b, 0.94)
                border.color: menuColor("borderPrimary")
                border.width: 1

                Text {
                    text: "START PICK   SELECT MENU"
                    color: readableText ? readableText(parent.color) : menuColor("secondaryInk")
                    font.family: gameFont
                    font.pixelSize: 8
                    font.bold: true
                    anchors.centerIn: parent
                }
            }
        }
    }
}
