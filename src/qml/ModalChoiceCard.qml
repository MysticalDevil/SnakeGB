import QtQuick

Rectangle {
    id: choiceCard
    property string gameFont: ""
    property string titleText: ""
    property string descriptionText: ""
    property string badgeText: ""
    property int powerType: 0
    property bool selected: false
    property real elapsed: 0
    property color accent: "white"
    property color fillColor: "white"
    property color fillSelectedColor: "white"
    property color borderColor: "black"
    property color borderSelectedColor: "black"
    property color titleColor: "black"
    property color descriptionColor: "black"
    property color iconSocketColor: "white"
    property color iconBorderColor: "black"
    property color iconGlyphColor: "black"
    property color badgeColor: "white"
    property color badgeBorderColor: "black"
    property color badgeTextColor: "black"
    property var drawPowerSymbol
    property var rarityTier

    width: parent ? parent.width : 0
    height: 48
    radius: 4
    color: selected ? fillSelectedColor : fillColor
    border.color: selected ? borderSelectedColor : borderColor
    border.width: 1

    readonly property int badgeWidth: 52
    readonly property int sidePadding: 8
    readonly property int iconSize: Math.min(26, Math.max(20, height - 18))
    readonly property bool pulseAccent: rarityTier ? rarityTier(powerType) >= 3 : false

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: choiceCard.accent
        opacity: selected ? 0.08 : 0.02
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
        width: selected ? 5 : 4
        radius: 3
        color: selected ? Qt.darker(accent, 1.18) : accent
        opacity: selected ? 1.0 : 0.78
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        radius: 1
        color: Qt.rgba(1, 1, 1, selected ? 0.24 : 0.12)
        opacity: 1.0
    }

    Row {
        anchors.fill: parent
        anchors.margins: choiceCard.sidePadding
        anchors.leftMargin: choiceCard.sidePadding + 6
        anchors.rightMargin: choiceCard.sidePadding + 1
        spacing: 10

        Rectangle {
            width: choiceCard.iconSize
            height: width
            radius: 6
            color: choiceCard.iconSocketColor
            border.color: choiceCard.selected ? choiceCard.borderSelectedColor : choiceCard.iconBorderColor
            border.width: 1
            anchors.verticalCenter: parent.verticalCenter

            Item {
                anchors.centerIn: parent
                width: 22
                height: 22

                Canvas {
                    anchors.fill: parent
                    onPaint: {
                        const ctx = getContext("2d")
                        ctx.reset()
                        drawPowerSymbol(ctx, width, height, powerType, iconGlyphColor)
                    }
                    Component.onCompleted: requestPaint()
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()
                }
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - choiceCard.iconSize - choiceCard.badgeWidth - 28
            spacing: 1

            Text {
                text: choiceCard.titleText
                color: choiceCard.titleColor
                font.family: choiceCard.gameFont
                font.pixelSize: 9
                font.bold: true
                width: parent.width
                elide: Text.ElideRight
            }

            Text {
                text: choiceCard.descriptionText
                color: choiceCard.descriptionColor
                font.family: choiceCard.gameFont
                font.pixelSize: 7
                font.bold: false
                width: parent.width
                opacity: 0.84
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
            }
        }
    }

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: choiceCard.sidePadding
        anchors.topMargin: 3
        width: choiceCard.badgeWidth
        height: 12
        radius: 3
        color: choiceCard.badgeColor
        border.color: choiceCard.badgeBorderColor
        border.width: selected ? 2 : 1

        Text {
            anchors.fill: parent
            text: choiceCard.badgeText
            color: choiceCard.badgeTextColor
            font.family: choiceCard.gameFont
            font.pixelSize: 7
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: accent
        border.width: 1
        opacity: choiceCard.pulseAccent
                 ? ((Math.floor(choiceCard.elapsed * 6) % 2 === 0) ? 0.28 : 0.08)
                 : 0.0
    }
}
