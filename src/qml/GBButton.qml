import QtQuick

Rectangle {
    id: root
    property alias text: label.text
    property color buttonColor: "#a01040"
    signal clicked

    width: 45; height: 45; radius: 22.5
    color: mouseArea.pressed ? Qt.darker(buttonColor, 1.2) : buttonColor
    border.color: "#333"; border.width: 2

    scale: mouseArea.pressed ? 0.9 : 1.0
    
    // 增加触觉反馈暗示
    Behavior on scale { 
        NumberAnimation { duration: 100; easing.type: Easing.OutBack } 
    }

    Text {
        id: label
        anchors.top: parent.bottom; anchors.topMargin: 4
        anchors.horizontalCenter: parent.horizontalCenter
        font.bold: true; color: "#333"; font.pixelSize: 12
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
