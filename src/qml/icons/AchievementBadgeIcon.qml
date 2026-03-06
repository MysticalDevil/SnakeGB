import QtQuick

IconFrame {
    id: badgeIcon

    property string achievementId: ""
    property bool unlocked: false
    property bool selected: false
    property color badgeFill: "white"
    property color badgeText: "black"
    property color iconFill: "black"
    property color unknownText: "white"

    radius: width / 2
    borderWidth: 2

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: width / 2
        color: "transparent"
        border.color: badgeIcon.unlocked
            ? Qt.rgba(badgeIcon.badgeText.r, badgeIcon.badgeText.g, badgeIcon.badgeText.b, 0.65)
            : Qt.rgba(badgeIcon.badgeFill.r, badgeIcon.badgeFill.g, badgeIcon.badgeFill.b, 0.55)
        border.width: 1
    }

    fillColor: unlocked ? badgeFill : iconFill

    AchievementGlyph {
        anchors.fill: parent
        anchors.margins: 4
        achievementId: badgeIcon.achievementId
        glyphColor: badgeIcon.unlocked ? badgeIcon.badgeText : badgeIcon.unknownText
        opacity: badgeIcon.unlocked ? 1.0 : 0.78
    }

    Rectangle {
        visible: !badgeIcon.unlocked
        width: Math.max(9, parent.width * 0.38)
        height: width
        radius: width / 2
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: -1
        anchors.bottomMargin: -1
        color: badgeIcon.badgeFill
        border.color: badgeIcon.badgeText
        border.width: 1
    }

    Text {
        visible: !badgeIcon.unlocked
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: parent.width * 0.18
        anchors.verticalCenterOffset: parent.height * 0.18
        text: "?"
        color: badgeIcon.badgeText
        font.pixelSize: Math.max(8, Math.floor(Math.min(parent.width, parent.height) * 0.24))
        font.bold: true
    }
}
