import QtQuick

Rectangle {
    id: root
    property string text: ""
    property var theme: ({})
    property bool pressedExternally: false
    signal clicked
    signal pressed
    signal released

    readonly property bool pressedVisual: mouseArea.pressed || pressedExternally
    readonly property color buttonBase: theme.wheelBody || "#7d8696"
    readonly property color buttonTop: theme.wheelBodyLight || "#98a1b3"
    readonly property color buttonBottom: theme.wheelBodyDark || "#768091"
    readonly property color buttonBorder: theme.shellBorder || Qt.rgba(0.16, 0.18, 0.22, 0.42)
    readonly property color labelColor: theme.buttonLabelInk || theme.brandInk || "#282d34"
    readonly property color bodyShadow: Qt.rgba(buttonBorder.r, buttonBorder.g, buttonBorder.b, 0.35)
    readonly property color highlightTone: Qt.rgba(1, 1, 1, 0.10)
    readonly property color shadeTone: Qt.rgba(0, 0, 0, 0.08)

    width: 54
    height: 17
    radius: 8
    color: pressedVisual ? Qt.darker(buttonBase, 1.08) : buttonBase
    rotation: -20
    border.color: Qt.rgba(buttonBorder.r, buttonBorder.g, buttonBorder.b, 0.52)
    border.width: 1

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: parent.radius - 1
        gradient: Gradient {
            GradientStop { position: 0.0; color: pressedVisual ? Qt.darker(buttonTop, 1.06) : buttonTop }
            GradientStop { position: 1.0; color: pressedVisual ? Qt.darker(buttonBottom, 1.06) : buttonBottom }
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
        color: labelColor
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
