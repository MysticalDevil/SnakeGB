import QtQuick

Rectangle {
    id: replayBanner
    property bool active: false
    property string gameFont: ""
    property var menuColor
    property string titleText: "REPLAY"
    property string hintText: "START MENU   SELECT MENU"

    width: 174
    height: 42
    radius: 4
    color: menuColor("actionCard")
    opacity: 0.98
    border.color: menuColor("borderPrimary")
    border.width: 1
    visible: active

    Column {
        anchors.centerIn: parent
        spacing: 2

        Text {
            text: replayBanner.titleText
            color: menuColor("actionInk")
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: true
            font.pixelSize: 12
        }

        Text {
            text: replayBanner.hintText
            color: menuColor("actionInk")
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 9
            font.bold: true
            opacity: 0.94
        }
    }
}
