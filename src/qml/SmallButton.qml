import QtQuick

Rectangle {
    id: root
    property string text: ""
    property bool isPressed: false
    signal clicked
    signal pressed
    signal released

    width: 40
    height: 12
    radius: 6
    color: (mouseArea.pressed || isPressed) ? "#444" : "#666"
    rotation: -20

    Text {
        text: root.text
        anchors.top: parent.bottom
        anchors.topMargin: 4
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 10
        font.bold: true
        color: "#333"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            root.clicked()
        }
        onPressed: {
            root.pressed()
        }
        onReleased: {
            root.released()
        }
    }
}
