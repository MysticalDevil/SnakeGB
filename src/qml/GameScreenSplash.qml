import QtQuick

Rectangle {
    id: splashLayer
    property bool active: false
    property string gameFont: ""
    property var menuColor

    readonly property color pageBg: menuColor("cardPrimary")
    readonly property color panelBg: menuColor("cardSecondary")
    readonly property color panelAccent: menuColor("actionCard")
    readonly property color panelBorder: menuColor("borderPrimary")
    readonly property color titleInk: menuColor("titleInk")
    readonly property color accentInk: menuColor("actionInk")

    color: pageBg
    visible: active
    z: 1000
    property real logoY: -56
    property int fakeLoad: 0

    onVisibleChanged: {
        if (visible) {
            logoY = -56
            fakeLoad = 0
            dropAnim.restart()
            loadTimer.start()
        } else {
            dropAnim.stop()
            loadTimer.stop()
        }
    }

    SequentialAnimation {
        id: dropAnim
        running: splashLayer.visible
        NumberAnimation { target: splashLayer; property: "logoY"; to: 82; duration: 480; easing.type: Easing.OutQuad }
        NumberAnimation { target: splashLayer; property: "logoY"; to: 90; duration: 80; easing.type: Easing.OutQuad }
        NumberAnimation { target: splashLayer; property: "logoY"; to: 76; duration: 95; easing.type: Easing.OutQuad }
        NumberAnimation { target: splashLayer; property: "logoY"; to: 82; duration: 85; easing.type: Easing.OutQuad }
    }

    Timer {
        id: loadTimer
        interval: 75
        repeat: true
        running: splashLayer.visible
        onTriggered: {
            if (splashLayer.fakeLoad < 100) {
                splashLayer.fakeLoad += 5
            } else {
                stop()
            }
        }
    }

    Text {
        id: bootText
        text: "S N A K E"
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: gameFont
        font.pixelSize: 32
        color: splashLayer.titleInk
        font.bold: true
        y: splashLayer.logoY
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 156
        width: 120
        height: 8
        color: splashLayer.panelBg
        border.color: splashLayer.panelBorder
        border.width: 1
        Rectangle {
            x: 1
            y: 1
            width: (parent.width - 2) * (splashLayer.fakeLoad / 100.0)
            height: parent.height - 2
            color: splashLayer.panelAccent
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 170
        text: `LOADING ${splashLayer.fakeLoad}%`
        font.family: gameFont
        font.pixelSize: 8
        color: splashLayer.accentInk
        opacity: 0.92
    }
}
