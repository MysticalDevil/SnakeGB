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
    readonly property int textPadding: 9
    readonly property int volumePadding: 6

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
        anchors.verticalCenter: osdLayer.osdMode === "volume" ? undefined : parent.verticalCenter
        anchors.bottom: osdLayer.osdMode === "volume" ? parent.bottom : undefined
        anchors.bottomMargin: osdLayer.osdMode === "volume" ? 14 : 0
        width: osdLayer.osdMode === "volume"
               ? Math.max(92, volumeRow.implicitWidth + (osdLayer.volumePadding * 2))
               : Math.max(88, osdLabel.implicitWidth + (osdLayer.textPadding * 2))
        height: osdLayer.osdMode === "volume"
                ? Math.max(24, volumeRow.implicitHeight + (osdLayer.volumePadding * 2))
                : Math.max(24, osdLabel.implicitHeight + (osdLayer.textPadding * 2))
        radius: osdLayer.osdMode === "volume" ? 5 : 4
        color: Qt.rgba(osdLayer.bg.r, osdLayer.bg.g, osdLayer.bg.b, 0.8)
        visible: false

        Text {
            id: osdLabel
            anchors.centerIn: parent
            visible: osdLayer.osdMode === "text"
            color: osdLayer.ink
            font.family: osdLayer.gameFont
            font.bold: true
            font.pixelSize: 9
        }

        Row {
            id: volumeRow
            anchors.centerIn: parent
            spacing: 5
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
                height: 10
                spacing: 2

                Repeater {
                    model: 10
                    delegate: Rectangle {
                        readonly property int activeStep: Math.round(osdLayer.volumeValue * 9)
                        width: 5
                        height: 8
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
        interval: osdLayer.osdMode === "volume" ? 850 : 1500
        running: false
        onTriggered: {
            if (!osdLayer.pinned) {
                osdBox.visible = false
            }
        }
    }
}
