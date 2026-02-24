import QtQuick

Item {
    id: root
    property var theme
    property real volume: 1.0
    property int detentCount: 16
    signal volumeRequested(real value, bool withHaptic)

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
        x: 1
        y: 4
        width: 6
        height: parent.height - 8
        radius: 3
        gradient: Gradient {
            GradientStop { position: 0.0; color: theme.wheelTrackA }
            GradientStop { position: 0.55; color: theme.wheelTrackB }
            GradientStop { position: 1.0; color: theme.wheelTrackA }
        }
        border.color: Qt.rgba(0, 0, 0, 0.24)
        border.width: 1
        opacity: 0.82
    }

    Rectangle {
        anchors.fill: sideCut
        anchors.margins: 1
        radius: sideCut.radius - 1
        color: "transparent"
        border.color: Qt.rgba(1, 1, 1, 0.04)
        border.width: 1
    }

    Item {
        id: wheelViewport
        x: 4
        y: 4
        width: 9
        height: parent.height - 8
        clip: true

        Rectangle {
            id: wheelBody
            width: wheelViewport.width
            height: wheelViewport.height
            radius: wheelViewport.width / 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: theme.wheelBodyLight }
                GradientStop { position: 0.5; color: theme.wheelBody }
                GradientStop { position: 1.0; color: theme.wheelBodyDark }
            }
            border.color: Qt.rgba(0, 0, 0, 0.3)
            border.width: 1

            Repeater {
                model: root.detentCount
                delegate: Rectangle {
                    width: parent.width * 0.9
                    height: 1
                    radius: 1
                    x: parent.width * 0.05
                    y: (parent.height / (root.detentCount + 1)) * (index + 1)
                    color: Qt.rgba(0, 0, 0, 0.2)
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onPressed: (event) => {
            const v = 1.0 - ((event.y - 4) / (root.height - 8))
            root.setDetentVolume(v, true)
        }
        onPositionChanged: (event) => {
            if (pressed) {
                const v = 1.0 - ((event.y - 4) / (root.height - 8))
                root.setDetentVolume(v, false)
            }
        }
    }
}
