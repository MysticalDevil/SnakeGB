import QtQuick
import QtQuick.Controls

Item {
    id: root
    property string text: ""
    property var commandController: null
    property bool pressedExternally: false
    signal clicked

    width: 62
    height: 62

    readonly property bool pressedVisual: mouseArea.pressed || root.pressedExternally
    readonly property real faceSize: 52
    readonly property color highlightTone: Qt.rgba(1, 1, 1, 0.10)
    readonly property color shadeTone: Qt.rgba(0, 0, 0, 0.08)

    Rectangle {
        anchors.centerIn: parent
        width: root.faceSize + 4
        height: root.faceSize + 4
        radius: width / 2
        color: Qt.rgba(0, 0, 0, 0.06)
        z: -2
    }

    Rectangle {
        id: buttonBody
        anchors.centerIn: parent
        width: root.faceSize
        height: root.faceSize
        radius: width / 2
        color: "#8a2a40"
        border.color: Qt.rgba(0.17, 0.04, 0.09, 0.44)
        border.width: 1

        transform: Translate {
            y: pressedVisual ? 1 : -1
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            radius: width / 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.lighter(buttonBody.color, 1.12) }
                GradientStop { position: 0.44; color: buttonBody.color }
                GradientStop { position: 1.0; color: Qt.darker(buttonBody.color, 1.10) }
            }
            opacity: 0.92
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 7
            radius: width / 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: root.highlightTone }
                GradientStop { position: 0.45; color: "transparent" }
                GradientStop { position: 1.0; color: root.shadeTone }
            }
            opacity: 0.38
        }

        Text {
            anchors.centerIn: parent
            text: root.text
            color: "#f3f3f3"
            font.bold: true
            font.pixelSize: 16
            font.family: "Trebuchet MS"
            style: Text.Normal
        }
    }

    Rectangle {
        anchors.fill: buttonBody
        radius: buttonBody.radius
        color: Qt.rgba(0, 0, 0, 0.08)
        z: -1
        visible: !pressedVisual
        transform: Translate { y: 1 }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            if (root.commandController) {
                root.commandController.dispatch("feedback_ui")
            }
            root.clicked()
        }
    }
}
