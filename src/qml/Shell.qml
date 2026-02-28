import QtQuick
import QtQuick.Controls
import "ThemeCatalog.js" as ThemeCatalog

Rectangle {
    id: shell
    anchors.fill: parent
    property color shellColor: "#4aa3a8"
    property string shellThemeName: "Teal"
    property real volume: 1.0
    property var bridge: null
    readonly property var shellTheme: ThemeCatalog.shellTheme(shellThemeName, shellColor)

    color: shell.shellColor
    radius: 16
    border.color: shell.shellTheme.shellBorder
    border.width: 2

    default property alias screenContent: screenBorder.content

    Behavior on color {
        ColorAnimation { duration: 300 }
    }

    ShellSurface {
        anchors.fill: parent
        shellColor: shell.shellColor
        shellTheme: shell.shellTheme
        radius: shell.radius
    }

    // --- Screen Border ---
    ScreenBezel {
        id: screenBorder
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        theme: shell.shellTheme
    }

    // --- Branding / Color Toggle ---
    ShellBranding {
        anchors.top: screenBorder.bottom
        anchors.topMargin: 12
        anchors.horizontalCenter: parent.horizontalCenter
        width: screenBorder.width
        theme: shell.shellTheme
        onLogoClicked: {
            if (shell.bridge) {
                shell.bridge.shellColorToggleRequested()
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
        externalUpPressed: shell.bridge ? shell.bridge.upPressed : false
        externalDownPressed: shell.bridge ? shell.bridge.downPressed : false
        externalLeftPressed: shell.bridge ? shell.bridge.leftPressed : false
        externalRightPressed: shell.bridge ? shell.bridge.rightPressed : false
        onUpClicked: {
            if (shell.bridge) {
                shell.bridge.directionRequested(0, -1)
            }
        }
        onDownClicked: {
            if (shell.bridge) {
                shell.bridge.directionRequested(0, 1)
            }
        }
        onLeftClicked: {
            if (shell.bridge) {
                shell.bridge.directionRequested(-1, 0)
            }
        }
        onRightClicked: {
            if (shell.bridge) {
                shell.bridge.directionRequested(1, 0)
            }
        }
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 132
        anchors.right: parent.right
        anchors.rightMargin: 22
        spacing: 18
        rotation: -15
        GBButton {
            id: bBtnUI
            text: "B"
            pressedExternally: shell.bridge ? shell.bridge.secondaryPressed : false
            onClicked: {
                if (shell.bridge) {
                    shell.bridge.secondaryRequested()
                }
            }
        }
        GBButton {
            id: aBtnUI
            text: "A"
            pressedExternally: shell.bridge ? shell.bridge.primaryPressed : false
            onClicked: {
                if (shell.bridge) {
                    shell.bridge.primaryRequested()
                }
            }
        }
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 36
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 28
        SmallButton {
            id: selectBtnUI
            text: "SELECT"
            theme: shell.shellTheme
            pressedExternally: shell.bridge ? shell.bridge.selectPressed : false
            onPressed: {
                if (shell.bridge) {
                    shell.bridge.selectPressBegan()
                }
            }
            onReleased: {
                if (shell.bridge) {
                    shell.bridge.selectPressEnded()
                }
            }
            onClicked: {
                if (shell.bridge) {
                    shell.bridge.selectRequested()
                }
            }
        }
        SmallButton {
            id: startBtnUI
            text: "START"
            theme: shell.shellTheme
            pressedExternally: shell.bridge ? shell.bridge.startPressed : false
            onPressed: {
                if (shell.bridge) {
                    shell.bridge.startPressBegan()
                }
            }
            onReleased: {
                if (shell.bridge) {
                    shell.bridge.startPressEnded()
                }
            }
            onClicked: {
                if (shell.bridge) {
                    shell.bridge.startRequested()
                }
            }
        }
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

        SpeakerGrill { anchors.fill: parent; theme: shell.shellTheme }
    }

    // --- Physical Volume Wheel (Game Boy side thumbwheel style) ---
    VolumeWheel {
        id: volumeControl
        anchors.right: parent.right
        anchors.rightMargin: -1
        anchors.verticalCenter: screenBorder.verticalCenter
        anchors.verticalCenterOffset: 16
        width: 18
        height: 74
        theme: shell.shellTheme
        volume: shell.volume
        onVolumeRequested: {
            if (shell.bridge) {
                shell.bridge.volumeRequested(value, withHaptic)
            }
        }
    }
}
