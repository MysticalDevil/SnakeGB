import QtQuick
import SnakeGB 1.0

Item {
    id: gameWorld
    property bool active: false
    property int currentState: AppState.Splash
    property int boardWidth: 1
    property int boardHeight: 1
    property var ghostModel: []
    property var snakeModel: []
    property bool shieldActive: false
    property var obstacleModel: []
    property string currentLevelName: ""
    property var foodPos: ({ x: 0, y: 0 })
    property var powerUpPos: ({ x: -1, y: -1 })
    property int powerUpType: 0
    property int activeBuff: 0
    property int buffTicksRemaining: 0
    property int buffTicksTotal: 0
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
    readonly property real cellW: width / Math.max(1, boardWidth)
    readonly property real cellH: height / Math.max(1, boardHeight)
    readonly property int layerObstacle: 12
    readonly property int layerFood: 20
    readonly property int layerPowerUp: 30
    readonly property int layerBuffPanel: 40

    Repeater {
        model: ghostModel
        visible: gameWorld.currentState === AppState.Playing
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
        model: snakeModel
        delegate: Rectangle {
            x: model.pos.x * gameWorld.cellW
            y: model.pos.y * gameWorld.cellH
            width: gameWorld.cellW
            height: gameWorld.cellH
            color: gameWorld.activeBuff === 6
                   ? (Math.floor(gameWorld.elapsed * 10) % 2 === 0 ? powerColor(6) : gameWorld.gameInk)
                   : (index === 0 ? gameWorld.gameInk : gameWorld.gameSubInk)
            radius: index === 0 ? 2 : 0
            Rectangle {
                anchors.fill: parent
                anchors.margins: -2
                border.color: powerColor(4)
                border.width: 1
                radius: parent.radius + 2
                visible: index === 0 && gameWorld.shieldActive
            }
        }
    }

    Repeater {
        model: obstacleModel
        delegate: Rectangle {
            x: modelData.x * gameWorld.cellW
            y: modelData.y * gameWorld.cellH
            width: gameWorld.cellW
            height: gameWorld.cellH
            color: gameWorld.currentLevelName === "Dynamic Pulse" || gameWorld.currentLevelName === "Crossfire" || gameWorld.currentLevelName === "Shifting Box"
                   ? ((Math.floor(gameWorld.elapsed * 8) % 2 === 0) ? gameWorld.gameInk : gameWorld.gameSubInk)
                   : gameWorld.gameSubInk
            border.color: gameWorld.gameBorder
            border.width: 1
            z: gameWorld.layerObstacle
        }
    }

    Item {
        x: gameWorld.foodPos.x * gameWorld.cellW
        y: gameWorld.foodPos.y * gameWorld.cellH
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
        visible: gameWorld.powerUpPos.x !== -1
        x: gameWorld.powerUpPos.x * gameWorld.cellW
        y: gameWorld.powerUpPos.y * gameWorld.cellH
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
                drawPowerSymbol(ctx, width, height, gameWorld.powerUpType, powerColor(gameWorld.powerUpType))
            }
            Component.onCompleted: requestPaint()
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            onVisibleChanged: requestPaint()
        }
    }

    BuffStatusPanel {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: gameWorld.currentState === AppState.Replaying ? 44 : 4
        anchors.leftMargin: 4
        active: (gameWorld.currentState === AppState.Playing || gameWorld.currentState === AppState.Replaying) &&
                gameWorld.activeBuff !== 0 && gameWorld.buffTicksTotal > 0
        gameFont: gameFont
        menuColor: gameWorld.menuColor
        readableText: gameWorld.readableText
        elapsed: gameWorld.elapsed
        buffLabel: buffName(gameWorld.activeBuff)
        rarityLabel: rarityName(gameWorld.activeBuff)
        accent: rarityColor(gameWorld.activeBuff)
        buffTier: rarityTier(gameWorld.activeBuff)
        ticksRemaining: gameWorld.buffTicksRemaining
        ticksTotal: gameWorld.buffTicksTotal
        z: gameWorld.layerBuffPanel
    }
}
