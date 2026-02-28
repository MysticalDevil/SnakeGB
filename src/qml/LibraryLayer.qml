import QtQuick
import QtQuick.Controls

Rectangle {
    id: libraryLayer
    property bool active: false
    property string gameFont: ""
    property var gameLogic
    property var menuColor
    property var pageTheme
    property var powerColor

    readonly property color pageBg: menuColor("cardPrimary")
    readonly property color panelBgStrong: menuColor("cardPrimary")
    readonly property color panelBg: menuColor("cardSecondary")
    readonly property color panelBgSoft: menuColor("hintCard")
    readonly property color panelAccent: pageTheme && pageTheme.cardSelected ? pageTheme.cardSelected : menuColor("actionCard")
    readonly property color borderStrong: menuColor("borderPrimary")
    readonly property color borderSoft: menuColor("borderSecondary")
    readonly property color textStrong: menuColor("titleInk")
    readonly property color textMuted: menuColor("secondaryInk")
    readonly property color textOnAccent: menuColor("actionInk")
    readonly property color scrollbarHandle: pageTheme && pageTheme.scrollbarHandle ? pageTheme.scrollbarHandle : borderStrong
    readonly property color scrollbarTrack: pageTheme && pageTheme.scrollbarTrack ? pageTheme.scrollbarTrack : panelBgSoft
    readonly property color iconStroke: pageTheme && pageTheme.iconStroke ? pageTheme.iconStroke : textStrong
    readonly property color iconFill: pageTheme && pageTheme.iconFill ? pageTheme.iconFill : panelBgStrong
    readonly property color unknownText: pageTheme && pageTheme.unknownText ? pageTheme.unknownText : textMuted
    readonly property int cardRadius: 4
    readonly property int discoveredCount: {
        if (!gameLogic || !gameLogic.fruitLibrary) {
            return 0
        }
        let count = 0
        for (let i = 0; i < gameLogic.fruitLibrary.length; ++i) {
            if (gameLogic.fruitLibrary[i].discovered) {
                count += 1
            }
        }
        return count
    }

    anchors.fill: parent
    color: pageBg
    visible: active
    clip: true

    Rectangle {
        anchors.fill: parent
        anchors.margins: 6
        color: Qt.rgba(libraryLayer.panelBgStrong.r, libraryLayer.panelBgStrong.g, libraryLayer.panelBgStrong.b, 0.42)
        border.color: libraryLayer.borderStrong
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
            color: Qt.rgba(libraryLayer.panelBgStrong.r, libraryLayer.panelBgStrong.g, libraryLayer.panelBgStrong.b, 0.86)
            border.color: libraryLayer.borderStrong
            border.width: 1

            Column {
                anchors.centerIn: parent
                spacing: 0

                Text {
                    text: "CATALOG"
                    color: libraryLayer.textStrong
                    font.family: gameFont
                    font.pixelSize: 14
                    font.bold: true
                }

                Text {
                    text: `${libraryLayer.discoveredCount}/${gameLogic.fruitLibrary.length} DISCOVERED`
                    color: Qt.rgba(libraryLayer.textMuted.r, libraryLayer.textMuted.g, libraryLayer.textMuted.b, 0.92)
                    font.family: gameFont
                    font.pixelSize: 7
                    font.bold: true
                }
            }
        }

        ListView {
            id: libraryList
            width: parent.width
            height: Math.max(
                        0,
                        parent.height - headerPanel.height - footerPanel.height - (parent.spacing * 2))
            model: gameLogic.fruitLibrary
            property bool syncingFromLogic: false
            currentIndex: -1
            spacing: 6
            clip: true
            interactive: true
            boundsBehavior: Flickable.StopAtBounds

            Component.onCompleted: {
                syncingFromLogic = true
                currentIndex = gameLogic.libraryIndex
                syncingFromLogic = false
            }

            onCurrentIndexChanged: {
                if (syncingFromLogic) {
                    return
                }
                positionViewAtIndex(currentIndex, ListView.Contain)
                if (currentIndex !== gameLogic.libraryIndex) {
                    gameLogic.dispatchUiAction(`set_library_index:${currentIndex}`)
                }
            }

            Connections {
                target: gameLogic

                function onLibraryIndexChanged() {
                    if (libraryList.currentIndex !== gameLogic.libraryIndex) {
                        libraryList.syncingFromLogic = true
                        libraryList.currentIndex = gameLogic.libraryIndex
                        libraryList.syncingFromLogic = false
                        libraryList.positionViewAtIndex(libraryList.currentIndex, ListView.Contain)
                    }
                }
            }

            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: (event) => {
                    libraryList.contentY = Math.max(0, Math.min(
                        libraryList.contentHeight - libraryList.height,
                        libraryList.contentY - event.angleDelta.y
                    ))
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                width: 6

                contentItem: Rectangle {
                    implicitWidth: 6
                    radius: 3
                    color: libraryLayer.scrollbarHandle
                }

                background: Rectangle {
                    radius: 3
                    color: libraryLayer.scrollbarTrack
                    opacity: 0.35
                }
            }

            delegate: Rectangle {
                id: libraryCard
                width: parent.width
                height: 52
                radius: libraryLayer.cardRadius
                color: libraryList.currentIndex === index
                       ? Qt.rgba(libraryLayer.panelAccent.r, libraryLayer.panelAccent.g, libraryLayer.panelAccent.b, 0.92)
                       : Qt.rgba(libraryLayer.panelBg.r, libraryLayer.panelBg.g, libraryLayer.panelBg.b, 0.84)
                border.color: libraryList.currentIndex === index ? libraryLayer.borderStrong : libraryLayer.borderSoft
                border.width: 1
                readonly property bool selected: libraryList.currentIndex === index
                readonly property color labelColor: selected ? libraryLayer.textOnAccent : libraryLayer.textStrong
                readonly property color descColor: selected
                                                   ? Qt.rgba(libraryLayer.textOnAccent.r, libraryLayer.textOnAccent.g, libraryLayer.textOnAccent.b, 0.92)
                                                   : Qt.rgba(libraryLayer.textMuted.r, libraryLayer.textMuted.g, libraryLayer.textMuted.b, 0.96)

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 1
                    radius: libraryLayer.cardRadius - 1
                    color: "transparent"
                    border.color: libraryCard.selected ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)
                    border.width: 1
                }

                Row {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 12

                    Item {
                        width: 24
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter

                        Item {
                            anchors.centerIn: parent
                            width: 20
                            height: 20

                            Rectangle { anchors.fill: parent; color: "transparent"; border.color: libraryLayer.iconStroke; border.width: 1; visible: modelData.discovered && modelData.type === 1 }
                            Rectangle {
                                anchors.fill: parent
                                radius: 10
                                color: "transparent"
                                border.color: libraryLayer.iconStroke
                                border.width: 2
                                visible: modelData.discovered && modelData.type === 2

                                Rectangle {
                                    width: 10
                                    height: 2
                                    color: libraryLayer.iconStroke
                                    anchors.centerIn: parent
                                }
                            }
                            Rectangle {
                                anchors.fill: parent
                                color: libraryLayer.iconStroke
                                visible: modelData.discovered && modelData.type === 3
                                clip: true

                                Rectangle {
                                    width: 20
                                    height: 20
                                    rotation: 45
                                    y: 10
                                    color: libraryLayer.iconFill
                                }
                            }
                            Rectangle { anchors.fill: parent; radius: 10; color: "transparent"; border.color: libraryLayer.iconStroke; border.width: 2; visible: modelData.discovered && modelData.type === 4 }
                            Rectangle {
                                anchors.fill: parent
                                radius: 10
                                color: "transparent"
                                border.color: libraryLayer.iconStroke
                                border.width: 1
                                visible: modelData.discovered && modelData.type === 5

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 10
                                    height: 10
                                    radius: 5
                                    border.color: libraryLayer.iconStroke
                                    border.width: 1
                                }
                            }
                            Rectangle { anchors.centerIn: parent; width: 16; height: 16; rotation: 45; color: powerColor(6); visible: modelData.discovered && modelData.type === 6 }
                            Rectangle { anchors.centerIn: parent; width: 16; height: 16; rotation: 45; color: powerColor(7); visible: modelData.discovered && modelData.type === 7 }
                            Rectangle { anchors.fill: parent; color: "transparent"; border.color: powerColor(8); border.width: 2; visible: modelData.discovered && modelData.type === 8 }
                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: libraryLayer.iconStroke
                                border.width: 1
                                visible: modelData.discovered && modelData.type === 9

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 4
                                    height: 4
                                    color: libraryLayer.iconFill
                                }
                            }
                            Text { text: "?"; color: libraryLayer.unknownText; visible: !modelData.discovered; anchors.centerIn: parent; font.bold: true; font.pixelSize: 12 }
                        }
                    }

                    Column {
                        width: parent.width - 50
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: modelData.name
                            color: libraryCard.labelColor
                            font.family: gameFont
                            font.pixelSize: 11
                            font.bold: true
                        }

                        Text {
                            text: modelData.desc
                            color: libraryCard.descColor
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

        Rectangle {
            id: footerPanel
            width: parent.width
            height: 16
            radius: 3
            color: Qt.rgba(libraryLayer.panelBgStrong.r, libraryLayer.panelBgStrong.g, libraryLayer.panelBgStrong.b, 0.82)
            border.color: libraryLayer.borderStrong
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "UP/DOWN BROWSE   B MENU"
                color: libraryLayer.textMuted
                font.family: gameFont
                font.pixelSize: 8
                font.bold: true
            }
        }
    }
}
