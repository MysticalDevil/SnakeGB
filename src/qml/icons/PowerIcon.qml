import QtQuick

IconFrame {
    id: powerIcon

    property int powerType: 0
    property color glyphColor: "white"

    PowerGlyph {
        anchors.fill: parent
        powerType: powerIcon.powerType
        glyphColor: powerIcon.glyphColor
    }
}
