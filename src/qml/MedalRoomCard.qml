import QtQuick
import "icons" as Icons
import "components" as Components

Components.ListCardFrame {
    id: medalCard
    property var medalData
    property bool unlocked: false
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
    height: 62
    radius: 4
    normalFill: medalCard.cardNormal
    selectedFill: medalCard.cardSelected
    borderColor: medalCard.cardBorder

    readonly property color titleInk: selected ? badgeText : titleColor
    readonly property color hintInk: selected
        ? Qt.rgba(badgeText.r, badgeText.g, badgeText.b, 0.92)
        : Qt.rgba(secondaryText.r, secondaryText.g, secondaryText.b, 0.94)

    Row {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 12

        Icons.AchievementBadgeIcon {
            width: 36
            height: 36
            anchors.verticalCenter: parent.verticalCenter
            achievementId: medalCard.medalData ? String(medalCard.medalData.id) : ""
            borderColor: medalCard.cardBorder
            borderWidth: 1
            unlocked: medalCard.unlocked
            selected: medalCard.selected
            badgeFill: medalCard.badgeFill
            badgeText: medalCard.badgeText
            iconFill: medalCard.iconFill
            unknownText: medalCard.unknownText
        }

        Column {
            width: parent.width - 58
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                text: medalCard.unlocked && medalCard.medalData
                    ? medalCard.medalData.id
                    : "?????????"
                color: medalCard.titleInk
                font.family: medalCard.gameFont
                font.pixelSize: 12
                font.bold: true
            }

            Text {
                text: medalCard.unlocked && medalCard.medalData
                    ? "UNLOCKED"
                    : (medalCard.medalData ? medalCard.medalData.hint : "")
                color: medalCard.hintInk
                font.family: medalCard.gameFont
                font.pixelSize: 8
                font.bold: true
                opacity: 1.0
                width: parent.width
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }
    }

    Components.StatusPill {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 4
        anchors.topMargin: 4
        width: medalCard.unlocked ? 38 : 36
        height: 12
        color: Qt.rgba(medalCard.selected ? medalCard.badgeText.r : medalCard.badgeFill.r,
                        medalCard.selected ? medalCard.badgeText.g : medalCard.badgeFill.g,
                        medalCard.selected ? medalCard.badgeText.b : medalCard.badgeFill.b,
                        medalCard.unlocked ? 0.22 : 0.14)
        borderColor: medalCard.selected ? medalCard.badgeText : medalCard.cardBorder
        textColor: medalCard.selected ? medalCard.badgeText : medalCard.titleColor
        gameFont: medalCard.gameFont
        label: medalCard.unlocked ? "DONE" : "LOCK"
    }
}
