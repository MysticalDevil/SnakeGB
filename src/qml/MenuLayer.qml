import QtQuick

Rectangle {
    id: menuLayer
    property bool active: false
    property string gameFont: ""
    property real elapsed: 0
    property var menuColor
    property var sessionStatus
    property int highScore: 0

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

    Rectangle {
        id: titleBlock
        width: parent.width - 28
        anchors.top: parent.top
        anchors.topMargin: 24
        anchors.horizontalCenter: parent.horizontalCenter
        height: 48
        radius: 4
        color: Qt.rgba(menuLayer.cardSecondary.r, menuLayer.cardSecondary.g, menuLayer.cardSecondary.b, 0.84)
        border.color: Qt.rgba(menuLayer.borderPrimary.r, menuLayer.borderPrimary.g, menuLayer.borderPrimary.b, 0.72)
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 2

            Text {
                text: "S N A K E"
                font.family: gameFont
                font.pixelSize: 26
                color: menuLayer.titleInk
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: sessionStatus.hasSave ? "CONTINUE READY" : "NEW RUN READY"
                font.family: gameFont
                font.pixelSize: 8
                color: Qt.rgba(menuLayer.secondaryInk.r, menuLayer.secondaryInk.g, menuLayer.secondaryInk.b, 0.74)
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Column {
        id: centerStack
        width: parent.width - 44
        anchors.top: titleBlock.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 0

        Rectangle {
            width: 190
            height: 40
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 4
            color: menuLayer.actionCard
            border.color: Qt.rgba(menuLayer.actionInk.r, menuLayer.actionInk.g, menuLayer.actionInk.b, 0.72)
            border.width: 1

            Row {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    text: "START"
                    color: Qt.rgba(menuLayer.actionInk.r, menuLayer.actionInk.g, menuLayer.actionInk.b, 0.68)
                    font.family: gameFont
                    font.pixelSize: 10
                    font.bold: true
                    width: 42
                    horizontalAlignment: Text.AlignRight
                }

                Text {
                    text: sessionStatus.hasSave ? "CONTINUE" : "NEW GAME"
                    color: menuLayer.actionInk
                    font.family: gameFont
                    font.pixelSize: 15
                    font.bold: true
                    opacity: (Math.floor(elapsed * 4) % 2 === 0) ? 1.0 : 0.86
                    width: 86
                    horizontalAlignment: Text.AlignLeft
                }
            }
        }
    }

    Column {
        id: hintColumn
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        spacing: 2

        Repeater {
            model: [
                { key: "UP", value: "MEDALS" },
                { key: "DOWN", value: "REPLAY" },
                { key: "LEFT", value: "CATALOG" },
                { key: "SELECT", value: "LEVEL" }
            ]

            delegate: Row {
                spacing: 4

                Text {
                    text: modelData.key
                    color: Qt.rgba(menuLayer.secondaryInk.r, menuLayer.secondaryInk.g, menuLayer.secondaryInk.b, 0.44)
                    font.family: gameFont
                    font.pixelSize: 6
                    font.bold: true
                }

                Text {
                    text: modelData.value
                    color: Qt.rgba(menuLayer.secondaryInk.r, menuLayer.secondaryInk.g, menuLayer.secondaryInk.b, 0.58)
                    font.family: gameFont
                    font.pixelSize: 7
                    font.bold: true
                }
            }
        }
    }

    Column {
        id: statusColumn
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        spacing: 2

        Repeater {
            model: [
                { label: "HI", value: `${highScore}` },
                { label: "LEVEL", value: `${sessionStatus.currentLevelName}` }
            ]

            delegate: Row {
                anchors.right: parent ? parent.right : undefined
                spacing: 4

                Text {
                    text: modelData.label
                    font.family: gameFont
                    font.pixelSize: 7
                    font.bold: true
                    color: Qt.rgba(menuLayer.secondaryInk.r, menuLayer.secondaryInk.g, menuLayer.secondaryInk.b, 0.5)
                }

                Text {
                    text: modelData.value
                    font.family: gameFont
                    font.pixelSize: index === 0 ? 10 : 9
                    font.bold: true
                    color: index === 0
                           ? Qt.rgba(menuLayer.titleInk.r, menuLayer.titleInk.g, menuLayer.titleInk.b, 0.82)
                           : Qt.rgba(menuLayer.secondaryInk.r, menuLayer.secondaryInk.g, menuLayer.secondaryInk.b, 0.78)
                }
            }
        }
    }
}
