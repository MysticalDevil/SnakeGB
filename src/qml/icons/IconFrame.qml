import QtQuick

Rectangle {
    id: frame

    property color fillColor: "transparent"
    property color borderColor: "white"
    property int borderWidth: 1
    property int contentMargin: 2

    default property alias contentData: contentRoot.data

    radius: 4
    color: fillColor
    border.color: borderColor
    border.width: borderWidth

    Item {
        id: contentRoot
        anchors.fill: parent
        anchors.margins: frame.contentMargin
    }
}
