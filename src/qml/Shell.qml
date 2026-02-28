import QtQuick
import QtQuick.Controls
import "ThemeCatalog.js" as ThemeCatalog

Rectangle {
    id: shell
    anchors.fill: parent
    property color shellColor: "#4aa3a8"
    property string shellThemeName: "Teal"
    property real volume: 1.0
    readonly property var shellTheme: ThemeCatalog.shellTheme(shellThemeName, shellColor)

    signal shellColorToggleRequested()
    signal volumeRequested(real value, bool withHaptic)

    color: shell.shellColor
    radius: 16
    border.color: shell.shellTheme.shellBorder
    border.width: 2

    property alias screenContainer: screenBorder.screenContainer
    property alias dpad: dpadUI
    property alias bButton: bBtnUI
    property alias aButton: aBtnUI
    property alias selectButton: selectBtnUI
    property alias startButton: startBtnUI

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
        theme: shell.shellTheme
        onLogoClicked: shell.shellColorToggleRequested()
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
        onVolumeRequested: shell.volumeRequested(value, withHaptic)
    }
}
