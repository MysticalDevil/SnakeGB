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
    readonly property color panelFill: menuColor("cardPrimary")
    readonly property color panelBorder: accent
    readonly property color titleStripFill: Qt.lighter(menuColor("cardSecondary"), 1.02)
    readonly property color titleInk: readableText ? readableText(titleStripFill) : menuColor("titleInk")
    readonly property color badgeInk: readableText ? readableText(accent) : menuColor("actionInk")
    readonly property int badgeWidth: Math.max(30, rarityText.implicitWidth + 10)
    readonly property int titleMaxWidth: width - badgeWidth - 14
    readonly property int titleWidth: Math.min(titleMaxWidth, Math.max(40, titleText.implicitWidth + 10))

    width: 126
    height: 32
    radius: 4
    color: panelFill
    border.color: panelBorder
    border.width: 1
    visible: active

    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.top: parent.top
        anchors.topMargin: 4
        width: buffPanel.titleWidth
        height: 12
        radius: 3
        color: buffPanel.titleStripFill
        border.color: Qt.rgba(buffPanel.panelBorder.r, buffPanel.panelBorder.g, buffPanel.panelBorder.b, 0.55)
        border.width: 1

        Text {
            id: titleText
            anchors.fill: parent
            anchors.leftMargin: 5
            anchors.rightMargin: 4
            text: buffPanel.buffLabel
            color: buffPanel.titleInk
            font.family: gameFont
            font.pixelSize: 8
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }

    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.top: parent.top
        anchors.topMargin: 4
        width: buffPanel.badgeWidth
        height: 12
        radius: 3
        color: buffPanel.accent
        border.color: Qt.rgba(buffPanel.badgeInk.r, buffPanel.badgeInk.g, buffPanel.badgeInk.b, 0.55)
        border.width: 1

        Text {
            id: rarityText
            anchors.centerIn: parent
            text: buffPanel.rarityLabel
            color: buffPanel.badgeInk
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
