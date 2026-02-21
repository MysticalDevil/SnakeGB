import QtQuick
import QtQuick.Controls

Rectangle {
    id: medalRoot
    anchors.fill: parent
    z: 1000

    property color p0
    property color p1
    property color p2
    property color p3
    property var visualTheme: ({})
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

    readonly property color pageBg: visualTheme.pageBg || p0
    readonly property color titleColor: visualTheme.title || p3
    readonly property color dividerColor: visualTheme.divider || p3
    readonly property color cardNormal: visualTheme.cardNormal || p1
    readonly property color cardSelected: visualTheme.cardSelected || p2
    readonly property color cardBorder: visualTheme.cardBorder || p3
    readonly property color badgeFill: visualTheme.badgeFill || p3
    readonly property color badgeText: visualTheme.badgeText || p0
    readonly property color iconFill: visualTheme.iconFill || p0
    readonly property color unknownText: visualTheme.unknownText || p0
    readonly property color scrollbarHandle: visualTheme.scrollbarHandle || p2
    readonly property color scrollbarTrack: visualTheme.scrollbarTrack || p1

    color: pageBg

    Column {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10

        Text {
            text: "ACHIEVEMENTS"
            color: titleColor
            font.family: gameFont
            font.pixelSize: 20
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle { width: parent.width; height: 2; color: dividerColor; opacity: 0.5 }

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
                    gameLogic.dispatchUiAction("set_medal_index:" + currentIndex)
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
                contentItem: Rectangle {
                    implicitWidth: 6
                    radius: 3
                    color: medalRoot.scrollbarHandle
                }
                background: Rectangle {
                    radius: 3
                    color: medalRoot.scrollbarTrack
                    opacity: 0.35
                }
            }

            delegate: Rectangle {
                id: medalCard
                width: parent.width
                height: 48
                color: medalList.currentIndex === index ? medalRoot.cardSelected : medalRoot.cardNormal
                border.color: medalRoot.cardBorder
                border.width: medalList.currentIndex === index ? 2 : 1

                readonly property bool unlocked: gameLogic.achievements.indexOf(modelData.id) !== -1
                readonly property bool selected: medalList.currentIndex === index
                readonly property color titleColor: selected ? medalRoot.badgeText : medalRoot.titleColor
                readonly property color hintColor: selected
                                                 ? Qt.rgba(medalRoot.badgeText.r, medalRoot.badgeText.g, medalRoot.badgeText.b, 0.86)
                                                 : Qt.rgba(medalRoot.titleColor.r, medalRoot.titleColor.g, medalRoot.titleColor.b, 0.78)

                Row {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 12
                    
                    Rectangle {
                        width: 28; height: 28
                        color: unlocked ? medalRoot.badgeFill : medalRoot.iconFill
                        radius: 14
                        border.color: medalRoot.cardBorder
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            anchors.centerIn: parent
                            text: unlocked ? "★" : "?"
                            color: unlocked ? medalRoot.badgeText : medalRoot.unknownText
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }

                    Column {
                        width: parent.width - 50
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            text: unlocked ? modelData.id : "?????????"
                            color: medalCard.titleColor
                            font.family: gameFont
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: unlocked ? "UNLOCKED" : modelData.hint
                            color: medalCard.hintColor
                            font.family: gameFont
                            font.pixelSize: 9
                            opacity: 1.0
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
    }
}
