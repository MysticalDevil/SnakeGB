import QtQuick
import QtQuick.Controls

Item {
    id: dpad
    width: 96
    height: 96

    property bool upPressed: false
    property bool downPressed: false
    property bool leftPressed: false
    property bool rightPressed: false

    signal upClicked
    signal downClicked
    signal leftClicked
    signal rightClicked

    readonly property int armThickness: 30
    readonly property int crossSpan: 86
    readonly property int pressOffsetX: (rightPressed ? 1 : 0) - (leftPressed ? 1 : 0)
    readonly property int pressOffsetY: (downPressed ? 1 : 0) - (upPressed ? 1 : 0)

    Item {
        id: dpadVisual
        width: crossSpan
        height: crossSpan
        anchors.centerIn: parent
        x: dpad.pressOffsetX
        y: dpad.pressOffsetY

        // Shadow under one-piece cross.
        Item {
            anchors.fill: parent
            x: 1
            y: 2
            opacity: 0.25
            Rectangle {
                anchors.centerIn: parent
                width: dpad.armThickness
                height: parent.height
                radius: 2
                color: "black"
            }
            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: dpad.armThickness
                radius: 2
                color: "black"
            }
        }

        // Main plastic body.
        Item {
            anchors.fill: parent

            Rectangle {
                id: verticalArm
                anchors.centerIn: parent
                width: dpad.armThickness
                height: parent.height
                radius: 2
                color: "#2a2f36"
                border.color: "#141920"
                border.width: 2
            }

            Rectangle {
                id: horizontalArm
                anchors.centerIn: parent
                width: parent.width
                height: dpad.armThickness
                radius: 2
                color: "#2a2f36"
                border.color: "#141920"
                border.width: 2
            }

            // Bevel-like highlight and shade to avoid flat look.
            Rectangle {
                anchors.fill: verticalArm
                anchors.margins: 2
                radius: 1
                color: "transparent"
                border.color: Qt.rgba(1, 1, 1, 0.10)
                border.width: 1
            }

            Rectangle {
                anchors.fill: horizontalArm
                anchors.margins: 2
                radius: 1
                color: "transparent"
                border.color: Qt.rgba(1, 1, 1, 0.10)
                border.width: 1
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: Qt.rgba(0, 0, 0, 0.24)
                border.width: 1
                visible: false
            }
        }

        // Pressed arm tint.
        Rectangle {
            x: (crossSpan - dpad.armThickness) / 2
            y: 0
            width: dpad.armThickness
            height: (crossSpan - dpad.armThickness) / 2 + 2
            color: Qt.rgba(1, 1, 1, 0.11)
            visible: dpad.upPressed
        }
        Rectangle {
            x: (crossSpan - dpad.armThickness) / 2
            y: (crossSpan + dpad.armThickness) / 2 - 2
            width: dpad.armThickness
            height: (crossSpan - dpad.armThickness) / 2 + 2
            color: Qt.rgba(1, 1, 1, 0.11)
            visible: dpad.downPressed
        }
        Rectangle {
            x: 0
            y: (crossSpan - dpad.armThickness) / 2
            width: (crossSpan - dpad.armThickness) / 2 + 2
            height: dpad.armThickness
            color: Qt.rgba(1, 1, 1, 0.11)
            visible: dpad.leftPressed
        }
        Rectangle {
            x: (crossSpan + dpad.armThickness) / 2 - 2
            y: (crossSpan - dpad.armThickness) / 2
            width: (crossSpan - dpad.armThickness) / 2 + 2
            height: dpad.armThickness
            color: Qt.rgba(1, 1, 1, 0.11)
            visible: dpad.rightPressed
        }

        // Center pivot cap.
        Rectangle {
            anchors.centerIn: parent
            width: 22
            height: 22
            radius: 11
            color: "#171b21"
            border.color: "#0f1319"
            border.width: 1
        }

        Rectangle {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -1
            width: 14
            height: 7
            radius: 3
            color: Qt.rgba(1, 1, 1, 0.06)
        }

        // Subtle embossed arrows.
        Text {
            text: "▲"
            anchors.horizontalCenter: parent.horizontalCenter
            y: 8
            color: dpad.upPressed ? "#9ea6b3" : "#4c5562"
            font.pixelSize: 11
            font.bold: true
            opacity: 0.75
        }
        Text {
            text: "▼"
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height - 20
            color: dpad.downPressed ? "#9ea6b3" : "#4c5562"
            font.pixelSize: 11
            font.bold: true
            opacity: 0.75
        }
        Text {
            text: "◀"
            x: 8
            anchors.verticalCenter: parent.verticalCenter
            color: dpad.leftPressed ? "#9ea6b3" : "#4c5562"
            font.pixelSize: 11
            font.bold: true
            opacity: 0.72
        }
        Text {
            text: "▶"
            x: parent.width - 20
            anchors.verticalCenter: parent.verticalCenter
            color: dpad.rightPressed ? "#9ea6b3" : "#4c5562"
            font.pixelSize: 11
            font.bold: true
            opacity: 0.72
        }
    }

    // Hit areas.
    Item {
        anchors.fill: dpadVisual
        anchors.centerIn: parent

        MouseArea {
            x: (parent.width - dpad.armThickness) / 2
            y: 0
            width: dpad.armThickness
            height: (parent.height - dpad.armThickness) / 2 + 8
            onPressed: { dpad.upPressed = true; dpad.upClicked() }
            onReleased: dpad.upPressed = false
            onCanceled: dpad.upPressed = false
        }

        MouseArea {
            x: (parent.width - dpad.armThickness) / 2
            y: (parent.height + dpad.armThickness) / 2 - 8
            width: dpad.armThickness
            height: (parent.height - dpad.armThickness) / 2 + 8
            onPressed: { dpad.downPressed = true; dpad.downClicked() }
            onReleased: dpad.downPressed = false
            onCanceled: dpad.downPressed = false
        }

        MouseArea {
            x: 0
            y: (parent.height - dpad.armThickness) / 2
            width: (parent.width - dpad.armThickness) / 2 + 8
            height: dpad.armThickness
            onPressed: { dpad.leftPressed = true; dpad.leftClicked() }
            onReleased: dpad.leftPressed = false
            onCanceled: dpad.leftPressed = false
        }

        MouseArea {
            x: (parent.width + dpad.armThickness) / 2 - 8
            y: (parent.height - dpad.armThickness) / 2
            width: (parent.width - dpad.armThickness) / 2 + 8
            height: dpad.armThickness
            onPressed: { dpad.rightPressed = true; dpad.rightClicked() }
            onReleased: dpad.rightPressed = false
            onCanceled: dpad.rightPressed = false
        }
    }
}
