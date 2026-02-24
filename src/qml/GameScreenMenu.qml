import QtQuick

Rectangle {
    id: menuLayer
    property bool active: false
    property string gameFont: ""
    property real elapsed: 0
    property var menuColor
    property var gameLogic

    readonly property color cardPrimary: menuColor("cardPrimary")
    readonly property color cardSecondary: menuColor("cardSecondary")
    readonly property color actionCard: menuColor("actionCard")
    readonly property color hintCard: menuColor("hintCard")
    readonly property color borderPrimary: menuColor("borderPrimary")
    readonly property color borderSecondary: menuColor("borderSecondary")
    readonly property color titleInk: menuColor("titleInk")
    readonly property color secondaryInk: menuColor("secondaryInk")
    readonly property color actionInk: menuColor("actionInk")
    readonly property color hintInk: menuColor("hintInk")

    color: cardPrimary
    visible: active
    z: 500

    Column {
        width: parent.width - 24
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 7

        Rectangle {
            width: parent.width
            height: 44
            radius: 4
            color: Qt.rgba(menuLayer.cardSecondary.r, menuLayer.cardSecondary.g, menuLayer.cardSecondary.b, 0.88)
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
                    text: `HI ${gameLogic.highScore}`
                    font.family: gameFont
                    font.pixelSize: 11
                    font.bold: true
                    color: menuLayer.secondaryInk
                }
                Text {
                    text: `LEVEL ${gameLogic.currentLevelName}`
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
            color: Qt.rgba(menuLayer.cardSecondary.r, menuLayer.cardSecondary.g, menuLayer.cardSecondary.b, 0.90)
            border.color: menuLayer.borderPrimary
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 7
                spacing: 1
                Text {
                    text: "UP: MEDALS   DOWN: REPLAY"
                    color: Qt.rgba(menuLayer.secondaryInk.r, menuLayer.secondaryInk.g, menuLayer.secondaryInk.b, 0.95)
                    font.pixelSize: 8
                    font.bold: false
                }
                Text {
                    text: "LEFT: CATALOG   SELECT: LEVEL"
                    color: Qt.rgba(menuLayer.secondaryInk.r, menuLayer.secondaryInk.g, menuLayer.secondaryInk.b, 0.95)
                    font.pixelSize: 8
                    font.bold: false
                }
            }
        }
    }
}
