import QtQuick

Item {
    id: root
    width: 50
    height: 50
    property string text: ""
    property bool isPressed: false
    signal clicked()

    Rectangle {
        id: body
        anchors.fill: parent
        radius: width / 2
        color: root.isPressed ? "#800020" : "#a81830" // Sinking color
        border.color: Qt.darker(color, 1.2)
        border.width: 2

        // Outer Glow when pressed
        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            radius: width / 2
            color: gameLogic.palette[2]
            opacity: root.isPressed ? 0.3 : 0
            z: -1
            Behavior on opacity { NumberAnimation { duration: 50 } }
        }

        Text {
            anchors.centerIn: parent
            text: root.text
            color: "white"
            font.bold: true
            font.pixelSize: 18
        }

        // Translation for "Physical" feel
        transform: Translate { 
            x: root.isPressed ? 1 : 0
            y: root.isPressed ? 2 : 0 
        }
    }

    MouseArea {
        anchors.fill: parent
        onPressed: { root.isPressed = true; root.clicked() }
        onReleased: root.isPressed = false
        onCanceled: root.isPressed = false
    }
}
