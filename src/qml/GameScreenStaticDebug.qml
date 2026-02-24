import QtQuick

Rectangle {
    id: staticSceneLayer
    property string staticScene: ""
    property string gameFont: ""
    property var menuColor
    property var gameLogic
    property color gameGrid: "gray"
    property color gameInk: "white"
    property color gameSubInk: "gray"
    property color gameBorder: "gray"
    property var drawFoodSymbol

    anchors.fill: parent
    visible: staticScene !== ""
    z: 1500
    color: menuColor("cardPrimary")
    clip: true
    readonly property bool showBoot: staticScene === "boot"
    readonly property bool showGame: staticScene === "game"
    readonly property bool showReplay: staticScene === "replay"
    readonly property color panelBg: menuColor("cardSecondary")
    readonly property color panelAccent: menuColor("actionCard")
    readonly property color panelBorder: menuColor("borderPrimary")
    readonly property color titleInk: menuColor("titleInk")
    readonly property color accentInk: menuColor("actionInk")
    readonly property color hintInk: menuColor("hintInk")

    Rectangle {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 6
        width: parent.width - 12
        height: 16
        radius: 3
        color: Qt.rgba(staticSceneLayer.panelBg.r, staticSceneLayer.panelBg.g, staticSceneLayer.panelBg.b, 0.9)
        border.color: staticSceneLayer.panelBorder
        border.width: 1
        Text {
            anchors.centerIn: parent
            text: staticSceneLayer.showBoot ? "STATIC DEBUG: BOOT"
                 : (staticSceneLayer.showGame ? "STATIC DEBUG: GAME" : "STATIC DEBUG: REPLAY")
            color: staticSceneLayer.titleInk
            font.family: gameFont
            font.pixelSize: 8
            font.bold: true
        }
    }

    Item {
        anchors.fill: parent
        anchors.topMargin: 24
        visible: staticSceneLayer.showBoot

        Text {
            text: "S N A K E"
            anchors.horizontalCenter: parent.horizontalCenter
            y: 70
            font.family: gameFont
            font.pixelSize: 32
            color: staticSceneLayer.titleInk
            font.bold: true
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 152
            width: 120
            height: 8
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
            y: 166
            text: "LOADING 72%"
            font.family: gameFont
            font.pixelSize: 8
            color: staticSceneLayer.accentInk
            opacity: 0.92
        }
    }

    Item {
        anchors.fill: parent
        anchors.topMargin: 24
        visible: staticSceneLayer.showGame || staticSceneLayer.showReplay

        Canvas {
            anchors.fill: parent
            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                const cw = width / gameLogic.boardWidth
                const ch = height / gameLogic.boardHeight
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

        Rectangle {
            x: 88
            y: 88
            width: 10
            height: 10
            color: staticSceneLayer.gameSubInk
        }
        Rectangle {
            x: 98
            y: 88
            width: 10
            height: 10
            color: staticSceneLayer.gameSubInk
        }
        Rectangle {
            x: 108
            y: 88
            width: 10
            height: 10
            radius: 2
            color: staticSceneLayer.gameInk
        }
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

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 4
            anchors.leftMargin: 4
            width: 110
            height: 24
            color: Qt.rgba(staticSceneLayer.panelBg.r, staticSceneLayer.panelBg.g, staticSceneLayer.panelBg.b, 0.95)
            border.color: staticSceneLayer.panelBorder
            border.width: 1
            visible: staticSceneLayer.showGame
            Text {
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.top: parent.top
                anchors.topMargin: 1
                text: "MAGNET"
                color: staticSceneLayer.titleInk
                font.family: gameFont
                font.pixelSize: 7
                font.bold: true
            }
            Text {
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.top: parent.top
                anchors.topMargin: 1
                text: "COMMON"
                color: staticSceneLayer.titleInk
                font.family: gameFont
                font.pixelSize: 7
                font.bold: true
            }
        }

        Rectangle {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 4
            width: 160
            height: 32
            color: staticSceneLayer.panelAccent
            border.color: Qt.rgba(staticSceneLayer.accentInk.r, staticSceneLayer.accentInk.g, staticSceneLayer.accentInk.b, 0.65)
            border.width: 1
            visible: staticSceneLayer.showReplay
            Column {
                anchors.centerIn: parent
                spacing: 1
                Text {
                    text: "REPLAY"
                    color: staticSceneLayer.accentInk
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.bold: true
                    font.pixelSize: 11
                }
                Text {
                    text: "START: MENU   SELECT: MENU"
                    color: staticSceneLayer.hintInk
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 7
                }
            }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 4
        width: parent.width - 12
        height: 14
        radius: 3
        color: Qt.rgba(staticSceneLayer.panelBg.r, staticSceneLayer.panelBg.g, staticSceneLayer.panelBg.b, 0.84)
        border.color: staticSceneLayer.panelBorder
        border.width: 1
        Text {
            anchors.centerIn: parent
            text: "UP/DOWN SWITCH   SELECT/B EXIT"
            color: staticSceneLayer.hintInk
            font.family: gameFont
            font.pixelSize: 7
            font.bold: true
        }
    }
}
