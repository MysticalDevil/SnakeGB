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
    Rectangle {
        id: volumeKnobTrack
        anchors.right: parent.right
        anchors.rightMargin: -8
        anchors.top: parent.top
        anchors.topMargin: 150
        width: 18
        height: 92
        color: "#2b2e33"
        radius: 5
        clip: true
        border.color: "#171a1f"
        border.width: 1

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#3a3d44" }
                GradientStop { position: 0.5; color: "#262a30" }
                GradientStop { position: 1.0; color: "#1f2329" }
            }
        }

        Repeater {
            model: 10
            delegate: Rectangle {
                width: 7
                height: 1
                x: 2
                y: 7 + index * 8
                color: Qt.rgba(0, 0, 0, 0.35)
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 1
            width: 2
            height: parent.height - 2
            y: 1
            radius: 1
            color: Qt.rgba(1, 1, 1, 0.15)
        }

        Rectangle {
            id: volumeWheel
            width: parent.width - 2
            height: 30
            x: 1
            color: "#5b616e"
            radius: 3
            y: (1.0 - gameLogic.volume) * (parent.height - height)
            border.color: "#2a2f38"
            border.width: 1

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: parent.radius - 1
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#7a8291" }
                    GradientStop { position: 0.45; color: "#5d6471" }
                    GradientStop { position: 1.0; color: "#444b56" }
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: 2
                Repeater {
                    model: 6
                    Rectangle { width: 11; height: 1; color: "#262b33"; radius: 1 }
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.leftMargin: 2
                anchors.verticalCenter: parent.verticalCenter
                width: 2
                height: 8
                radius: 1
                color: "#c5ccd8"
                opacity: 0.85
            }

            MouseArea {
                anchors.fill: parent
                drag.target: volumeWheel
                drag.axis: Drag.YAxis
                drag.minimumY: 0
                drag.maximumY: volumeKnobTrack.height - volumeWheel.height
                
                property int lastStep: 0
                
                onPositionChanged: {
                    var normalized = 1.0 - (volumeWheel.y / (volumeKnobTrack.height - volumeWheel.height))
                    gameLogic.volume = normalized
                    
                    var currentStep = Math.floor(normalized * 10)
                    if (currentStep !== lastStep) {
                        gameLogic.requestFeedback(1)
                        lastStep = currentStep
                    }
                }
            }
        }
        Text {
            anchors.bottom: parent.top
            anchors.bottomMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            text: "VOL"
            color: "#4f545d"
            font.pixelSize: 8
            font.bold: true
        }
    }
}
