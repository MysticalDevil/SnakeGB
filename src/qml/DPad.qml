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
    readonly property int crossSize: 84
    readonly property int pressX: (rightPressed ? 1 : 0) - (leftPressed ? 1 : 0)
    readonly property int pressY: (downPressed ? 1 : 0) - (upPressed ? 1 : 0)

    Item {
        id: crossRoot
        anchors.centerIn: parent
        width: dpad.crossSize
        height: dpad.crossSize
        x: dpad.pressX
        y: dpad.pressY

        Item {
            anchors.fill: parent
            x: 1
            y: 2
            opacity: 0.28
            Rectangle {
                anchors.centerIn: parent
                width: dpad.armThickness
                height: parent.height
                radius: 2
                color: "#000000"
            }
            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: dpad.armThickness
                radius: 2
                color: "#000000"
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: dpad.armThickness
            height: parent.height
            radius: 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#343b47" }
                GradientStop { position: 1.0; color: "#252b34" }
            }
            border.color: "#10161c"
            border.width: 2
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: dpad.armThickness
            radius: 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#343b47" }
                GradientStop { position: 1.0; color: "#252b34" }
            }
            border.color: "#10161c"
            border.width: 2
        }

        Rectangle {
            anchors.centerIn: parent
            width: dpad.armThickness - 4
            height: parent.height - 6
            radius: 1
            color: "transparent"
            border.color: Qt.rgba(1, 1, 1, 0.08)
            border.width: 1
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width - 6
            height: dpad.armThickness - 4
            radius: 1
            color: "transparent"
            border.color: Qt.rgba(1, 1, 1, 0.08)
            border.width: 1
        }

        Rectangle {
            x: (parent.width - dpad.armThickness) / 2
            y: 0
            width: dpad.armThickness
            height: (parent.height - dpad.armThickness) / 2 + 1
            color: Qt.rgba(0, 0, 0, 0.18)
            visible: dpad.upPressed
        }
        Rectangle {
            x: (parent.width - dpad.armThickness) / 2
            y: (parent.height + dpad.armThickness) / 2 - 1
            width: dpad.armThickness
            height: (parent.height - dpad.armThickness) / 2 + 1
            color: Qt.rgba(0, 0, 0, 0.18)
            visible: dpad.downPressed
        }
        Rectangle {
            x: 0
            y: (parent.height - dpad.armThickness) / 2
            width: (parent.width - dpad.armThickness) / 2 + 1
            height: dpad.armThickness
            color: Qt.rgba(0, 0, 0, 0.18)
            visible: dpad.leftPressed
        }
        Rectangle {
            x: (parent.width + dpad.armThickness) / 2 - 1
            y: (parent.height - dpad.armThickness) / 2
            width: (parent.width - dpad.armThickness) / 2 + 1
            height: dpad.armThickness
            color: Qt.rgba(0, 0, 0, 0.18)
            visible: dpad.rightPressed
        }

        Rectangle {
            anchors.centerIn: parent
            width: 20
            height: 20
            radius: 10
            color: "#151a20"
            border.color: "#0c1015"
            border.width: 1
        }

        Rectangle {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -1
            width: 12
            height: 5
            radius: 2
            color: Qt.rgba(1, 1, 1, 0.07)
        }
    }

    Item {
        anchors.fill: crossRoot
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
