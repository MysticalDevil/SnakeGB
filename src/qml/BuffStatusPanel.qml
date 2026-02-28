import QtQuick

Rectangle {
    id: buffPanel
    property bool active: false
    property string gameFont: ""
    property var menuColor
    property var readableText
    property real elapsed: 0
    property string buffLabel: ""
    property string rarityLabel: ""
    property color accent: "white"
    property int buffTier: 1
    property int ticksRemaining: 0
    property int ticksTotal: 1
    readonly property real progressRatio: Math.max(0, Math.min(1, ticksRemaining / Math.max(1, ticksTotal)))

    width: 126
    height: 30
    radius: 4
    color: menuColor("cardPrimary")
    border.color: accent
    border.width: 1
    visible: active

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.top: parent.top
        anchors.topMargin: 3
        text: buffPanel.buffLabel
        color: readableText ? readableText(menuColor("cardPrimary")) : menuColor("titleInk")
        font.family: gameFont
        font.pixelSize: 9
        font.bold: true
    }

    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.top: parent.top
        anchors.topMargin: 4
        width: 38
        height: 12
        radius: 3
        color: buffPanel.accent
        border.color: menuColor("borderPrimary")
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: buffPanel.rarityLabel
            color: menuColor("actionInk")
            font.family: gameFont
            font.pixelSize: 7
            font.bold: true
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        anchors.bottomMargin: 4
        height: 7
        radius: 2
        color: menuColor("cardSecondary")
        border.color: buffPanel.accent
        border.width: 1

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * buffPanel.progressRatio
            radius: 1
            color: buffPanel.accent
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: buffPanel.accent
            border.width: 1
            opacity: buffPanel.buffTier >= 3
                     ? ((Math.floor(buffPanel.elapsed * 8) % 2 === 0) ? 0.35 : 0.1)
                     : 0.0
        }
    }
}
