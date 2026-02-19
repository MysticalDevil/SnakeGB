import QtQuick

Rectangle {
    id: root
    property alias text: label.text
    property color buttonColor: "#a01040"
    property color pressedColor: Qt.darker(buttonColor, 1.2)
    signal clicked

    width: 50
    height: 50
    radius: width / 2
    color: mouseArea.pressed ? pressedColor : buttonColor
    border.color: "#333"
    border.width: 2

    scale: mouseArea.pressed ? 0.95 : 1.0

    Behavior on scale { NumberAnimation { duration: 50 } }
    Behavior on color { ColorAnimation { duration: 50 } }

    Text {
        id: label
        anchors.top: parent.bottom
        anchors.topMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        font.bold: true
        color: "#333"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
