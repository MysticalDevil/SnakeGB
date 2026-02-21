import QtQuick
import QtQuick.Controls

Item {
    id: root
    property string text: ""
    property bool isPressed: false
    signal clicked

    width: 62
    height: 62

    readonly property bool pressedVisual: mouseArea.pressed || root.isPressed

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "#26070c"
        opacity: 0.36
        visible: !pressedVisual
        z: -2
        transform: Translate { y: 5 }
    }

    Rectangle {
        id: buttonBody
        anchors.fill: parent
        radius: width / 2
        color: "#8f1b2f"
        border.color: Qt.rgba(0.18, 0.04, 0.08, 0.75)
        border.width: 1

        transform: Translate {
            y: pressedVisual ? 3 : 0
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            radius: width / 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.lighter(buttonBody.color, 1.25) }
                GradientStop { position: 0.45; color: buttonBody.color }
                GradientStop { position: 1.0; color: Qt.darker(buttonBody.color, 1.22) }
            }
            opacity: 0.95
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: width / 2
            color: "transparent"
            border.color: Qt.rgba(1, 1, 1, 0.10)
            border.width: 1
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 7
            radius: width / 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.18) }
                GradientStop { position: 0.45; color: "transparent" }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.14) }
            }
            opacity: 0.55
        }

        Text {
            anchors.centerIn: parent
            text: root.text
            color: "#f3f3f3"
            font.bold: true
            font.pixelSize: 19
            font.family: "Trebuchet MS"
            style: Text.Raised
            styleColor: "#3b0f16"
        }
    }

    Rectangle {
        anchors.fill: buttonBody
        radius: buttonBody.radius
        color: "black"
        opacity: 0.2
        z: -1
        visible: !pressedVisual
        transform: Translate { y: 3 }
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
