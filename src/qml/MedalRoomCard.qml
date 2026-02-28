import QtQuick

Rectangle {
    id: medalCard
    property var modelData
    property bool unlocked: false
    property bool selected: false
    property color cardNormal: "transparent"
    property color cardSelected: "transparent"
    property color cardBorder: "white"
    property color badgeFill: "white"
    property color badgeText: "black"
    property color titleColor: "white"
    property color secondaryText: "white"
    property color iconFill: "black"
    property color unknownText: "white"
    property string gameFont: ""

    width: parent ? parent.width : 0
    height: 52
    radius: 4
    color: selected ? cardSelected : cardNormal
    border.color: cardBorder
    border.width: 1

    readonly property color titleInk: selected ? badgeText : titleColor
    readonly property color hintInk: selected
        ? Qt.rgba(badgeText.r, badgeText.g, badgeText.b, 0.92)
        : Qt.rgba(secondaryText.r, secondaryText.g, secondaryText.b, 0.94)

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: 3
        color: "transparent"
        border.color: selected ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)
        border.width: 1
    }

    Row {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 12

        Rectangle {
            width: 28
            height: 28
            radius: 14
            anchors.verticalCenter: parent.verticalCenter
            color: medalCard.unlocked ? medalCard.badgeFill : medalCard.iconFill
            border.color: medalCard.cardBorder
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: medalCard.unlocked ? "★" : "?"
                color: medalCard.unlocked ? medalCard.badgeText : medalCard.unknownText
                font.pixelSize: 14
                font.bold: true
            }
        }

        Column {
            width: parent.width - 50
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                text: medalCard.unlocked && medalCard.modelData
                    ? medalCard.modelData.id
                    : "?????????"
                color: medalCard.titleInk
                font.family: medalCard.gameFont
                font.pixelSize: 12
                font.bold: true
            }

            Text {
                text: medalCard.unlocked && medalCard.modelData
                    ? "UNLOCKED"
                    : (medalCard.modelData ? medalCard.modelData.hint : "")
                color: medalCard.hintInk
                font.family: medalCard.gameFont
                font.pixelSize: 9
                opacity: 1.0
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }
    }

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 4
        anchors.topMargin: 4
        width: medalCard.unlocked ? 38 : 36
        height: 11
        radius: 3
        color: Qt.rgba(medalCard.selected ? medalCard.badgeText.r : medalCard.badgeFill.r,
                        medalCard.selected ? medalCard.badgeText.g : medalCard.badgeFill.g,
                        medalCard.selected ? medalCard.badgeText.b : medalCard.badgeFill.b,
                        medalCard.unlocked ? 0.22 : 0.14)
        border.color: medalCard.selected ? medalCard.badgeText : medalCard.cardBorder
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: medalCard.unlocked ? "DONE" : "LOCK"
            color: medalCard.selected ? medalCard.badgeText : medalCard.titleColor
            font.family: medalCard.gameFont
            font.pixelSize: 7
            font.bold: true
        }
    }
}
