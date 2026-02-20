import QtQuick
import QtQuick.Controls

Item {
    id: dpad
    width: 100
    height: 100

    property bool upPressed: false
    property bool downPressed: false
    property bool leftPressed: false
    property bool rightPressed: false

    signal upClicked
    signal downClicked
    signal leftClicked
    signal rightClicked

    Rectangle {
        anchors.centerIn: parent
        width: 34
        height: 90
        color: "#222"
        radius: 4
        border.color: "#111"
        border.width: 2
    }
    Rectangle {
        anchors.centerIn: parent
        width: 90
        height: 34
        color: "#222"
        radius: 4
        border.color: "#111"
        border.width: 2
    }

    // 方向键
    Item {
        anchors.fill: parent
        // UP
        Rectangle {
            x: 33; y: 5; width: 34; height: 34; color: upPressed ? "#111" : "transparent"
            Text { text: "▲"; anchors.centerIn: parent; color: "#333"; opacity: 0.5; font.pixelSize: 10 }
            MouseArea { 
                anchors.fill: parent
                onPressed: { 
                    dpad.upPressed = true
                    dpad.upClicked() 
                } 
                onReleased: { 
                    dpad.upPressed = false 
                } 
            }
        }
        // DOWN
        Rectangle {
            x: 33; y: 61; width: 34; height: 34; color: downPressed ? "#111" : "transparent"
            Text { text: "▼"; anchors.centerIn: parent; color: "#333"; opacity: 0.5; font.pixelSize: 10 }
            MouseArea { 
                anchors.fill: parent
                onPressed: { 
                    dpad.downPressed = true
                    dpad.downClicked() 
                } 
                onReleased: { 
                    dpad.downPressed = false 
                } 
            }
        }
        // LEFT
        Rectangle {
            x: 5; y: 33; width: 34; height: 34; color: leftPressed ? "#111" : "transparent"
            Text { text: "◀"; anchors.centerIn: parent; color: "#333"; opacity: 0.5; font.pixelSize: 10 }
            MouseArea { 
                anchors.fill: parent
                onPressed: { 
                    dpad.leftPressed = true
                    dpad.leftClicked() 
                } 
                onReleased: { 
                    dpad.leftPressed = false 
                } 
            }
        }
        // RIGHT
        Rectangle {
            x: 61; y: 33; width: 34; height: 34; color: rightPressed ? "#111" : "transparent"
            Text { text: "▶"; anchors.centerIn: parent; color: "#333"; opacity: 0.5; font.pixelSize: 10 }
            MouseArea { 
                anchors.fill: parent
                onPressed: { 
                    dpad.rightPressed = true
                    dpad.rightClicked() 
                } 
                onReleased: { 
                    dpad.rightPressed = false 
                } 
            }
        }
    }
}
