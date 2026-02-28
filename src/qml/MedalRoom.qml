import QtQuick
import QtQuick.Controls

Rectangle {
    id: medalRoot
    anchors.fill: parent

    property color p0
    property color p1
    property color p2
    property color p3
    property var menuColor
    property var pageTheme: ({})
    property var medalLibraryModel: []
    property int medalIndex: 0
    property int unlockedCount: 0
    property var unlockedAchievementIds: []
    property var setMedalIndex
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
            id: headerPanel
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
            height: Math.max(
                        0,
                        parent.height - headerPanel.height - footerPanel.height - (parent.spacing * 2))
            model: medalLibraryModel
            property bool syncingFromState: false
            currentIndex: -1
            clip: true
            spacing: 6
            interactive: true
            boundsBehavior: Flickable.StopAtBounds

            Component.onCompleted: {
                syncingFromState = true
                currentIndex = medalRoot.medalIndex
                syncingFromState = false
            }

            onCurrentIndexChanged: {
                if (syncingFromState) {
                    return
                }
                medalList.positionViewAtIndex(currentIndex, ListView.Contain)
                if (currentIndex !== medalRoot.medalIndex && medalRoot.setMedalIndex) {
                    medalRoot.setMedalIndex(currentIndex)
                }
            }

            onModelChanged: {
                if (medalList.currentIndex < 0 && medalRoot.medalIndex >= 0) {
                    medalList.syncingFromState = true
                    medalList.currentIndex = medalRoot.medalIndex
                    medalList.syncingFromState = false
                }
            }

            Connections {
                target: medalRoot

                function onMedalIndexChanged() {
                    if (medalList.currentIndex !== medalRoot.medalIndex) {
                        medalList.syncingFromState = true
                        medalList.currentIndex = medalRoot.medalIndex
                        medalList.syncingFromState = false
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
                unlocked: modelData && medalRoot.unlockedAchievementIds.indexOf(modelData.id) !== -1
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
            id: footerPanel
            width: parent.width
            height: 16
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
