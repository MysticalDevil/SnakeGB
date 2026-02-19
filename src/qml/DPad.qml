import QtQuick

Item {
    id: root
    width: 120
    height: 120

    signal upClicked
    signal downClicked
    signal leftClicked
    signal rightClicked

    // Horizontal bar
    Rectangle {
        width: 110; height: 35; color: "#222"; anchors.centerIn: parent; radius: 5
    }
    // Vertical bar
    Rectangle {
        width: 35; height: 110; color: "#222"; anchors.centerIn: parent; radius: 5
    }

    // Directional buttons with visual feedback
    component DPadButton : Rectangle {
        property string dir: ""
        signal pressAction
        width: 35; height: 35; color: mouseArea.pressed ? "#444" : "transparent"
        radius: 5
        MouseArea { id: mouseArea; anchors.fill: parent; onClicked: pressAction() }
        Behavior on color { ColorAnimation { duration: 50 } }
    }

    DPadButton {
        anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
        onPressAction: upClicked()
    }
    DPadButton {
        anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
        onPressAction: downClicked()
    }
    DPadButton {
        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
        onPressAction: leftClicked()
    }
    DPadButton {
        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
        onPressAction: rightClicked()
    }
}
