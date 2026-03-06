import QtQuick

Rectangle {
    id: frame

    property bool selected: false
    property color normalFill: "transparent"
    property color selectedFill: "transparent"
    property color borderColor: "white"
    property int borderLineWidth: 1
    property int innerMargin: 1
    property real innerBorderOpacitySelected: 0.18
    property real innerBorderOpacityNormal: 0.08

    default property alias contentData: contentRoot.data

    radius: 4
    color: selected ? selectedFill : normalFill
    border.color: borderColor
    border.width: borderLineWidth

    Rectangle {
        anchors.fill: parent
        anchors.margins: frame.innerMargin
        radius: Math.max(1, frame.radius - frame.innerMargin)
        color: "transparent"
        border.color: Qt.rgba(1, 1, 1, frame.selected ? frame.innerBorderOpacitySelected : frame.innerBorderOpacityNormal)
        border.width: 1
    }

    Item {
        id: contentRoot
        anchors.fill: parent
    }
}
