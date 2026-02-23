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
        color: "#13070a"
        opacity: 0.16
        visible: !pressedVisual
        z: -2
        transform: Translate { y: 3 }
    }

    Rectangle {
        id: buttonBody
        anchors.fill: parent
        radius: width / 2
        color: "#8a2a40"
        border.color: Qt.rgba(0.17, 0.04, 0.09, 0.58)
        border.width: 1

        transform: Translate {
            y: pressedVisual ? 3 : 0
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            radius: width / 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.lighter(buttonBody.color, 1.10) }
                GradientStop { position: 0.5; color: buttonBody.color }
                GradientStop { position: 1.0; color: Qt.darker(buttonBody.color, 1.08) }
            }
            opacity: 0.90
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: width / 2
            color: "transparent"
            border.color: Qt.rgba(1, 1, 1, 0.06)
            border.width: 1
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 7
            radius: width / 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.08) }
                GradientStop { position: 0.45; color: "transparent" }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.06) }
            }
            opacity: 0.32
        }

        Text {
            anchors.centerIn: parent
            text: root.text
            color: "#f3f3f3"
            font.bold: true
            font.pixelSize: 18
            font.family: "Trebuchet MS"
            style: Text.Normal
        }
    }

    Rectangle {
        anchors.fill: buttonBody
        radius: buttonBody.radius
        color: "black"
        opacity: 0.08
        z: -1
        visible: !pressedVisual
        transform: Translate { y: 1 }
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
            gameLogic.dispatchUiAction("feedback_ui")
            root.clicked()
        }
    }
}
