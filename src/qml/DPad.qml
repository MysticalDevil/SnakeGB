import QtQuick
import QtQuick.Controls

Item {
    id: dpad
    width: 102
    height: 102

    property bool upPressed: false
    property bool downPressed: false
    property bool leftPressed: false
    property bool rightPressed: false

    signal upClicked
    signal downClicked
    signal leftClicked
    signal rightClicked

    readonly property int armThickness: 34
    readonly property int crossSize: 94
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
            opacity: 0.24
            Rectangle {
                anchors.centerIn: parent
                width: dpad.armThickness
                height: parent.height
                radius: 1
                color: "#000000"
            }
            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: dpad.armThickness
                radius: 1
                color: "#000000"
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: dpad.armThickness
            height: parent.height
            radius: 1
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#465063" }
                GradientStop { position: 0.5; color: "#353f4f" }
                GradientStop { position: 1.0; color: "#252d39" }
            }
            border.color: "#0f141a"
            border.width: 2
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: dpad.armThickness
            radius: 1
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#465063" }
                GradientStop { position: 0.5; color: "#353f4f" }
                GradientStop { position: 1.0; color: "#252d39" }
            }
            border.color: "#0f141a"
            border.width: 2
        }

        Canvas {
            id: embossMarks
            anchors.fill: parent
            opacity: 0.34
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()

                var light = "rgba(170, 182, 198, 0.34)"
                var dark = "rgba(15, 20, 26, 0.55)"

                // Up mark
                ctx.fillStyle = dark
                ctx.beginPath()
                ctx.moveTo(width / 2, 14)
                ctx.lineTo(width / 2 - 5, 22)
                ctx.lineTo(width / 2 + 5, 22)
                ctx.closePath()
                ctx.fill()
                ctx.fillStyle = light
                ctx.beginPath()
                ctx.moveTo(width / 2, 13)
                ctx.lineTo(width / 2 - 4, 20)
                ctx.lineTo(width / 2 + 4, 20)
                ctx.closePath()
                ctx.fill()

                // Down mark
                ctx.fillStyle = dark
                ctx.beginPath()
                ctx.moveTo(width / 2 - 5, height - 22)
                ctx.lineTo(width / 2 + 5, height - 22)
                ctx.lineTo(width / 2, height - 14)
                ctx.closePath()
                ctx.fill()
                ctx.fillStyle = light
                ctx.beginPath()
                ctx.moveTo(width / 2 - 4, height - 21)
                ctx.lineTo(width / 2 + 4, height - 21)
                ctx.lineTo(width / 2, height - 14)
                ctx.closePath()
                ctx.fill()

                // Left mark
                ctx.fillStyle = dark
                ctx.beginPath()
                ctx.moveTo(14, height / 2)
                ctx.lineTo(22, height / 2 - 5)
                ctx.lineTo(22, height / 2 + 5)
                ctx.closePath()
                ctx.fill()
                ctx.fillStyle = light
                ctx.beginPath()
                ctx.moveTo(13, height / 2)
                ctx.lineTo(20, height / 2 - 4)
                ctx.lineTo(20, height / 2 + 4)
                ctx.closePath()
                ctx.fill()

                // Right mark
                ctx.fillStyle = dark
                ctx.beginPath()
                ctx.moveTo(width - 22, height / 2 - 5)
                ctx.lineTo(width - 14, height / 2)
                ctx.lineTo(width - 22, height / 2 + 5)
                ctx.closePath()
                ctx.fill()
                ctx.fillStyle = light
                ctx.beginPath()
                ctx.moveTo(width - 21, height / 2 - 4)
                ctx.lineTo(width - 14, height / 2)
                ctx.lineTo(width - 21, height / 2 + 4)
                ctx.closePath()
                ctx.fill()
            }
            Component.onCompleted: requestPaint()
        }

        Rectangle {
            anchors.centerIn: parent
            width: dpad.armThickness - 5
            height: parent.height - 8
            radius: 1
            color: "transparent"
            border.color: Qt.rgba(1, 1, 1, 0.12)
            border.width: 1
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width - 8
            height: dpad.armThickness - 5
            radius: 1
            color: "transparent"
            border.color: Qt.rgba(1, 1, 1, 0.12)
            border.width: 1
        }

        Rectangle {
            x: (parent.width - dpad.armThickness) / 2
            y: 0
            width: dpad.armThickness
            height: (parent.height - dpad.armThickness) / 2 + 1
            color: Qt.rgba(0, 0, 0, 0.24)
            visible: dpad.upPressed
        }
        Rectangle {
            x: (parent.width - dpad.armThickness) / 2
            y: (parent.height + dpad.armThickness) / 2 - 1
            width: dpad.armThickness
            height: (parent.height - dpad.armThickness) / 2 + 1
            color: Qt.rgba(0, 0, 0, 0.24)
            visible: dpad.downPressed
        }
        Rectangle {
            x: 0
            y: (parent.height - dpad.armThickness) / 2
            width: (parent.width - dpad.armThickness) / 2 + 1
            height: dpad.armThickness
            color: Qt.rgba(0, 0, 0, 0.24)
            visible: dpad.leftPressed
        }
        Rectangle {
            x: (parent.width + dpad.armThickness) / 2 - 1
            y: (parent.height - dpad.armThickness) / 2
            width: (parent.width - dpad.armThickness) / 2 + 1
            height: dpad.armThickness
            color: Qt.rgba(0, 0, 0, 0.24)
            visible: dpad.rightPressed
        }

        Rectangle {
            anchors.centerIn: parent
            width: 18
            height: 18
            radius: 9
            color: "#161d25"
            border.color: "#0b1015"
            border.width: 1
        }

        Rectangle {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -1
            width: 10
            height: 4
            radius: 2
            color: Qt.rgba(1, 1, 1, 0.06)
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
