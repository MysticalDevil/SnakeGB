import QtQuick
import QtQuick.Controls
import "PowerMeta.js" as PowerMeta
import "icons" as Icons

Rectangle {
    id: libraryLayer
    property bool active: false
    property string gameFont: ""
    property var fruitLibraryModel: []
    property int libraryIndex: 0
    property var setLibraryIndex
    property var menuColor
    property var pageTheme
    property var powerColor
    property var debugDiscoveredTypes: []
    property bool debugDiscoverAll: false

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
        if (!fruitLibraryModel) {
            return 0
        }
        let count = 0
        for (let i = 0; i < fruitLibraryModel.length; ++i) {
            if (isDiscovered(fruitLibraryModel[i])) {
                count += 1
            }
        }
        return count
    }

    function isDebugDiscovered(type) {
        return debugDiscoveredTypes && debugDiscoveredTypes.indexOf(Number(type)) !== -1
    }

    function isDiscovered(entry) {
        return !!entry && (debugDiscoverAll || entry.discovered || isDebugDiscovered(entry.type))
    }

    function resolvedName(entry) {
        if (!entry) {
            return "??????"
        }
        return isDiscovered(entry) ? PowerMeta.choiceName(Number(entry.type)).toUpperCase() : "??????"
    }

    function resolvedDesc(entry) {
        if (!entry) {
            return ""
        }
        return isDiscovered(entry)
                ? PowerMeta.choiceDescription(Number(entry.type))
                : "Eat this fruit in-game to unlock its data."
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
            height: 30
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
                    text: `${libraryLayer.discoveredCount}/${fruitLibraryModel.length} DISCOVERED`
                    color: Qt.rgba(libraryLayer.textMuted.r, libraryLayer.textMuted.g, libraryLayer.textMuted.b, 0.92)
                    font.family: gameFont
                    font.pixelSize: 8
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
            model: fruitLibraryModel
            property bool syncingFromState: false
            currentIndex: -1
            spacing: 6
            clip: true
            interactive: true
            boundsBehavior: Flickable.StopAtBounds

            Component.onCompleted: {
                syncingFromState = true
                currentIndex = libraryLayer.libraryIndex
                syncingFromState = false
            }

            onCurrentIndexChanged: {
                if (syncingFromState) {
                    return
                }
                positionViewAtIndex(currentIndex, ListView.Contain)
                if (currentIndex !== libraryLayer.libraryIndex && libraryLayer.setLibraryIndex) {
                    libraryLayer.setLibraryIndex(currentIndex)
                }
            }

            onModelChanged: {
                if (libraryList.currentIndex < 0 && libraryLayer.libraryIndex >= 0) {
                    libraryList.syncingFromState = true
                    libraryList.currentIndex = libraryLayer.libraryIndex
                    libraryList.syncingFromState = false
                }
            }

            Connections {
                target: libraryLayer

                function onLibraryIndexChanged() {
                    if (libraryList.currentIndex !== libraryLayer.libraryIndex) {
                        libraryList.syncingFromState = true
                        libraryList.currentIndex = libraryLayer.libraryIndex
                        libraryList.syncingFromState = false
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
                height: 58
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
                    anchors.margins: 6
                    spacing: 12

                    Item {
                        width: 24
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter

                        Icons.PowerIcon {
                            anchors.centerIn: parent
                            width: 20
                            height: 20
                            visible: libraryLayer.isDiscovered(modelData)
                            radius: 4
                            contentMargin: 2
                            fillColor: libraryCard.selected
                                       ? Qt.rgba(libraryLayer.panelBgStrong.r, libraryLayer.panelBgStrong.g,
                                                 libraryLayer.panelBgStrong.b, 0.88)
                                       : Qt.rgba(libraryLayer.iconFill.r, libraryLayer.iconFill.g,
                                                 libraryLayer.iconFill.b, 0.96)
                            borderColor: libraryCard.selected
                                         ? Qt.rgba(libraryLayer.textOnAccent.r, libraryLayer.textOnAccent.g,
                                                   libraryLayer.textOnAccent.b, 0.72)
                                         : Qt.rgba(powerColor(modelData.type).r, powerColor(modelData.type).g,
                                                   powerColor(modelData.type).b, 0.72)
                            borderWidth: modelData.type >= 9 ? 2 : 1
                            powerType: Number(modelData.type)
                            glyphColor: libraryCard.selected ? libraryLayer.textOnAccent : powerColor(modelData.type)
                        }

                        Text {
                            text: "?"
                            color: libraryLayer.unknownText
                            visible: !libraryLayer.isDiscovered(modelData)
                            anchors.centerIn: parent
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }

                    Column {
                        width: parent.width - 50
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: libraryLayer.resolvedName(modelData)
                            color: libraryCard.labelColor
                            font.family: gameFont
                            font.pixelSize: 11
                            font.bold: true
                        }

                        Text {
                            text: libraryLayer.resolvedDesc(modelData)
                            color: libraryCard.descColor
                            font.family: gameFont
                            font.pixelSize: 8
                            font.bold: true
                            opacity: 1.0
                            width: parent.width
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
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
                text: "UP PREV   DOWN NEXT   SELECT MENU"
                color: libraryLayer.textMuted
                font.family: gameFont
                font.pixelSize: 8
                font.bold: true
            }
        }
    }
}
