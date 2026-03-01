import QtQuick

Item {
    id: root
    property var theme
    default property alias content: screenSlot.data
    property bool batteryBreathing: false

    width: 300
    height: 278

    Rectangle {
        anchors.fill: parent
        color: theme.bezelBase
        radius: 10
        border.color: theme.bezelEdge
        border.width: 2

        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            radius: parent.radius - 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.lighter(theme.bezelBase, 1.18) }
                GradientStop { position: 1.0; color: Qt.darker(theme.bezelBase, 1.12) }
            }
            opacity: 0.72
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 12
            radius: 8
            color: theme.bezelInner
            border.color: theme.bezelInnerBorder
            border.width: 1
        }

        Item {
            id: screenSlot
            anchors.centerIn: parent
            width: 236
            height: 212
        }

        Text {
            id: topLabel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 12
            text: "DOT MATRIX WITH STEREO SOUND"
            color: theme.labelInk
            font.pixelSize: 8
            font.bold: false
            opacity: 0.9
        }

        Rectangle {
            width: 26
            height: 2
            radius: 1
            anchors.verticalCenter: topLabel.verticalCenter
            anchors.right: topLabel.left
            anchors.rightMargin: 10
            color: Qt.rgba(theme.logoAccent.r, theme.logoAccent.g, theme.logoAccent.b, 0.9)
            opacity: 0.82
        }

        Rectangle {
            width: 26
            height: 2
            radius: 1
            anchors.verticalCenter: topLabel.verticalCenter
            anchors.left: topLabel.right
            anchors.leftMargin: 10
            color: Qt.rgba(theme.logoAccent.r, theme.logoAccent.g, theme.logoAccent.b, 0.9)
            opacity: 0.82
        }

        Item {
            id: batteryPanel
            width: 24
            height: 26
            anchors.left: parent.left
            anchors.leftMargin: 13
            anchors.top: screenSlot.top
            anchors.topMargin: 126

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 2
                anchors.top: parent.top
                spacing: 2

                Item {
                    width: 10
                    height: 10

                    Rectangle {
                        anchors.centerIn: parent
                        width: 8
                        height: 8
                        radius: 4
                        color: Qt.rgba(0, 0, 0, 0.18)
                        border.color: Qt.rgba(1, 1, 1, 0.04)
                        border.width: 1
                    }

                    Rectangle {
                        id: batteryLamp
                        anchors.centerIn: parent
                        width: 6
                        height: 6
                        radius: 3
                        color: "#c9484d"
                        border.color: Qt.rgba(0, 0, 0, 0.24)
                        border.width: 1
                        opacity: root.batteryBreathing ? 0.58 : 0.92
                        scale: root.batteryBreathing ? 0.92 : 1.0

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 1
                            radius: 2
                            color: Qt.rgba(1, 1, 1, 0.12)
                        }

                        SequentialAnimation on opacity {
                            running: root.batteryBreathing
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.42; to: 0.95; duration: 1700; easing.type: Easing.InOutSine }
                            NumberAnimation { from: 0.95; to: 0.42; duration: 1700; easing.type: Easing.InOutSine }
                        }

                        SequentialAnimation on scale {
                            running: root.batteryBreathing
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.90; to: 1.02; duration: 1700; easing.type: Easing.InOutSine }
                            NumberAnimation { from: 1.02; to: 0.90; duration: 1700; easing.type: Easing.InOutSine }
                        }
                    }
                }

                Text {
                    width: batteryPanel.width + 6
                    text: "BATTERY"
                    color: Qt.lighter(theme.labelInk, 1.18)
                    font.pixelSize: 4
                    font.bold: true
                    opacity: 0.94
                    horizontalAlignment: Text.AlignLeft
                    leftPadding: 0
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.batteryBreathing = !root.batteryBreathing
            }
        }
    }
}
