import QtQuick
import QtQuick.Controls
import "ThemeCatalog.js" as ThemeCatalog

Item {
    id: shell
    anchors.fill: parent
    property color shellColor: "#4aa3a8"
    property string shellThemeName: "Teal"
    property real volume: 1.0
    property var bridge: null
    property var commandController: null
    property var inputController: null
    property Component screenContentComponent
    readonly property Item screenItem: screenBorder.screenItem
    property real shellCornerRadius: 13
    property real shellLowerRightRadius: 72
    readonly property var shellTheme: ThemeCatalog.shellTheme(shellThemeName, shellColor)
    readonly property real lowerDeckTop: screenBorder.bottom + 28
    // Local z-layer tokens (avoid bare numbers in component tree).
    readonly property int zSpeakerCluster: 20
    readonly property int zStartSelectCluster: 30

    Behavior on shellColor {
        ColorAnimation { duration: 300 }
    }

    ShellSurface {
        anchors.fill: parent
        shellColor: shell.shellColor
        shellTheme: shell.shellTheme
        smallRadius: shell.shellCornerRadius
        largeBottomRightRadius: shell.shellLowerRightRadius
    }

    // --- Screen Border ---
    ScreenBezel {
        id: screenBorder
        anchors.top: parent.top
        anchors.topMargin: 26
        anchors.horizontalCenter: parent.horizontalCenter
        theme: shell.shellTheme
        screenContentComponent: shell.screenContentComponent
    }

    // --- Branding / Color Toggle ---
    ShellBranding {
        id: shellBranding
        anchors.top: screenBorder.bottom
        anchors.topMargin: 24
        anchors.left: parent.left
        anchors.leftMargin: 42
        width: 188
        theme: shell.shellTheme
        onLogoClicked: {
            if (shell.bridge) {
                shell.bridge.shellColorToggleTriggered()
            }
        }
    }

    // --- Controls ---
    Item {
        id: controlsBand
        width: 304
        height: 146
        anchors.top: shellBranding.bottom
        anchors.topMargin: 2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 8

        Item {
            id: dpadCluster
            width: 132
            height: 132
            x: 0
            y: 6

            Rectangle {
                anchors.centerIn: parent
                width: dpadUI.width + 2
                height: dpadUI.height + 2
                radius: width / 2
                color: Qt.rgba(shell.shellTheme.shellShade.r,
                               shell.shellTheme.shellShade.g,
                               shell.shellTheme.shellShade.b,
                               0.18)
                border.color: Qt.rgba(shell.shellTheme.shellBorder.r,
                                      shell.shellTheme.shellBorder.g,
                                      shell.shellTheme.shellBorder.b,
                                      0.10)
                border.width: 1

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 2
                    radius: parent.radius - 2
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.14) }
                        GradientStop { position: 0.25; color: Qt.rgba(0, 0, 0, 0.05) }
                        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.08) }
                    }
                }
            }

            DPad {
                id: dpadUI
                anchors.centerIn: parent
                width: 118
                height: 118
                externalUpPressed: shell.bridge ? shell.bridge.upPressed : false
                externalDownPressed: shell.bridge ? shell.bridge.downPressed : false
                externalLeftPressed: shell.bridge ? shell.bridge.leftPressed : false
                externalRightPressed: shell.bridge ? shell.bridge.rightPressed : false
                onUpClicked: {
                    if (shell.bridge) {
                        shell.bridge.directionTriggered(0, -1)
                    }
                }
                onDownClicked: {
                    if (shell.bridge) {
                        shell.bridge.directionTriggered(0, 1)
                    }
                }
                onLeftClicked: {
                    if (shell.bridge) {
                        shell.bridge.directionTriggered(-1, 0)
                    }
                }
                onRightClicked: {
                    if (shell.bridge) {
                        shell.bridge.directionTriggered(1, 0)
                    }
                }
            }
        }

        Item {
            id: abCluster
            width: 156
            height: 102
            x: controlsBand.width - width
            y: 10
            rotation: -24

            Rectangle {
                id: abCradle
                anchors.centerIn: parent
                width: (bBtnUI.width * 2) + 18 + 2
                height: bBtnUI.height + 2
                radius: height / 2
                color: Qt.rgba(shell.shellTheme.shellShade.r,
                               shell.shellTheme.shellShade.g,
                               shell.shellTheme.shellShade.b,
                               0.16)
                border.color: Qt.rgba(shell.shellTheme.shellBorder.r,
                                      shell.shellTheme.shellBorder.g,
                                      shell.shellTheme.shellBorder.b,
                                      0.12)
                border.width: 1

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 3
                    radius: parent.radius - 3
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.12) }
                        GradientStop { position: 0.55; color: Qt.rgba(0, 0, 0, 0.03) }
                        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.08) }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    radius: parent.radius - 4
                    color: "transparent"
                    border.color: Qt.rgba(1, 1, 1, 0.04)
                    border.width: 1
                }
            }

            Row {
                anchors.centerIn: abCradle
                spacing: 18

                GBButton {
                    id: bBtnUI
                    text: "B"
                    commandController: shell.commandController
                    pressedExternally: shell.bridge ? shell.bridge.secondaryPressed : false
                    onClicked: {
                        if (shell.bridge) {
                            shell.bridge.secondaryTriggered()
                        }
                    }
                }

                GBButton {
                    id: aBtnUI
                    text: "A"
                    commandController: shell.commandController
                    pressedExternally: shell.bridge ? shell.bridge.primaryPressed : false
                    onClicked: {
                        if (shell.bridge) {
                            shell.bridge.primaryTriggered()
                        }
                    }
                }
            }
        }
    }

    Item {
        id: startSelectCluster
        z: shell.zStartSelectCluster
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 58
        anchors.horizontalCenter: parent.horizontalCenter
        width: startSelectRow.width
        height: startSelectRow.height + 10

        Row {
            id: startSelectRow
            anchors.centerIn: parent
            spacing: 18

            SmallButton {
                id: selectBtnUI
                text: "SELECT"
                theme: shell.shellTheme
                rotation: -18
                pressedExternally: shell.bridge ? shell.bridge.selectHeld : false
                onPressed: {
                    if (shell.bridge) {
                        shell.bridge.selectPressed()
                    }
                }
                onReleased: {
                    if (shell.bridge) {
                        shell.bridge.selectReleased()
                    }
                }
            }

            SmallButton {
                id: startBtnUI
                text: "START"
                theme: shell.shellTheme
                rotation: -18
                pressedExternally: shell.bridge ? shell.bridge.startHeld : false
                onPressed: {
                    if (shell.bridge) {
                        shell.bridge.startPressed()
                    }
                }
                onReleased: {
                    if (shell.bridge) {
                        shell.bridge.startReleased()
                    }
                }
            }
        }
    }

    Item {
        id: speakerCluster
        z: shell.zSpeakerCluster
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        width: 128
        height: 104
        opacity: 0.82

        SpeakerGrill { anchors.fill: parent; theme: shell.shellTheme }

        MouseArea {
            // Keep speaker tap gesture away from START/SELECT cluster.
            x: Math.round(parent.width * 0.34)
            y: Math.round(parent.height * 0.10)
            width: Math.round(parent.width * 0.58)
            height: Math.round(parent.height * 0.78)
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                keyFocusScope.forceActiveFocus()
                if (shell.commandController) {
                    shell.commandController.cycleBgm()
                }
            }
        }
    }

    // --- Physical Volume Wheel (Game Boy side thumbwheel style) ---
    VolumeWheel {
        id: volumeControl
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.verticalCenter: screenBorder.verticalCenter
        anchors.verticalCenterOffset: 16
        width: 14
        height: 64
        opacity: 0.84
        theme: shell.shellTheme
        volume: shell.volume
        onVolumeRequested: {
            if (shell.bridge) {
                shell.bridge.volumeRequested(value, withHaptic)
            }
        }
    }

    FocusScope {
        id: keyFocusScope
        anchors.fill: parent
        focus: true
        activeFocusOnTab: true

        Component.onCompleted: forceActiveFocus()
        onVisibleChanged: {
            if (visible) {
                forceActiveFocus()
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            hoverEnabled: true
            onPressed: keyFocusScope.forceActiveFocus()
        }

        Keys.onPressed: (event) => {
            if (shell.inputController) {
                shell.inputController.handleKeyPressed(event)
            }
        }

        Keys.onReleased: (event) => {
            if (shell.inputController) {
                shell.inputController.handleKeyReleased(event)
            }
        }
    }
}
