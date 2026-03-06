import QtQuick

IconFrame {
    id: foodIcon

    property color strokeColor: "black"
    property color coreColor: "white"
    property color highlightColor: "white"
    property color stemColor: "black"
    property color sparkColor: "white"

    FoodGlyph {
        anchors.fill: parent
        strokeColor: foodIcon.strokeColor
        coreColor: foodIcon.coreColor
        highlightColor: foodIcon.highlightColor
        stemColor: foodIcon.stemColor
        sparkColor: foodIcon.sparkColor
    }
}
