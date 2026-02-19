import QtQuick

Item {
    id: root
    width: 120; height: 120

    // 暴露按键状态
    property bool upPressed: false
    property bool downPressed: false
    property bool leftPressed: false
    property bool rightPressed: false

    signal upClicked; signal downClicked; signal leftClicked; signal rightClicked

    // 背景十字
    Rectangle { width: 110; height: 35; color: "#222"; anchors.centerIn: parent; radius: 5 }
    Rectangle { width: 35; height: 110; color: "#222"; anchors.centerIn: parent; radius: 5 }

    component DPadButton : Rectangle {
        property bool active: false
        signal pressAction
        width: 35; height: 35
        color: (mouseArea.pressed || active) ? "#555" : "transparent"
        radius: 5
        MouseArea { id: mouseArea; anchors.fill: parent; onClicked: pressAction() }
    }

    DPadButton {
        id: upBtn; anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
        active: root.upPressed
        onPressAction: upClicked()
        Text { text: "▲"; color: "#111"; anchors.centerIn: parent; opacity: 0.5 }
    }
    DPadButton {
        id: downBtn; anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
        active: root.downPressed
        onPressAction: downClicked()
        Text { text: "▼"; color: "#111"; anchors.centerIn: parent; opacity: 0.5 }
    }
    DPadButton {
        id: leftBtn; anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
        active: root.leftPressed
        onPressAction: leftClicked()
        Text { text: "◀"; color: "#111"; anchors.centerIn: parent; opacity: 0.5 }
    }
    DPadButton {
        id: rightBtn; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
        active: root.rightPressed
        onPressAction: rightClicked()
        Text { text: "▶"; color: "#111"; anchors.centerIn: parent; opacity: 0.5 }
    }
}
