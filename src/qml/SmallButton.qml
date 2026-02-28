import QtQuick

Rectangle {
    id: root
    property string text: ""
    property bool isPressed: false
    signal clicked
    signal pressed
    signal released

    readonly property bool pressedVisual: mouseArea.pressed || isPressed
    readonly property color bodyShadow: "#17191d"
    readonly property color highlightTone: Qt.rgba(1, 1, 1, 0.10)
    readonly property color shadeTone: Qt.rgba(0, 0, 0, 0.08)

    width: 54
    height: 17
    radius: 8
    color: pressedVisual ? "#656d79" : "#7d8696"
    rotation: -20
    border.color: Qt.rgba(0.16, 0.18, 0.22, 0.42)
    border.width: 1

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: parent.radius - 1
        gradient: Gradient {
            GradientStop { position: 0.0; color: pressedVisual ? "#747e8d" : "#98a1b3" }
            GradientStop { position: 1.0; color: pressedVisual ? "#5a6473" : "#768091" }
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: parent.radius - 1
        color: "transparent"
        border.color: Qt.rgba(1, 1, 1, 0.10)
        border.width: 1
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: parent.radius - 4
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.highlightTone }
            GradientStop { position: 0.5; color: "transparent" }
            GradientStop { position: 1.0; color: root.shadeTone }
        }
        opacity: 0.36
    }

    Text {
        text: root.text
        anchors.top: parent.bottom
        anchors.topMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 10
        font.bold: true
        color: "#282d34"
        font.family: "Trebuchet MS"
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: root.bodyShadow
        opacity: 0.12
        z: -1
        visible: !pressedVisual
        transform: Translate { y: 2 }
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
