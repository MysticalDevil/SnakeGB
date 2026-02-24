import QtQuick

Item {
    id: root
    property var theme
    property int slatCount: 6

    Repeater {
        model: slatCount
        delegate: Rectangle {
            width: 52
            height: 2
            radius: 1
            x: 20 + index * 5
            y: 8 + index * 8
            color: root.theme.grillInk
        }
    }
}
