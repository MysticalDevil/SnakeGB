import QtQuick
import QtQuick.Controls

Rectangle {
    id: shell
    anchors.fill: parent
    color: gameLogic.shellColor
    radius: 10
    border.color: Qt.darker(color, 1.2)
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

    // --- Screen Border ---
    Rectangle {
        id: screenBorder
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        width: 300
        height: 270
        color: "#404040"
        radius: 10

        Item {
            id: screenPlaceholder
            anchors.centerIn: parent
            width: 240
            height: 216
        }
    }

    // --- Branding / Color Toggle ---
    Text {
        anchors.top: screenBorder.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        text: "SnakeGB"
        color: Qt.darker(shell.color, 2.0)
        font.family: "Monospace"
        font.pixelSize: 14
        font.bold: true
        font.letterSpacing: 2
        opacity: 0.6

        MouseArea {
            anchors.fill: parent
            onClicked: {
                gameLogic.requestFeedback(5)
                gameLogic.nextShellColor()
            }
        }
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
        anchors.bottomMargin: 140
        anchors.right: parent.right
        anchors.rightMargin: 30
        spacing: 15
        rotation: -15
        GBButton { id: bBtnUI; text: "B" }
        GBButton { id: aBtnUI; text: "A" }
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 30
        SmallButton { id: selectBtnUI; text: "SELECT" }
        SmallButton { id: startBtnUI; text: "START" }
    }

    // --- Physical Volume Knob (Side Wheel) ---
    Rectangle {
        id: volumeKnobTrack
        anchors.right: parent.right
        anchors.rightMargin: -8
        anchors.top: parent.top
        anchors.topMargin: 150
        width: 16
        height: 80
        color: "#333"
        radius: 4
        clip: true
        border.color: "#222"
        border.width: 1

            Rectangle {
                id: volumeWheel
                width: parent.width
                height: 30
                color: "#444"
                radius: 2
                y: (1.0 - gameLogic.volume) * (parent.height - height)

                Column {
                    anchors.centerIn: parent
                    spacing: 2
                    Repeater {
                        model: 5
                        Rectangle { width: 12; height: 1; color: "#222" }
                    }
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
                        
                        // Haptic feedback every 10% volume change
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
            color: "#666"
            font.pixelSize: 8
            font.bold: true
        }
    }
}
