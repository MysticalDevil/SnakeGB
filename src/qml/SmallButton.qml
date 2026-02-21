import QtQuick

Rectangle {
    id: root
    property string text: ""
    property bool isPressed: false
    signal clicked
    signal pressed
    signal released

    readonly property bool pressedVisual: mouseArea.pressed || isPressed

    width: 52
    height: 16
    radius: 8
    color: pressedVisual ? "#51555e" : "#6e7380"
    rotation: -20
    border.color: Qt.rgba(0.16, 0.18, 0.22, 0.65)
    border.width: 1

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: parent.radius - 1
        gradient: Gradient {
            GradientStop { position: 0.0; color: pressedVisual ? "#636875" : "#868c99" }
            GradientStop { position: 1.0; color: pressedVisual ? "#3e434c" : "#5b606b" }
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: parent.radius - 1
        color: "transparent"
        border.color: Qt.rgba(1, 1, 1, 0.2)
        border.width: 1
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: parent.radius - 4
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.15) }
            GradientStop { position: 0.5; color: "transparent" }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.14) }
        }
        opacity: 0.55
    }

    Text {
        text: root.text
        anchors.top: parent.bottom
        anchors.topMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 10
        font.bold: true
        color: "#2b2e33"
        font.family: "Trebuchet MS"
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "#17191d"
        opacity: 0.25
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
