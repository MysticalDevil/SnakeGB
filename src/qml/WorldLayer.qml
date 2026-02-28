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
    property var readableText

    anchors.fill: parent
    visible: active
    readonly property real cellW: width / gameLogic.boardWidth
    readonly property real cellH: height / gameLogic.boardHeight
    readonly property int layerObstacle: 12
    readonly property int layerFood: 20
    readonly property int layerPowerUp: 30
    readonly property int layerBuffPanel: 40

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
            z: gameWorld.layerObstacle
        }
    }

    Item {
        x: gameLogic.food.x * gameWorld.cellW
        y: gameLogic.food.y * gameWorld.cellH
        width: gameWorld.cellW
        height: gameWorld.cellH
        z: gameWorld.layerFood

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
        z: gameWorld.layerPowerUp

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

    BuffStatusPanel {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: gameLogic.state === AppState.Replaying ? 44 : 4
        anchors.leftMargin: 4
        active: (gameLogic.state === AppState.Playing || gameLogic.state === AppState.Replaying) &&
                gameLogic.activeBuff !== 0 && gameLogic.buffTicksTotal > 0
        gameFont: gameFont
        menuColor: gameWorld.menuColor
        readableText: gameWorld.readableText
        elapsed: gameWorld.elapsed
        buffLabel: buffName(gameLogic.activeBuff)
        rarityLabel: rarityName(gameLogic.activeBuff)
        accent: rarityColor(gameLogic.activeBuff)
        buffTier: rarityTier(gameLogic.activeBuff)
        ticksRemaining: gameLogic.buffTicksRemaining
        ticksTotal: gameLogic.buffTicksTotal
        z: gameWorld.layerBuffPanel
    }
}
