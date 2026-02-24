import QtQuick

Rectangle {
    id: medalCard
    property var modelData
    property var gameLogic
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
    height: 48
    color: selected ? cardSelected : cardNormal
    border.color: cardBorder
    border.width: selected ? 2 : 1

    readonly property bool unlocked: gameLogic && modelData
        ? gameLogic.achievements.indexOf(modelData.id) !== -1
        : false
    readonly property color titleInk: selected ? badgeText : titleColor
    readonly property color hintInk: selected
        ? Qt.rgba(badgeText.r, badgeText.g, badgeText.b, 0.92)
        : Qt.rgba(secondaryText.r, secondaryText.g, secondaryText.b, 0.94)

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
}
