import QtQuick
import QtQuick.Controls

Rectangle {
    id: osdBox
    anchors.centerIn: parent
    width: osdMode === "volume"
           ? Math.max(112, volumeColumn.implicitWidth + (volumePadding * 2))
           : Math.max(88, osdLabel.implicitWidth + (textPadding * 2))
    height: osdMode === "volume"
            ? Math.max(34, volumeColumn.implicitHeight + (volumePadding * 2))
            : Math.max(24, osdLabel.implicitHeight + (textPadding * 2))
    radius: osdMode === "volume" ? 5 : 4
    color: Qt.rgba(bg.r, bg.g, bg.b, 0.8)
    visible: false

    property color bg
    property color ink
    property string gameFont
    property string osdMode: "text"
    property real volumeValue: 1.0
    readonly property int textPadding: 9
    readonly property int volumePadding: 8

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

    Text {
        id: osdLabel
        anchors.centerIn: parent
        visible: osdBox.osdMode === "text"
        color: ink
        font.family: gameFont
        font.bold: true
        font.pixelSize: 9
    }

    Column {
        id: volumeColumn
        anchors.fill: parent
        anchors.margins: volumePadding
        spacing: 3
        visible: osdBox.osdMode === "volume"

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            color: osdBox.ink
            font.family: osdBox.gameFont
            font.bold: true
            font.pixelSize: 8
            text: "VOLUME"
        }

        Row {
            width: parent.width
            height: 14
            spacing: 2
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                model: 10
                delegate: Rectangle {
                    readonly property int activeStep: Math.round(osdBox.volumeValue * 9)
                    width: 8
                    height: 10
                    radius: 1
                    anchors.verticalCenter: parent.verticalCenter
                    color: index <= activeStep
                           ? osdBox.ink
                           : Qt.rgba(osdBox.ink.r, osdBox.ink.g, osdBox.ink.b, 0.18)
                    border.color: index <= activeStep
                                  ? Qt.rgba(osdBox.bg.r, osdBox.bg.g, osdBox.bg.b, 0.18)
                                  : Qt.rgba(osdBox.ink.r, osdBox.ink.g, osdBox.ink.b, 0.22)
                    border.width: 1
                }
            }
        }
    }

    Timer {
        id: osdTimer
        interval: osdBox.osdMode === "volume" ? 850 : 1500
        onTriggered: osdBox.visible = false
    }
}
