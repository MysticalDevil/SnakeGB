import QtQuick
import QtQuick.Controls

Rectangle {
    id: shell
    anchors.fill: parent
    property color shellColor: "#4aa3a8"
    property real volume: 1.0

    signal shellColorToggleRequested()
    signal volumeRequested(real value, bool withHaptic)

    color: shell.shellColor
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
                shell.shellColorToggleRequested()
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

    // --- Physical Volume Wheel (Game Boy side thumbwheel style) ---
    Item {
        id: volumeControl
        anchors.right: parent.right
        anchors.rightMargin: -6
        anchors.top: parent.top
        anchors.topMargin: 156
        width: 27
        height: 88
        property int detentCount: 16

        function clamp01(v) {
            return Math.max(0.0, Math.min(1.0, v))
        }

        function setDetentVolume(v, withHaptic) {
            var clamped = clamp01(v)
            var snapped = Math.round(clamped * (detentCount - 1)) / (detentCount - 1)
            var oldStep = Math.round(shell.volume * (detentCount - 1))
            var newStep = Math.round(snapped * (detentCount - 1))
            if (Math.abs(snapped - shell.volume) > 0.0001) {
                shell.volumeRequested(snapped, withHaptic && oldStep !== newStep)
            }
        }

        // Molded side opening where the wheel sits.
        Rectangle {
            id: sideCut
            x: 0
            y: 5
            width: 9
            height: parent.height - 10
            radius: 4
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#30404f" }
                GradientStop { position: 0.5; color: "#1f2a35" }
                GradientStop { position: 1.0; color: "#2e3c4a" }
            }
            border.color: "#162029"
            border.width: 1
            opacity: 0.96
        }

        Rectangle {
            anchors.fill: sideCut
            anchors.margins: 1
            radius: sideCut.radius - 1
            color: "transparent"
            border.color: Qt.rgba(1, 1, 1, 0.07)
            border.width: 1
        }

        Item {
            id: wheelViewport
            x: 8
            y: 4
            width: 14
            height: parent.height - 8
            clip: true

            Rectangle {
                id: wheelBody
                anchors.fill: parent
                radius: 7
                color: "#5f6776"
                border.color: "#333a45"
                border.width: 1
                property real spinPhase: shell.volume * 90
                property real groovePitch: 5

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 1
                    radius: parent.radius - 1
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#8f9aae" }
                        GradientStop { position: 0.5; color: "#6c7689" }
                        GradientStop { position: 1.0; color: "#4c5564" }
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.top: parent.top
                    anchors.topMargin: 2
                    width: 2
                    height: parent.height - 4
                    radius: 1
                    color: Qt.rgba(1, 1, 1, 0.11)
                }

                Repeater {
                    model: Math.ceil(wheelBody.height / wheelBody.groovePitch) + 3
                    delegate: Rectangle {
                        required property int index
                        width: wheelBody.width - 3
                        height: 1
                        radius: 1
                        x: 1.5
                        property real yPos: index * wheelBody.groovePitch - (wheelBody.spinPhase % wheelBody.groovePitch) - wheelBody.groovePitch
                        y: yPos
                        visible: yPos >= 1 && yPos <= wheelBody.height - 2
                        color: "#2b3440"
                        opacity: 0.48
                    }
                }
            }

            Rectangle {
                anchors.fill: wheelBody
                radius: wheelBody.radius
                color: "transparent"
                border.color: Qt.rgba(0, 0, 0, 0.16)
                border.width: 1
            }

            MouseArea {
                anchors.fill: parent
                property real startY: 0.0
                property real startVolume: 0.0
                onPressed: {
                    startY = mouse.y
                    startVolume = shell.volume
                }
                onPositionChanged: {
                    if (!pressed) return
                    var delta = (startY - mouse.y) / 76.0
                    volumeControl.setDetentVolume(startVolume + delta, true)
                }
            }

            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: (event) => {
                    var step = (event.angleDelta.y > 0 ? 1 : -1) / Math.max(1, volumeControl.detentCount - 1)
                    volumeControl.setDetentVolume(shell.volume + step, true)
                }
            }
        }

        Text {
            x: 1
            y: sideCut.y + sideCut.height / 2 - 10
            rotation: 90
            text: "VOL"
            font.pixelSize: 9
            font.bold: true
            color: Qt.rgba(0, 0, 0, 0.28)
            opacity: 0.72
        }
    }
}
