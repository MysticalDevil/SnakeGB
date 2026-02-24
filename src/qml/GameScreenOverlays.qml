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

    anchors.fill: parent

    Rectangle {
        id: pausedLayer
        anchors.fill: parent
        color: Qt.rgba(menuColor("cardPrimary").r, menuColor("cardPrimary").g, menuColor("cardPrimary").b, 0.9)
        visible: gameLogic.state === AppState.Paused
        z: overlayZBase
        Column {
            anchors.centerIn: parent
            spacing: 6
            Text { text: "PAUSED"; font.family: gameFont; font.pixelSize: 20; color: menuColor("titleInk"); font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
            Text { text: "START: RESUME   SELECT: MENU"; color: menuColor("hintInk"); font.family: gameFont; font.pixelSize: 8; anchors.horizontalCenter: parent.horizontalCenter }
        }
    }

    Rectangle {
        id: gameOverLayer
        anchors.fill: parent
        color: Qt.rgba(menuColor("cardPrimary").r, menuColor("cardPrimary").g, menuColor("cardPrimary").b, 0.94)
        visible: gameLogic.state === AppState.GameOver
        z: overlayZBase + 20
        Column {
            anchors.centerIn: parent
            spacing: 10
            Text { text: "GAME OVER"; color: menuColor("titleInk"); font.family: gameFont; font.pixelSize: 24; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
            Text { text: `SCORE: ${gameLogic.score}`; color: menuColor("secondaryInk"); font.family: gameFont; font.pixelSize: 14; anchors.horizontalCenter: parent.horizontalCenter }
            Text { text: "START: RESTART   SELECT: MENU"; color: menuColor("hintInk"); font.family: gameFont; font.pixelSize: 8; anchors.horizontalCenter: parent.horizontalCenter }
        }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: 160
        height: 32
        color: menuColor("actionCard")
        opacity: 0.96
        visible: gameLogic.state === AppState.Replaying
        z: overlayZBase + 10
        Column {
            anchors.centerIn: parent
            spacing: 1
            Text { text: "REPLAY"; color: menuColor("actionInk"); anchors.horizontalCenter: parent.horizontalCenter; font.bold: true; font.pixelSize: 11 }
            Text { text: "START: MENU   SELECT: MENU"; color: menuColor("hintInk"); anchors.horizontalCenter: parent.horizontalCenter; font.pixelSize: 7 }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: menuColor("cardPrimary")
        opacity: 1.0
        visible: gameLogic.state === AppState.ChoiceSelection
        z: overlayZModal
        Column {
            anchors.centerIn: parent
            spacing: 8
            width: parent.width - 40
            Text { text: "LEVEL UP!"; color: menuColor("titleInk"); font.pixelSize: 18; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
            Repeater {
                model: gameLogic.choices
                delegate: Rectangle {
                    id: choiceCard
                    width: parent.width
                    height: 46
                    property int powerType: Number(modelData.type)
                    property color accent: rarityColor(powerType)
                    color: gameLogic.choiceIndex === index
                           ? menuColor("actionCard")
                           : menuColor("cardSecondary")
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
                            color: menuColor("cardPrimary")
                            border.color: parent.parent.accent
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
                            width: parent.width - 44
                            Text { text: modelData.name; color: menuColor("titleInk"); font.bold: true; font.pixelSize: 9 }
                            Text { text: modelData.desc; color: menuColor("secondaryInk"); font.pixelSize: 7; opacity: 1.0; width: parent.width; wrapMode: Text.WordWrap }
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
                        color: Qt.rgba(menuColor("cardPrimary").r, menuColor("cardPrimary").g, menuColor("cardPrimary").b, 0.85)
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
                                 ? ((Math.floor(overlays.elapsed * 6) % 2 === 0) ? 0.35 : 0.08)
                                 : 0.0
                    }
                }
            }
            Text {
                text: "START: PICK   SELECT: MENU"
                color: menuColor("hintInk")
                font.family: gameFont
                font.pixelSize: 8
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
