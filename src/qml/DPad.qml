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
        width: 100; height: 34
        color: "#222"; radius: 4
    }
    Rectangle {
        anchors.centerIn: parent
        width: 34; height: 100
        color: "#222"; radius: 4
    }

    // Helper component for internal use
    component DPadSegment: Rectangle {
        property bool isDown: false
        width: 34; height: 34
        radius: 4
        color: isDown ? "#444" : "transparent"
        
        Rectangle {
            anchors.centerIn: parent
            width: 10; height: 10
            color: parent.isDown ? gameLogic.palette[3] : "#111"
            rotation: 45; opacity: parent.isDown ? 0.8 : 0.4
        }
        
        transform: Translate { y: isDown ? 2 : 0 }
    }

    // Up
    DPadSegment {
        anchors.top: parent.top; anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        isDown: root.upPressed || upMa.pressed
        MouseArea { id: upMa; anchors.fill: parent; onPressed: root.upClicked() }
    }
    // Down
    DPadSegment {
        anchors.bottom: parent.bottom; anchors.bottomMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        isDown: root.downPressed || downMa.pressed
        MouseArea { id: downMa; anchors.fill: parent; onPressed: root.downClicked() }
    }
    // Left
    DPadSegment {
        anchors.left: parent.left; anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        isDown: root.leftPressed || leftMa.pressed
        MouseArea { id: leftMa; anchors.fill: parent; onPressed: root.leftClicked() }
    }
    // Right
    DPadSegment {
        anchors.right: parent.right; anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        isDown: root.rightPressed || rightMa.pressed
        MouseArea { id: rightMa; anchors.fill: parent; onPressed: root.rightClicked() }
    }
}
