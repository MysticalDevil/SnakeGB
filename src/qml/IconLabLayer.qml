import QtQuick
import "meta/PowerMeta.js" as PowerMeta
import "meta/AchievementMeta.js" as AchievementMeta
import "icons" as Icons
import "components" as Components

Rectangle {
    id: iconLabLayer
    property bool active: false
    property int iconLabSelection: 0
    property real elapsed: 0
    property string gameFont: ""
    property var menuColor
    property var powerColor
    signal resetSelectionRequested()

    visible: active
    anchors.fill: parent
    color: menuColor("cardPrimary")
    clip: true

    readonly property int contentMargin: 8
    readonly property int contentSpacing: 4
    readonly property int headerHeight: 24
    readonly property int infoHeight: 28
    readonly property int sectionHeaderHeight: 14
    readonly property int medalSectionHeight: 42
    readonly property int footerHeight: 14
    readonly property color panelBgStrong: menuColor("cardPrimary")
    readonly property color panelBg: menuColor("cardSecondary")
    readonly property color panelBgSoft: menuColor("hintCard")
    readonly property color panelAccent: menuColor("actionCard")
    readonly property color borderStrong: menuColor("borderPrimary")
    readonly property color borderSoft: menuColor("borderSecondary")
    readonly property color textStrong: menuColor("titleInk")
    readonly property color textMuted: menuColor("secondaryInk")
    readonly property color textOnAccent: menuColor("actionInk")
    readonly property var medalSpecs: AchievementMeta.all()

    onVisibleChanged: {
        if (visible) {
            resetSelectionRequested()
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 6
        color: Qt.rgba(iconLabLayer.panelBgStrong.r, iconLabLayer.panelBgStrong.g, iconLabLayer.panelBgStrong.b, 0.44)
        border.color: iconLabLayer.borderStrong
        border.width: 1
    }

    Column {
        anchors.fill: parent
        anchors.margins: iconLabLayer.contentMargin
        spacing: iconLabLayer.contentSpacing

        Components.SectionHeader {
            width: parent.width
            height: iconLabLayer.headerHeight
            color: Qt.rgba(iconLabLayer.panelBgStrong.r, iconLabLayer.panelBgStrong.g, iconLabLayer.panelBgStrong.b, 0.86)
            border.color: iconLabLayer.borderStrong
            titleText: "ICON LAB"
            subtitleText: "FRUITS + MEDALS"
            gameFont: gameFont
            textColor: iconLabLayer.textStrong
            subtitleColor: Qt.rgba(iconLabLayer.textMuted.r, iconLabLayer.textMuted.g, iconLabLayer.textMuted.b, 0.9)
        }

        Row {
            width: parent.width
            spacing: iconLabLayer.contentSpacing
            Rectangle {
                width: 90
                height: iconLabLayer.infoHeight
                radius: 3
                color: Qt.rgba(iconLabLayer.panelBg.r, iconLabLayer.panelBg.g, iconLabLayer.panelBg.b, 0.84)
                border.color: iconLabLayer.borderSoft
                border.width: 1

                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    Rectangle {
                        width: 20
                        height: 20
                        radius: 3
                        color: Qt.rgba(iconLabLayer.panelBgSoft.r, iconLabLayer.panelBgSoft.g, iconLabLayer.panelBgSoft.b, 0.86)
                        border.color: iconLabLayer.borderStrong
                        border.width: 1
                        Icons.FoodGlyph {
                            anchors.fill: parent
                            strokeColor: iconLabLayer.borderStrong
                            coreColor: iconLabLayer.panelAccent
                            highlightColor: iconLabLayer.panelBgStrong
                            stemColor: iconLabLayer.borderStrong
                            sparkColor: iconLabLayer.textMuted
                        }
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        Text { text: "FOOD"; color: iconLabLayer.textStrong; font.family: gameFont; font.pixelSize: 8; font.bold: true }
                        Text { text: "BASE"; color: iconLabLayer.textMuted; font.family: gameFont; font.pixelSize: 7; font.bold: true }
                    }
                }
            }

            Rectangle {
                width: Math.max(64, parent.width - 90 - iconLabLayer.contentSpacing)
                height: iconLabLayer.infoHeight
                radius: 3
                color: Qt.rgba(iconLabLayer.panelBg.r, iconLabLayer.panelBg.g, iconLabLayer.panelBg.b, 0.84)
                border.color: iconLabLayer.borderSoft
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: "POWERUP ICON SUITE"
                    color: iconLabLayer.textStrong
                    font.family: gameFont
                    font.pixelSize: 8
                    font.bold: true
                }
            }
        }

        Grid {
            id: iconLabGrid
            width: parent.width
            height: Math.max(
                        0,
                        parent.height - iconLabLayer.headerHeight - iconLabLayer.infoHeight
                        - iconLabLayer.sectionHeaderHeight - iconLabLayer.medalSectionHeight
                        - iconLabLayer.footerHeight - (iconLabLayer.contentSpacing * 4))
            columns: 3
            columnSpacing: iconLabLayer.contentSpacing
            rowSpacing: iconLabLayer.contentSpacing

            Repeater {
                model: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
                delegate: Rectangle {
                    width: Math.floor((iconLabGrid.width - (iconLabGrid.columnSpacing * 2)) / 3)
                    height: Math.floor((iconLabGrid.height - (iconLabGrid.rowSpacing * 3)) / 4)
                    radius: 4
                    property int iconIdx: index
                    clip: true
                    color: Qt.rgba(iconLabLayer.panelBg.r, iconLabLayer.panelBg.g, iconLabLayer.panelBg.b, 0.8)
                    border.color: powerColor(modelData)
                    border.width: 1

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        radius: 3
                        color: "transparent"
                        border.color: iconLabLayer.borderStrong
                        border.width: 1
                        visible: iconLabLayer.iconLabSelection === iconIdx
                        opacity: (Math.floor(iconLabLayer.elapsed * 8) % 2 === 0) ? 0.9 : 0.5
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.rightMargin: 3
                        anchors.topMargin: 3
                        width: 22
                        height: 10
                        radius: 2
                        visible: iconLabLayer.iconLabSelection === iconIdx
                        color: iconLabLayer.panelAccent
                        border.color: iconLabLayer.borderStrong
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: "SEL"
                            color: iconLabLayer.textOnAccent
                            font.family: gameFont
                            font.pixelSize: 7
                            font.bold: true
                        }
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 4
                        clip: true

                        Rectangle {
                            width: Math.max(16, parent.height - 10)
                            height: width
                            radius: 4
                            color: Qt.rgba(iconLabLayer.panelBgSoft.r, iconLabLayer.panelBgSoft.g, iconLabLayer.panelBgSoft.b, 0.86)
                            border.color: iconLabLayer.borderStrong
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Icons.PowerGlyph {
                                anchors.fill: parent
                                powerType: modelData
                                glyphColor: powerColor(modelData)
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 0
                            Text {
                                text: PowerMeta.buffName(modelData)
                                color: iconLabLayer.textStrong
                                font.family: gameFont
                                font.pixelSize: 8
                                font.bold: true
                            }
                            Text {
                                text: PowerMeta.rarityName(modelData)
                                color: powerColor(modelData)
                                font.family: gameFont
                                font.pixelSize: 7
                                font.bold: true
                            }
                            Text {
                                text: `GLYPH ${PowerMeta.powerGlyph(modelData)}`
                                color: iconLabLayer.textMuted
                                font.family: gameFont
                                font.pixelSize: 7
                                font.bold: true
                                visible: parent.parent.height >= 42
                            }
                        }
                    }
                }
            }
        }

        Components.SectionHeader {
            width: parent.width
            height: iconLabLayer.sectionHeaderHeight
            color: Qt.rgba(iconLabLayer.panelBg.r, iconLabLayer.panelBg.g, iconLabLayer.panelBg.b, 0.84)
            border.color: iconLabLayer.borderSoft
            titleText: "ACHIEVEMENT GLYPHS"
            gameFont: gameFont
            textColor: iconLabLayer.textStrong
        }

        Grid {
            width: parent.width
            height: iconLabLayer.medalSectionHeight
            columns: 4
            columnSpacing: iconLabLayer.contentSpacing
            rowSpacing: iconLabLayer.contentSpacing

            Repeater {
                model: iconLabLayer.medalSpecs

                delegate: Rectangle {
                    width: Math.floor((parent.width - (parent.columnSpacing * 3)) / 4)
                    height: Math.floor((parent.height - parent.rowSpacing) / 2)
                    radius: 3
                    color: Qt.rgba(iconLabLayer.panelBg.r, iconLabLayer.panelBg.g, iconLabLayer.panelBg.b, 0.8)
                    border.color: iconLabLayer.borderSoft
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 3
                        spacing: 4

                        Icons.AchievementBadgeIcon {
                            width: Math.max(14, parent.height - 4)
                            height: width
                            anchors.verticalCenter: parent.verticalCenter
                            achievementId: modelData.id
                            unlocked: true
                            badgeFill: iconLabLayer.panelAccent
                            badgeText: iconLabLayer.textOnAccent
                            iconFill: iconLabLayer.panelBgSoft
                            unknownText: iconLabLayer.textMuted
                            borderColor: iconLabLayer.borderStrong
                            borderWidth: 1
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - parent.spacing - 22
                            text: AchievementMeta.shortLabel(modelData.id)
                            color: iconLabLayer.textStrong
                            font.family: gameFont
                            font.pixelSize: 6
                            font.bold: true
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: iconLabLayer.footerHeight
            radius: 3
            color: Qt.rgba(iconLabLayer.panelBg.r, iconLabLayer.panelBg.g, iconLabLayer.panelBg.b, 0.84)
            border.color: iconLabLayer.borderSoft
            border.width: 1
            Text {
                anchors.centerIn: parent
                text: `SELECTED: ${PowerMeta.buffName(iconLabLayer.iconLabSelection + 1)}`
                color: iconLabLayer.textStrong
                font.family: gameFont
                font.pixelSize: 8
                font.bold: true
            }
        }
    }
}
