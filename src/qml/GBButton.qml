import QtQuick
import QtQuick.Controls

Item {
    id: root
    property string text: ""
    property bool pressedExternally: false
    signal clicked

    width: 62
    height: 62

    readonly property bool pressedVisual: mouseArea.pressed || root.pressedExternally
    readonly property color baseShadow: "#12080b"
    readonly property color rimShadow: "#210a10"
    readonly property color highlightTone: Qt.rgba(1, 1, 1, 0.10)
    readonly property color shadeTone: Qt.rgba(0, 0, 0, 0.08)

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: root.baseShadow
        opacity: 0.18
        visible: !pressedVisual
        z: -2
        transform: Translate { y: 4 }
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
                GradientStop { position: 0.0; color: Qt.lighter(buttonBody.color, 1.12) }
                GradientStop { position: 0.44; color: buttonBody.color }
                GradientStop { position: 1.0; color: Qt.darker(buttonBody.color, 1.10) }
            }
            opacity: 0.92
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: width / 2
            color: "transparent"
            border.color: Qt.rgba(1, 1, 1, 0.07)
            border.width: 1
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
            font.pixelSize: 18
            font.family: "Trebuchet MS"
            style: Text.Normal
        }
    }

    Rectangle {
        anchors.fill: buttonBody
        radius: buttonBody.radius
        color: root.rimShadow
        opacity: 0.10
        z: -1
        visible: !pressedVisual
        transform: Translate { y: 2 }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            engineAdapter.dispatchUiAction("feedback_ui")
            root.clicked()
        }
    }
}
