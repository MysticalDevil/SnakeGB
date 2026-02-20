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

    // 一体化十字键背景投影
    Canvas {
        id: dpadShadow
        anchors.fill: parent
        anchors.margins: -2
        opacity: 0.3
        onPaint: {
            var ctx = getContext("2d")
            ctx.fillStyle = "black"
            ctx.beginPath()
            // 十字路径
            ctx.moveTo(35, 7)
            ctx.lineTo(65, 7)
            ctx.lineTo(65, 35)
            ctx.lineTo(93, 35)
            ctx.lineTo(93, 65)
            ctx.lineTo(65, 65)
            ctx.lineTo(65, 93)
            ctx.lineTo(35, 93)
            ctx.lineTo(35, 65)
            ctx.lineTo(7, 65)
            ctx.lineTo(7, 35)
            ctx.lineTo(35, 35)
            ctx.closePath()
            ctx.fill()
        }
    }

    // 一体化十字键主体
    Canvas {
        id: dpadBody
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.fillStyle = "#222"
            ctx.strokeStyle = "#111"
            ctx.lineWidth = 2
            ctx.beginPath()
            // 十字键完整闭合路径
            ctx.moveTo(33, 5)   // Top-Left of Up arm
            ctx.lineTo(67, 5)   // Top-Right of Up arm
            ctx.lineTo(67, 33)  // Inner Corner Top-Right
            ctx.lineTo(95, 33)  // Right end Top
            ctx.lineTo(95, 67)  // Right end Bottom
            ctx.lineTo(67, 67)  // Inner Corner Bottom-Right
            ctx.lineTo(67, 95)  // Bottom end Right
            ctx.lineTo(33, 95)  // Bottom end Left
            ctx.lineTo(33, 67)  // Inner Corner Bottom-Left
            ctx.lineTo(5, 67)   // Left end Bottom
            ctx.lineTo(5, 33)   // Left end Top
            ctx.lineTo(33, 33)  // Inner Corner Top-Left
            ctx.closePath()
            ctx.fill()
            ctx.stroke()
        }
    }

    // 中心圆形凹陷
    Rectangle {
        anchors.centerIn: parent
        width: 24
        height: 24
        radius: 12
        color: "#1a1a1a"
        border.color: "#111"
        border.width: 1
    }

    // 交互区域与矢量箭头
    Item {
        anchors.fill: parent
        
        // UP
        Item {
            x: 33
            y: 5
            width: 34
            height: 34
            Canvas {
                anchors.centerIn: parent
                width: 12
                height: 10
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.fillStyle = upPressed ? "#555" : "#333"
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
        Item {
            x: 33
            y: 61
            width: 34
            height: 34
            Canvas {
                anchors.centerIn: parent
                width: 12
                height: 10
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.fillStyle = downPressed ? "#555" : "#333"
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
        Item {
            x: 5
            y: 33
            width: 34
            height: 34
            Canvas {
                anchors.centerIn: parent
                width: 10
                height: 12
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.fillStyle = leftPressed ? "#555" : "#333"
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
        Item {
            x: 61
            y: 33
            width: 34
            height: 34
            Canvas {
                anchors.centerIn: parent
                width: 10
                height: 12
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.fillStyle = rightPressed ? "#555" : "#333"
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
