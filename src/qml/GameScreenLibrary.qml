import QtQuick
import QtQuick.Controls

Rectangle {
    id: libraryLayer
    property bool active: false
    property string gameFont: ""
    property var gameLogic
    property var catalogTheme
    property var powerColor

    anchors.fill: parent
    color: catalogTheme.pageBg
    visible: active
    z: 800

    Column {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10
        Text {
            text: "CATALOG"
            color: catalogTheme.title
            font.family: gameFont
            font.pixelSize: 20
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        ListView {
            id: libraryList
            width: parent.width
            height: parent.height - 60
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
                    color: catalogTheme.scrollbarHandle
                }
                background: Rectangle {
                    radius: 3
                    color: catalogTheme.scrollbarTrack
                    opacity: 0.35
                }
            }
            delegate: Rectangle {
                id: libraryCard
                width: parent.width
                height: 46
                color: libraryList.currentIndex === index ? catalogTheme.cardSelected : catalogTheme.cardNormal
                border.color: catalogTheme.cardBorder
                border.width: libraryList.currentIndex === index ? 2 : 1
                readonly property bool selected: libraryList.currentIndex === index
                readonly property color labelColor: selected ? catalogTheme.badgeText : catalogTheme.primaryText
                readonly property color descColor: selected
                                                   ? Qt.rgba(catalogTheme.badgeText.r, catalogTheme.badgeText.g, catalogTheme.badgeText.b, 0.92)
                                                   : Qt.rgba(catalogTheme.secondaryText.r, catalogTheme.secondaryText.g, catalogTheme.secondaryText.b, 0.96)
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
                            Rectangle { anchors.fill: parent; color: "transparent"; border.color: catalogTheme.iconStroke; border.width: 1; visible: modelData.discovered && modelData.type === 1 }
                            Rectangle { anchors.fill: parent; radius: 10; color: "transparent"; border.color: catalogTheme.iconStroke; border.width: 2; visible: modelData.discovered && modelData.type === 2
                                Rectangle { width: 10; height: 2; color: catalogTheme.iconStroke; anchors.centerIn: parent }
                            }
                            Rectangle { anchors.fill: parent; color: catalogTheme.iconStroke; visible: modelData.discovered && modelData.type === 3; clip: true
                                Rectangle { width: 20; height: 20; rotation: 45; y: 10; color: catalogTheme.iconFill }
                            }
                            Rectangle { anchors.fill: parent; radius: 10; color: "transparent"; border.color: catalogTheme.iconStroke; border.width: 2; visible: modelData.discovered && modelData.type === 4 }
                            Rectangle { anchors.fill: parent; radius: 10; color: "transparent"; border.color: catalogTheme.iconStroke; border.width: 1; visible: modelData.discovered && modelData.type === 5
                                Rectangle { anchors.centerIn: parent; width: 10; height: 10; radius: 5; border.color: catalogTheme.iconStroke; border.width: 1 }
                            }
                            Rectangle { anchors.centerIn: parent; width: 16; height: 16; rotation: 45; color: powerColor(6); visible: modelData.discovered && modelData.type === 6 }
                            Rectangle { anchors.centerIn: parent; width: 16; height: 16; rotation: 45; color: powerColor(7); visible: modelData.discovered && modelData.type === 7 }
                            Rectangle { anchors.fill: parent; color: "transparent"; border.color: powerColor(8); border.width: 2; visible: modelData.discovered && modelData.type === 8 }
                            Rectangle { anchors.fill: parent; color: "transparent"; border.color: catalogTheme.iconStroke; border.width: 1; visible: modelData.discovered && modelData.type === 9
                                Rectangle { anchors.centerIn: parent; width: 4; height: 4; color: catalogTheme.iconFill }
                            }
                            Text { text: "?"; color: catalogTheme.unknownText; visible: !modelData.discovered; anchors.centerIn: parent; font.bold: true; font.pixelSize: 12 }
                        }
                    }
                    Column {
                        width: parent.width - 50
                        anchors.verticalCenter: parent.verticalCenter
                        Text { text: modelData.name; color: libraryCard.labelColor; font.family: gameFont; font.pixelSize: 11; font.bold: true }
                        Text { text: modelData.desc; color: libraryCard.descColor; font.family: gameFont; font.pixelSize: 9; opacity: 1.0; width: parent.width; wrapMode: Text.WordWrap }
                    }
                }
            }
        }
    }
}
