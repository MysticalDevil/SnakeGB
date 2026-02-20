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

    Item {
        anchors.fill: parent
        
        // UP
        Rectangle {
            x: 33; y: 0; width: 34; height: 34; color: upPressed ? "#111" : "transparent"
            Canvas {
                anchors.centerIn: parent
                width: 12; height: 10
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.fillStyle = "#333"
                    ctx.beginPath()
                    ctx.moveTo(6, 0)
                    ctx.lineTo(12, 10)
                    ctx.lineTo(0, 10)
                    ctx.fill()
                }
            }
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
            x: 33; y: 66; width: 34; height: 34; color: downPressed ? "#111" : "transparent"
            Canvas {
                anchors.centerIn: parent
                width: 12; height: 10
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.fillStyle = "#333"
                    ctx.beginPath()
                    ctx.moveTo(0, 0)
                    ctx.lineTo(12, 0)
                    ctx.lineTo(6, 10)
                    ctx.fill()
                }
            }
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
            x: 0; y: 33; width: 34; height: 34; color: leftPressed ? "#111" : "transparent"
            Canvas {
                anchors.centerIn: parent
                width: 10; height: 12
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.fillStyle = "#333"
                    ctx.beginPath()
                    ctx.moveTo(10, 0)
                    ctx.lineTo(10, 12)
                    ctx.lineTo(0, 6)
                    ctx.fill()
                }
            }
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
            x: 66; y: 33; width: 34; height: 34; color: rightPressed ? "#111" : "transparent"
            Canvas {
                anchors.centerIn: parent
                width: 10; height: 12
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.fillStyle = "#333"
                    ctx.beginPath()
                    ctx.moveTo(0, 0)
                    ctx.lineTo(10, 6)
                    ctx.lineTo(0, 12)
                    ctx.fill()
                }
            }
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
