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

    // 监听状态变化，强制重绘视觉效果
    onUpPressedChanged: { dpadBody.requestPaint() }
    onDownPressedChanged: { dpadBody.requestPaint() }
    onLeftPressedChanged: { dpadBody.requestPaint() }
    onRightPressedChanged: { dpadBody.requestPaint() }

    // 1. 底部投影层
    Canvas {
        id: dpadShadow
        anchors.fill: parent
        anchors.margins: -2
        opacity: 0.3
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.fillStyle = "black"
            ctx.beginPath()
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

    // 2. 十字键主体
    Canvas {
        id: dpadBody
        anchors.fill: parent
        
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            
            var baseColor = "#222222"
            var activeColor = "#444444"
            var borderColor = "#111111"
            
            ctx.lineWidth = 2
            ctx.strokeStyle = borderColor
            
            var drawCross = function(isStroke) {
                ctx.beginPath()
                ctx.moveTo(33, 5)   
                ctx.lineTo(67, 5)   
                ctx.lineTo(67, 33)  
                ctx.lineTo(95, 33)  
                ctx.lineTo(95, 67)  
                ctx.lineTo(67, 67)  
                ctx.lineTo(67, 95)  
                ctx.lineTo(33, 95)  
                ctx.lineTo(33, 67)  
                ctx.lineTo(5, 67)   
                ctx.lineTo(5, 33)   
                ctx.lineTo(33, 33)  
                ctx.closePath()
                if (isStroke) { 
                    ctx.stroke() 
                } else { 
                    ctx.fill() 
                }
            }

            ctx.fillStyle = baseColor
            drawCross(false)

            ctx.fillStyle = activeColor
            if (upPressed) { 
                ctx.fillRect(33, 5, 34, 28) 
            }
            if (downPressed) { 
                ctx.fillRect(33, 67, 34, 28) 
            }
            if (leftPressed) { 
                ctx.fillRect(5, 33, 28, 34) 
            }
            if (rightPressed) { 
                ctx.fillRect(67, 33, 28, 34) 
            }

            drawCross(true)
        }

        transform: Translate {
            x: (rightPressed ? 2 : 0) - (leftPressed ? 2 : 0)
            y: (downPressed ? 2 : 0) - (upPressed ? 2 : 0)
        }
    }

    // 3. 中心细节
    Rectangle {
        anchors.centerIn: parent
        width: 24
        height: 24
        radius: 12
        color: "#1a1a1a"
        border.color: "#111"
        border.width: 1
        
        transform: Translate {
            x: (rightPressed ? 1 : 0) - (leftPressed ? 1 : 0)
            y: (downPressed ? 1 : 0) - (upPressed ? 1 : 0)
        }
    }

    // 4. 交互层与矢量箭头
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
                    ctx.fillStyle = dpad.upPressed ? "#888" : "#333"
                    ctx.beginPath()
                    ctx.moveTo(6, 0)
                    ctx.lineTo(12, 10)
                    ctx.lineTo(0, 10)
                    ctx.fill()
                }
                Connections { 
                    target: dpad
                    function onUpPressedChanged() { 
                        parent.requestPaint() 
                    } 
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
                    ctx.fillStyle = dpad.downPressed ? "#888" : "#333"
                    ctx.beginPath()
                    ctx.moveTo(0, 0)
                    ctx.lineTo(12, 0)
                    ctx.lineTo(6, 10)
                    ctx.fill()
                }
                Connections { 
                    target: dpad
                    function onDownPressedChanged() { 
                        parent.requestPaint() 
                    } 
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
                    ctx.fillStyle = dpad.leftPressed ? "#888" : "#333"
                    ctx.beginPath()
                    ctx.moveTo(10, 0)
                    ctx.lineTo(10, 12)
                    ctx.lineTo(0, 6)
                    ctx.fill()
                }
                Connections { 
                    target: dpad
                    function onLeftPressedChanged() { 
                        parent.requestPaint() 
                    } 
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
                    ctx.fillStyle = dpad.rightPressed ? "#888" : "#333"
                    ctx.beginPath()
                    ctx.moveTo(0, 0)
                    ctx.lineTo(10, 6)
                    ctx.lineTo(0, 12)
                    ctx.fill()
                }
                Connections { 
                    target: dpad
                    function onRightPressedChanged() { 
                        parent.requestPaint() 
                    } 
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
