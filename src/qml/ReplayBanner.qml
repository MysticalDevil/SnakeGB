import QtQuick

Rectangle {
    id: replayBanner
    property bool active: false
    property string gameFont: ""
    property var menuColor
    property string titleText: "REPLAY"
    property string hintText: "START MENU   SELECT MENU"

    width: 152
    height: hintText.length > 0 ? 38 : 24
    radius: 4
    color: menuColor("actionCard")
    opacity: 0.98
    border.color: menuColor("borderPrimary")
    border.width: 1
    visible: active

    Column {
        anchors.centerIn: parent
        spacing: hintText.length > 0 ? 2 : 0

        Text {
            text: replayBanner.titleText
            color: menuColor("actionInk")
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: true
            font.pixelSize: 11
        }

        Text {
            visible: replayBanner.hintText.length > 0
            text: replayBanner.hintText
            color: menuColor("actionInk")
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 8
            font.bold: true
            opacity: 0.94
        }
    }
}
