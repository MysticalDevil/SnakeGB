import QtQuick
import QtQuick.Controls

Rectangle {
    id: osdBox
    anchors.centerIn: parent
    width: 180
    height: 40
    radius: 5
    color: Qt.rgba(bg.r, bg.g, bg.b, 0.8)
    visible: false
    z: 200

    property color bg
    property color ink
    property string gameFont

    function show(text) {
        osdLabel.text = text
        osdBox.visible = true
        osdTimer.restart()
    }

    Text {
        id: osdLabel
        anchors.centerIn: parent
        color: ink
        font.family: gameFont
        font.bold: true
        font.pixelSize: 10
    }

    Timer {
        id: osdTimer
        interval: 1500
        onTriggered: osdBox.visible = false
    }
}
