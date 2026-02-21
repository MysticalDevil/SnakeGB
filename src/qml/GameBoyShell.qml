import QtQuick
import QtQuick.Controls

Rectangle {
    id: shell
    anchors.fill: parent
    color: gameLogic.shellColor
    radius: 16
    border.color: Qt.darker(color, 1.35)
    border.width: 2

    property alias screenContainer: screenPlaceholder
    property alias dpad: dpadUI
    property alias bButton: bBtnUI
    property alias aButton: aBtnUI
    property alias selectButton: selectBtnUI
    property alias startButton: startBtnUI

    Behavior on color {
        ColorAnimation { duration: 300 }
    }

    Rectangle {
        anchors.fill: parent
        radius: shell.radius
        color: "transparent"
        border.color: Qt.lighter(shell.color, 1.22)
        border.width: 1
        opacity: 0.5
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: shell.radius - 2
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.lighter(shell.color, 1.16) }
            GradientStop { position: 0.28; color: Qt.lighter(shell.color, 1.06) }
            GradientStop { position: 1.0; color: Qt.darker(shell.color, 1.12) }
        }
        opacity: 0.42
    }

    Repeater {
        model: 48
        delegate: Rectangle {
            width: 2
            height: 2
            radius: 1
            x: 10 + (index % 12) * 28
            y: 14 + Math.floor(index / 12) * 72
            color: Qt.rgba(0, 0, 0, 0.06)
        }
    }

    // --- Screen Border ---
    Rectangle {
        id: screenBorder
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        width: 300
        height: 270
        color: "#3c3f45"
        radius: 12
        border.color: "#202328"
        border.width: 2

        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            radius: parent.radius - 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#50545c" }
                GradientStop { position: 1.0; color: "#2e3137" }
            }
            opacity: 0.72
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 10
            radius: 8
            color: "#111417"
            border.color: "#5c6068"
            border.width: 1
        }

        Item {
            id: screenPlaceholder
            anchors.centerIn: parent
            width: 240
            height: 216
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.top: parent.top
            anchors.topMargin: 8
            text: "DOT MATRIX WITH STEREO SOUND"
            color: "#9fa3ac"
            font.pixelSize: 8
            font.bold: true
            opacity: 0.75
        }
    }

    // --- Branding / Color Toggle ---
    Text {
        anchors.top: screenBorder.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        text: "SnakeGB"
        color: Qt.darker(shell.color, 2.2)
        font.family: "Monospace"
        font.pixelSize: 14
        font.bold: true
        font.letterSpacing: 2
        opacity: 0.68

        MouseArea {
            anchors.fill: parent
            onClicked: {
                gameLogic.requestFeedback(5)
                gameLogic.nextShellColor()
            }
        }
    }

    Text {
        anchors.top: screenBorder.bottom
        anchors.topMargin: 32
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Portable Entertainment System"
        color: Qt.darker(shell.color, 2.0)
        font.pixelSize: 8
        font.italic: true
        opacity: 0.6
    }

    // --- Controls ---
    DPad {
        id: dpadUI
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 110
        anchors.left: parent.left
        anchors.leftMargin: 25
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 132
        anchors.right: parent.right
        anchors.rightMargin: 22
        spacing: 18
        rotation: -15
        GBButton { id: bBtnUI; text: "B" }
        GBButton { id: aBtnUI; text: "A" }
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 36
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 28
        SmallButton { id: selectBtnUI; text: "SELECT" }
        SmallButton { id: startBtnUI; text: "START" }
    }

    Item {
        anchors.right: parent.right
        anchors.rightMargin: 30
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 48
        width: 96
        height: 56
        rotation: -20
        opacity: 0.72

        Repeater {
            model: 6
            delegate: Rectangle {
                width: 52
                height: 2
                radius: 1
                x: 20 + index * 5
                y: 8 + index * 8
                color: "#25272b"
            }
        }
    }

    // --- Physical Volume Knob (Side Wheel) ---
    Item {
        id: volumeKnobTrack
        anchors.right: parent.right
        anchors.rightMargin: -12
        anchors.top: parent.top
        anchors.topMargin: 134
        width: 34
        height: 116
        property real wheelMinY: 10
        property real wheelMaxY: 82
        property int detentCount: 15

        function clamp01(v) {
            return Math.max(0.0, Math.min(1.0, v))
        }

        function setDetentVolume(v, withHaptic) {
            var clamped = clamp01(v)
            var snapped = Math.round(clamped * (detentCount - 1)) / (detentCount - 1)
            if (Math.abs(snapped - gameLogic.volume) > 0.0001) {
                gameLogic.volume = snapped
                if (withHaptic) {
                    gameLogic.requestFeedback(1)
                }
            }
        }

        Text {
            anchors.right: parent.left
            anchors.rightMargin: 1
            anchors.top: parent.top
            anchors.topMargin: 6
            text: "VOLUME"
            rotation: -90
            transformOrigin: Item.TopRight
            color: Qt.rgba(0, 0, 0, 0.45)
            font.pixelSize: 7
            font.bold: true
        }

        Rectangle {
            id: slotBody
            x: 9
            y: 8
            width: 14
            height: 94
            radius: 7
            color: "#20242a"
            border.color: "#15181d"
            border.width: 1

            MouseArea {
                anchors.fill: parent
                onPressed: {
                    var normalized = 1.0 - ((mouse.y - 2) / (slotBody.height - 4))
                    volumeKnobTrack.setDetentVolume(normalized, true)
                }
            }
        }

        Rectangle {
            anchors.fill: slotBody
            anchors.margins: 1
            radius: slotBody.radius - 1
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#373c44" }
                GradientStop { position: 0.45; color: "#22262c" }
                GradientStop { position: 1.0; color: "#171b21" }
            }
            opacity: 0.88
        }

        Repeater {
            model: 9
            delegate: Rectangle {
                width: 4
                height: 1
                x: 11
                y: 14 + index * 10
                color: Qt.rgba(0, 0, 0, 0.34)
            }
        }

        Rectangle {
            id: volumeWheel
            width: 20
            height: 22
            x: 12
            y: volumeKnobTrack.wheelMinY +
               (1.0 - gameLogic.volume) * (volumeKnobTrack.wheelMaxY - volumeKnobTrack.wheelMinY)
            radius: 6
            color: "#626a78"
            border.color: "#2a2f37"
            border.width: 1

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: parent.radius - 1
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#8a94a6" }
                    GradientStop { position: 0.42; color: "#687182" }
                    GradientStop { position: 1.0; color: "#4b5260" }
                }
            }

            Repeater {
                model: 5
                delegate: Rectangle {
                    width: 1
                    height: 14
                    x: 4 + index * 3
                    y: 4
                    radius: 1
                    color: "#2f353f"
                }
            }

            MouseArea {
                anchors.fill: parent
                property real dragOffsetY: 0.0
                onPressed: {
                    dragOffsetY = mouse.y
                }
                onPositionChanged: {
                    if (!pressed) return
                    var localY = volumeWheel.y + mouse.y - dragOffsetY
                    var normalized = 1.0 - ((localY - volumeKnobTrack.wheelMinY) /
                                             (volumeKnobTrack.wheelMaxY - volumeKnobTrack.wheelMinY))
                    volumeKnobTrack.setDetentVolume(normalized, true)
                }
            }

            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: (event) => {
                    var step = (event.angleDelta.y > 0 ? 1 : -1) / Math.max(1, volumeKnobTrack.detentCount - 1)
                    volumeKnobTrack.setDetentVolume(gameLogic.volume + step, true)
                }
            }
        }
    }
}
