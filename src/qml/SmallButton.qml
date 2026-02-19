import QtQuick

Rectangle {
    id: root
    property string text: ""
    property bool isPressed: false
    signal clicked

    width: 40; height: 12; radius: 6
    color: (mouseArea.pressed || isPressed) ? "#444" : "#666"
    rotation: -20 // GB 经典的倾斜角度

    Text {
        text: root.text
        anchors.top: parent.bottom; anchors.topMargin: 4
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 10; font.bold: true; color: "#333"
    }

    MouseArea {
        id: mouseArea; anchors.fill: parent; onClicked: root.clicked()
    }
}
