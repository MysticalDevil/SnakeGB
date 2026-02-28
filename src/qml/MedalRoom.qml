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
    property var menuColor
    property var pageTheme: ({})
    property var gameLogic
    property string gameFont

    readonly property color pageBg: menuColor("cardPrimary")
    readonly property color panelBgStrong: menuColor("cardPrimary")
    readonly property color panelBg: menuColor("cardSecondary")
    readonly property color panelBgSoft: menuColor("hintCard")
    readonly property color panelAccent: pageTheme && pageTheme.cardSelected ? pageTheme.cardSelected : menuColor("actionCard")
    readonly property color titleColor: menuColor("titleInk")
    readonly property color dividerColor: menuColor("borderPrimary")
    readonly property color cardNormal: Qt.rgba(panelBg.r, panelBg.g, panelBg.b, 0.84)
    readonly property color cardSelected: Qt.rgba(panelAccent.r, panelAccent.g, panelAccent.b, 0.92)
    readonly property color cardBorder: menuColor("borderSecondary")
    readonly property color badgeFill: pageTheme && pageTheme.badgeFill ? pageTheme.badgeFill : menuColor("actionCard")
    readonly property color badgeText: pageTheme && pageTheme.badgeText ? pageTheme.badgeText : menuColor("actionInk")
    readonly property color secondaryText: menuColor("secondaryInk")
    readonly property color iconFill: pageTheme && pageTheme.iconFill ? pageTheme.iconFill : panelBgStrong
    readonly property color unknownText: pageTheme && pageTheme.unknownText ? pageTheme.unknownText : secondaryText
    readonly property color scrollbarHandle: pageTheme && pageTheme.scrollbarHandle ? pageTheme.scrollbarHandle : dividerColor
    readonly property color scrollbarTrack: pageTheme && pageTheme.scrollbarTrack ? pageTheme.scrollbarTrack : panelBgSoft
    readonly property int unlockedCount: gameLogic ? gameLogic.achievements.length : 0

    color: pageBg
    clip: true

    Rectangle {
        anchors.fill: parent
        anchors.margins: 6
        color: Qt.rgba(medalRoot.panelBgStrong.r, medalRoot.panelBgStrong.g, medalRoot.panelBgStrong.b, 0.42)
        border.color: medalRoot.dividerColor
        border.width: 1
    }

    Column {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6

        Rectangle {
            width: parent.width
            height: 28
            radius: 3
            color: Qt.rgba(medalRoot.panelBgStrong.r, medalRoot.panelBgStrong.g, medalRoot.panelBgStrong.b, 0.86)
            border.color: medalRoot.dividerColor
            border.width: 1

            Column {
                anchors.centerIn: parent
                spacing: 0

                Text {
                    text: "ACHIEVEMENTS"
                    color: medalRoot.titleColor
                    font.family: gameFont
                    font.pixelSize: 14
                    font.bold: true
                }

                Text {
                    text: `${medalRoot.unlockedCount} UNLOCKED`
                    color: Qt.rgba(medalRoot.secondaryText.r, medalRoot.secondaryText.g, medalRoot.secondaryText.b, 0.92)
                    font.family: gameFont
                    font.pixelSize: 7
                    font.bold: true
                }
            }
        }

        ListView {
            id: medalList
            width: parent.width
            height: parent.height - 72
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
                    gameLogic.dispatchUiAction(`set_medal_index:${currentIndex}`)
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

            delegate: MedalRoomCard {
                modelData: modelData
                gameLogic: gameLogic
                selected: medalList.currentIndex === index
                cardNormal: medalRoot.cardNormal
                cardSelected: medalRoot.cardSelected
                cardBorder: medalRoot.cardBorder
                badgeFill: medalRoot.badgeFill
                badgeText: medalRoot.badgeText
                titleColor: medalRoot.titleColor
                secondaryText: medalRoot.secondaryText
                iconFill: medalRoot.iconFill
                unknownText: medalRoot.unknownText
                gameFont: medalRoot.gameFont
            }
        }

        Rectangle {
            width: parent.width
            height: 18
            radius: 3
            color: Qt.rgba(medalRoot.panelBgStrong.r, medalRoot.panelBgStrong.g, medalRoot.panelBgStrong.b, 0.82)
            border.color: medalRoot.dividerColor
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "UP/DOWN BROWSE   B MENU"
                color: medalRoot.secondaryText
                font.family: gameFont
                font.pixelSize: 8
                font.bold: true
            }
        }
    }
}
