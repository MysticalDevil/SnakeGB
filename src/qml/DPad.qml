import QtQuick

Item {
    id: root
    width: 120
    height: 120

    property bool upPressed: false
    property bool downPressed: false
    property bool leftPressed: false
    property bool rightPressed: false

    signal upClicked()
    signal downClicked()
    signal leftClicked()
    signal rightClicked()

    // Cross Base
    Rectangle {
        anchors.centerIn: parent
        width: 100
        height: 30
        color: "#222"
        radius: 4
    }
    Rectangle {
        anchors.centerIn: parent
        width: 30
        height: 100
        color: "#222"
        radius: 4
    }

    // Directional Segments with Feedback
    component DPadButton: Rectangle {
        property bool isPressed: false
        width: 30
        height: 30
        color: isPressed ? "#444" : "transparent"
        radius: 2
        
        // Inner Arrow Glow
        Rectangle {
            anchors.centerIn: parent
            width: 10; height: 10
            color: parent.isPressed ? gameLogic.palette[3] : "#111"
            rotation: 45
            opacity: parent.isPressed ? 0.8 : 0.3
            Behavior on color { ColorAnimation { duration: 50 } }
        }

        // Physical Sinking Effect
        transform: Translate { y: isPressed ? 2 : 0 }
    }

    DPadButton {
        id: upBtn
        anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
        isPressed: root.upPressed
        MouseArea { anchors.fill: parent; onPressed: root.upClicked() }
    }
    DPadButton {
        id: downBtn
        anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
        isPressed: root.downPressed
        MouseArea { anchors.fill: parent; onPressed: root.downClicked() }
    }
    DPadButton {
        id: leftBtn
        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
        isPressed: root.leftPressed
        MouseArea { anchors.fill: parent; onPressed: root.leftClicked() }
    }
    DPadButton {
        id: rightBtn
        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
        isPressed: root.rightPressed
        MouseArea { anchors.fill: parent; onPressed: root.rightClicked() }
    }
}
