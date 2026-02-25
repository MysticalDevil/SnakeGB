import QtQuick
import SnakeGB 1.0

Item {
    id: gameWorld
    property bool active: false
    property var gameLogic
    property real elapsed: 0
    property string gameFont: ""
    property var menuColor
    property color gameBg: "black"
    property color gamePanel: "black"
    property color gameInk: "white"
    property color gameSubInk: "gray"
    property color gameBorder: "gray"
    property var drawFoodSymbol
    property var drawPowerSymbol
    property var powerColor
    property var buffName
    property var rarityTier
    property var rarityName
    property var rarityColor

    anchors.fill: parent
    z: 10
    visible: active
    readonly property real cellW: width / gameLogic.boardWidth
    readonly property real cellH: height / gameLogic.boardHeight

    Repeater {
        model: gameLogic.ghost
        visible: gameLogic.state === AppState.Playing
        delegate: Rectangle {
            x: modelData.x * gameWorld.cellW
            y: modelData.y * gameWorld.cellH
            width: gameWorld.cellW
            height: gameWorld.cellH
            color: gameWorld.gameSubInk
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
            color: gameLogic.activeBuff === 6
                   ? (Math.floor(gameWorld.elapsed * 10) % 2 === 0 ? powerColor(6) : gameWorld.gameInk)
                   : (index === 0 ? gameWorld.gameInk : gameWorld.gameSubInk)
            radius: index === 0 ? 2 : 0
            Rectangle {
                anchors.fill: parent
                anchors.margins: -2
                border.color: powerColor(4)
                border.width: 1
                radius: parent.radius + 2
                visible: index === 0 && gameLogic.shieldActive
            }
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
                   ? ((Math.floor(gameWorld.elapsed * 8) % 2 === 0) ? gameWorld.gameInk : gameWorld.gameSubInk)
                   : gameWorld.gameSubInk
            border.color: gameWorld.gameBorder
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
                const ctx = getContext("2d")
                ctx.reset()
                drawFoodSymbol(ctx, width, height)
            }
            Component.onCompleted: requestPaint()
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
        }
    }

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
            border.color: gameWorld.gameBorder
            border.width: 1
            opacity: 0.75
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width - 1
            height: parent.height - 1
            radius: 2
            color: Qt.rgba(gameWorld.gamePanel.r, gameWorld.gamePanel.g, gameWorld.gamePanel.b, 0.78)
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width + 6
            height: parent.height + 6
            radius: width / 2
            color: "transparent"
            border.color: gameWorld.gameBorder
            border.width: 1
            opacity: (Math.floor(gameWorld.elapsed * 8) % 2 === 0) ? 0.45 : 0.1
        }

        Canvas {
            id: worldPowerIcon
            anchors.fill: parent
            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                drawPowerSymbol(ctx, width, height, gameLogic.powerUpType, powerColor(gameLogic.powerUpType))
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
        color: menuColor("cardPrimary")
        border.color: accent
        border.width: 1
        z: 40
        visible: (gameLogic.state === AppState.Playing || gameLogic.state === AppState.Replaying) &&
                 gameLogic.activeBuff !== 0 && gameLogic.buffTicksTotal > 0

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.top: parent.top
            anchors.topMargin: 1
            text: buffName(gameLogic.activeBuff)
            color: menuColor("titleInk")
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
            color: menuColor("titleInk")
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
            color: menuColor("cardSecondary")
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
                         ? ((Math.floor(gameWorld.elapsed * 8) % 2 === 0) ? 0.35 : 0.1)
                         : 0.0
            }
        }
    }
}
