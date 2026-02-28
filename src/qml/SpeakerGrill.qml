import QtQuick

Item {
    id: root
    property var theme
    property int slatCount: 6
    readonly property real slotWidth: 6
    readonly property real slotHeight: 31
    readonly property real slotRadius: slotWidth / 2
    readonly property real slotGap: 8
    readonly property real clusterAngle: -30
    readonly property color slotFill: theme.grillInk
    readonly property color slotShade: Qt.rgba(0, 0, 0, 0.18)
    readonly property color slotEdge: Qt.rgba(1, 1, 1, 0.08)

    Item {
        id: grillCluster
        width: (root.slatCount * root.slotWidth) + ((root.slatCount - 1) * root.slotGap)
        height: root.slotHeight + 6
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 14
        rotation: root.clusterAngle
        transformOrigin: Item.Center

        Repeater {
            model: root.slatCount

            delegate: Item {
                width: root.slotWidth + 4
                height: root.slotHeight + 4
                x: index * (root.slotWidth + root.slotGap)
                y: 0

                Rectangle {
                    anchors.fill: parent
                    anchors.leftMargin: 1
                    anchors.topMargin: 1
                    radius: root.slotRadius
                    color: root.slotShade
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.rightMargin: 1
                    anchors.bottomMargin: 1
                    radius: root.slotRadius
                    color: root.slotFill

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        radius: Math.max(1, parent.radius - 1)
                        color: "transparent"
                        border.color: root.slotEdge
                        border.width: 1
                    }
                }
            }
        }
    }
}
