import QtQuick

Rectangle {
    id: root
    property alias text: label.text
    property color buttonColor: "#a01040"
    property bool isPressed: false // 新增：支持外部按键控制
    signal clicked

    width: 45; height: 45; radius: 22.5
    // 逻辑：鼠标按下或键盘对应的 isPressed 为 true 时显示按下色
    color: (mouseArea.pressed || isPressed) ? Qt.darker(buttonColor, 1.2) : buttonColor
    border.color: "#333"; border.width: 2

    scale: (mouseArea.pressed || isPressed) ? 0.9 : 1.0
    
    Behavior on scale { 
        NumberAnimation { duration: 50; easing.type: Easing.OutQuad } 
    }
    Behavior on color {
        ColorAnimation { duration: 50 }
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
