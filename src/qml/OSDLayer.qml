import QtQuick
import QtQuick.Controls

Rectangle {
    id: osdBox
    anchors.centerIn: parent
    width: osdMode === "volume" ? 144 : 180
    height: osdMode === "volume" ? 52 : 40
    radius: 6
    color: Qt.rgba(bg.r, bg.g, bg.b, 0.8)
    visible: false

    property color bg
    property color ink
    property string gameFont
    property string osdMode: "text"
    property real volumeValue: 1.0

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
        font.pixelSize: 10
    }

    Column {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4
        visible: osdBox.osdMode === "volume"

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            color: osdBox.ink
            font.family: osdBox.gameFont
            font.bold: true
            font.pixelSize: 9
            text: "VOLUME"
        }

        Row {
            width: parent.width
            height: 18
            spacing: 3

            Repeater {
                model: 10
                delegate: Rectangle {
                    readonly property int activeStep: Math.round(osdBox.volumeValue * 9)
                    width: 9
                    height: 14
                    radius: 2
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
