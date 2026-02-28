import QtQuick

Item {
    id: root
    property var theme
    property real volume: 1.0
    property int detentCount: 10
    signal volumeRequested(real value, bool withHaptic)

    readonly property real slotMargin: 5
    readonly property real slotWidth: Math.max(4, width - 8)
    readonly property real slotHeight: height - (slotMargin * 2)
    readonly property real thumbTravel: Math.max(1, slotHeight - thumb.height)
    readonly property real snappedPosition: slotMargin + (1.0 - clamp01(volume)) * thumbTravel

    function clamp01(v) {
        return Math.max(0.0, Math.min(1.0, v))
    }

    function setDetentVolume(v, withHaptic) {
        const clamped = clamp01(v)
        const snapped = Math.round(clamped * (detentCount - 1)) / (detentCount - 1)
        const oldStep = Math.round(volume * (detentCount - 1))
        const newStep = Math.round(snapped * (detentCount - 1))
        if (Math.abs(snapped - volume) > 0.0001) {
            volumeRequested(snapped, withHaptic && oldStep !== newStep)
        }
    }

    Rectangle {
        id: sideCut
        x: Math.round((parent.width - root.slotWidth) / 2)
        y: root.slotMargin
        width: root.slotWidth
        height: root.slotHeight
        radius: width / 2
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.darker(theme.wheelTrackA, 1.22) }
            GradientStop { position: 0.45; color: Qt.darker(theme.wheelTrackB, 1.10) }
            GradientStop { position: 1.0; color: Qt.darker(theme.wheelTrackA, 1.25) }
        }
        border.color: Qt.rgba(0, 0, 0, 0.18)
        border.width: 1
        opacity: 0.68
    }

    Rectangle {
        anchors.fill: sideCut
        anchors.margins: 1
        radius: sideCut.radius - 1
        color: "transparent"
        border.color: Qt.rgba(1, 1, 1, 0.05)
        border.width: 1
    }

    Rectangle {
        id: thumb
        x: sideCut.x - 1
        y: Math.round(root.snappedPosition)
        width: sideCut.width + 2
        height: 16
        radius: width / 2
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.lighter(theme.wheelBodyLight, 1.03) }
            GradientStop { position: 0.5; color: theme.wheelBody }
            GradientStop { position: 1.0; color: theme.wheelBodyDark }
        }
        border.color: Qt.rgba(0, 0, 0, 0.24)
        border.width: 1
        opacity: 0.9

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.color: Qt.rgba(1, 1, 1, 0.08)
            border.width: 1
        }

        Repeater {
            model: 3
            delegate: Rectangle {
                width: parent.width * 0.58
                height: 1
                radius: 1
                anchors.horizontalCenter: parent.horizontalCenter
                y: 4 + (index * 4)
                color: Qt.rgba(0, 0, 0, 0.20)
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onPressed: (event) => {
            const v = 1.0 - ((event.y - root.slotMargin) / root.slotHeight)
            root.setDetentVolume(v, true)
        }
        onPositionChanged: (event) => {
            if (pressed) {
                const v = 1.0 - ((event.y - root.slotMargin) / root.slotHeight)
                root.setDetentVolume(v, false)
            }
        }
    }
}
