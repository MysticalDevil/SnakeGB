import QtQuick
import QtQuick.Controls

Rectangle {
    id: medalRoot
    anchors.fill: parent
    color: p0
    z: 1000

    property color p0
    property color p1
    property color p2
    property color p3
    property string gameFont

    function luminance(colorValue) {
        if (colorValue === undefined || colorValue === null) {
            return 0.0
        }
        return 0.299 * colorValue.r + 0.587 * colorValue.g + 0.114 * colorValue.b
    }

    function readableText(bgColor) {
        if (p0 === undefined || p3 === undefined) {
            return "white"
        }
        var d0 = Math.abs(luminance(p0) - luminance(bgColor))
        var d3 = Math.abs(luminance(p3) - luminance(bgColor))
        return d3 >= d0 ? p3 : p0
    }

    function readableMutedText(bgColor) {
        var c = readableText(bgColor)
        return Qt.rgba(c.r, c.g, c.b, 0.9)
    }

    function readableSecondaryText(bgColor) {
        var c = readableText(bgColor)
        return Qt.rgba(c.r, c.g, c.b, 0.78)
    }

    Column {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10

        Text {
            text: "ACHIEVEMENTS"
            color: p3
            font.family: gameFont
            font.pixelSize: 20
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle { width: parent.width; height: 2; color: p3; opacity: 0.5 }

        ListView {
            id: medalList
            width: parent.width
            height: parent.height - 60
            model: gameLogic.medalLibrary
            property bool syncingFromLogic: false
            currentIndex: -1
            clip: true
            spacing: 6
            interactive: true
            boundsBehavior: Flickable.StopAtBounds
            Component.onCompleted: {
                syncingFromLogic = true
                currentIndex = gameLogic.medalIndex
                syncingFromLogic = false
            }
            onCurrentIndexChanged: {
                if (syncingFromLogic) {
                    return
                }
                medalList.positionViewAtIndex(currentIndex, ListView.Contain)
                if (currentIndex !== gameLogic.medalIndex) {
                    gameLogic.setMedalIndex(currentIndex)
                }
            }
            Connections {
                target: gameLogic
                function onMedalIndexChanged() {
                    if (medalList.currentIndex !== gameLogic.medalIndex) {
                        medalList.syncingFromLogic = true
                        medalList.currentIndex = gameLogic.medalIndex
                        medalList.syncingFromLogic = false
                        medalList.positionViewAtIndex(medalList.currentIndex, ListView.Contain)
                    }
                }
            }
            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: (event) => {
                    medalList.contentY = Math.max(0, Math.min(
                        medalList.contentHeight - medalList.height,
                        medalList.contentY - event.angleDelta.y
                    ))
                }
            }
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                width: 6
            }

            delegate: Rectangle {
                width: parent.width
                height: 48
                color: medalList.currentIndex === index ? p2 : p1
                border.color: p3
                border.width: medalList.currentIndex === index ? 2 : 1

                readonly property bool unlocked: gameLogic.achievements.indexOf(modelData.id) !== -1

                Row {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 12
                    
                    Rectangle {
                        width: 28; height: 28
                        color: unlocked ? p3 : p0
                        radius: 14
                        border.color: p3
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            anchors.centerIn: parent
                            text: unlocked ? "★" : "?"
                            color: unlocked ? p0 : p3
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }

                    Column {
                        width: parent.width - 50
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            text: unlocked ? modelData.id : "?????????"
                            color: medalRoot.readableText(parent.parent.color)
                            font.family: gameFont
                            font.pixelSize: 12
                            font.bold: true
                            style: Text.Outline
                            styleColor: Qt.rgba(0, 0, 0, 0.24)
                        }
                        Text {
                            text: unlocked ? "UNLOCKED" : modelData.hint
                            color: medalRoot.readableSecondaryText(parent.parent.color)
                            font.family: gameFont
                            font.pixelSize: 9
                            opacity: 1.0
                            width: parent.width
                            wrapMode: Text.WordWrap
                            style: Text.Outline
                            styleColor: Qt.rgba(0, 0, 0, 0.20)
                        }
                    }
                }
            }
        }
    }
}
