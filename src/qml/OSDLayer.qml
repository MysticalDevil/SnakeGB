import QtQuick
import QtQuick.Controls

Item {
    id: osdLayer

    property color bg
    property color ink
    property string gameFont
    property string osdMode: "text"
    property real volumeValue: 1.0
    property bool pinned: false
    readonly property int panelPaddingX: 8
    readonly property int panelHeight: 24

    function show(text) {
        osdMode = "text"
        osdLabel.text = text
        osdBox.visible = true
        osdTimer.restart()
    }

    function showVolume(value) {
        osdMode = "volume"
        volumeValue = Math.max(0.0, Math.min(1.0, value))
        osdBox.visible = true
        osdTimer.restart()
    }

    Rectangle {
        id: osdBox
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        width: Math.min(parent.width - 8,
                        osdLayer.osdMode === "volume"
                        ? Math.max(96, volumeRow.implicitWidth + (osdLayer.panelPaddingX * 2))
                        : Math.max(88, osdLabel.implicitWidth + (osdLayer.panelPaddingX * 2)))
        height: osdLayer.panelHeight
        radius: 4
        color: Qt.rgba(osdLayer.bg.r, osdLayer.bg.g, osdLayer.bg.b, 0.84)
        border.color: Qt.rgba(osdLayer.ink.r, osdLayer.ink.g, osdLayer.ink.b, 0.26)
        border.width: 1
        visible: false

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 3
            color: "transparent"
            border.color: Qt.rgba(1, 1, 1, 0.08)
            border.width: 1
        }

        Text {
            id: osdLabel
            anchors.centerIn: parent
            visible: osdLayer.osdMode === "text"
            color: osdLayer.ink
            font.family: osdLayer.gameFont
            font.bold: true
            font.pixelSize: 8
        }

        Row {
            id: volumeRow
            anchors.centerIn: parent
            spacing: 4
            visible: osdLayer.osdMode === "volume"

            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: osdLayer.ink
                font.family: osdLayer.gameFont
                font.bold: true
                font.pixelSize: 8
                text: "VOL"
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                height: 8
                spacing: 2

                Repeater {
                    model: 10
                    delegate: Rectangle {
                        readonly property int activeStep: Math.round(osdLayer.volumeValue * 9)
                        width: 4
                        height: 6
                        radius: 1
                        anchors.verticalCenter: parent.verticalCenter
                        color: index <= activeStep
                               ? osdLayer.ink
                               : Qt.rgba(osdLayer.ink.r, osdLayer.ink.g, osdLayer.ink.b, 0.18)
                        border.color: index <= activeStep
                                      ? Qt.rgba(osdLayer.bg.r, osdLayer.bg.g, osdLayer.bg.b, 0.18)
                                      : Qt.rgba(osdLayer.ink.r, osdLayer.ink.g, osdLayer.ink.b, 0.22)
                        border.width: 1
                    }
                }
            }
        }
    }

    Timer {
        id: osdTimer
        interval: osdLayer.osdMode === "volume" ? 800 : 1200
        running: false
        onTriggered: {
            if (!osdLayer.pinned) {
                osdBox.visible = false
            }
        }
    }
}
