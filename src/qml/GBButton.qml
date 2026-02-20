import QtQuick
import QtQuick.Controls

Item {
    id: root
    property string text: ""
    property bool isPressed: false
    signal clicked

    width: 55
    height: 55

    Rectangle {
        id: buttonBody
        anchors.fill: parent
        radius: width / 2
        color: "#a01020" // Classic GB Red
        border.color: Qt.darker(color, 1.5)
        border.width: 3

        // Pressed-state offset
        transform: Translate {
            y: mouseArea.pressed || root.isPressed ? 3 : 0
        }

        // Top highlight
        Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            radius: width / 2
            color: "transparent"
            border.color: Qt.lighter(buttonBody.color, 1.5)
            border.width: 2
            opacity: 0.3
        }

        Text {
            anchors.centerIn: parent
            text: root.text
            color: "white"
            font.bold: true
            font.pixelSize: 20
            font.family: "Verdana"
        }
    }

    // Bottom drop shadow
    Rectangle {
        anchors.fill: buttonBody
        radius: buttonBody.radius
        color: "black"
        opacity: 0.3
        z: -1
        visible: !(mouseArea.pressed || root.isPressed)
        transform: Translate { y: 4 }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onPressed: {
            root.isPressed = true
        }
        onReleased: {
            root.isPressed = false
        }
        onClicked: {
            gameLogic.requestFeedback(5)
            root.clicked()
        }
    }
}
