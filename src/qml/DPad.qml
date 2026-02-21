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

    // 1. Bottom shadow layer
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

    // 2. D-pad body
    Canvas {
        id: dpadBody
        anchors.fill: parent
        
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            
            var baseColor = "#2a2d33"
            var activeColor = "#4a4f58"
            var borderColor = "#15181d"
            
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
            if (dpad.upPressed) { 
                ctx.fillRect(33, 5, 34, 28) 
            }
            if (dpad.downPressed) { 
                ctx.fillRect(33, 67, 34, 28) 
            }
            if (dpad.leftPressed) { 
                ctx.fillRect(5, 33, 28, 34) 
            }
            if (dpad.rightPressed) { 
                ctx.fillRect(67, 33, 28, 34) 
            }

            drawCross(true)
        }

        transform: Translate {
            x: (dpad.rightPressed ? 2 : 0) - (dpad.leftPressed ? 2 : 0)
            y: (dpad.downPressed ? 2 : 0) - (dpad.upPressed ? 2 : 0)
        }

        Connections {
            target: dpad
            function onUpPressedChanged() { dpadBody.requestPaint() }
            function onDownPressedChanged() { dpadBody.requestPaint() }
            function onLeftPressedChanged() { dpadBody.requestPaint() }
            function onRightPressedChanged() { dpadBody.requestPaint() }
        }
    }

    // 3. Center detail
    Rectangle {
        anchors.centerIn: parent
        width: 24
        height: 24
        radius: 12
        color: "#1a1a1a"
        border.color: "#111"
        border.width: 1
        
        transform: Translate {
            x: (dpad.rightPressed ? 1 : 0) - (dpad.leftPressed ? 1 : 0)
            y: (dpad.downPressed ? 1 : 0) - (dpad.upPressed ? 1 : 0)
        }
    }

    // 4. Interactive hit areas
    Item {
        anchors.fill: parent
        
        // UP
        Item {
            x: 33
            y: 5
            width: 34
            height: 34
            Canvas {
                id: upArrow
                anchors.centerIn: parent
                width: 12
                height: 10
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.fillStyle = dpad.upPressed ? "#aeb4bf" : "#515862"
                    ctx.beginPath()
                    ctx.moveTo(6, 0)
                    ctx.lineTo(12, 10)
                    ctx.lineTo(0, 10)
                    ctx.fill()
                }
                Connections { 
                    target: dpad
                    function onUpPressedChanged() { upArrow.requestPaint() } 
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
                id: downArrow
                anchors.centerIn: parent
                width: 12
                height: 10
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.fillStyle = dpad.downPressed ? "#aeb4bf" : "#515862"
                    ctx.beginPath()
                    ctx.moveTo(0, 0)
                    ctx.lineTo(12, 0)
                    ctx.lineTo(6, 10)
                    ctx.fill()
                }
                Connections { 
                    target: dpad
                    function onDownPressedChanged() { downArrow.requestPaint() } 
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
                id: leftArrow
                anchors.centerIn: parent
                width: 10
                height: 12
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.fillStyle = dpad.leftPressed ? "#aeb4bf" : "#515862"
                    ctx.beginPath()
                    ctx.moveTo(10, 0)
                    ctx.lineTo(10, 12)
                    ctx.lineTo(0, 6)
                    ctx.fill()
                }
                Connections { 
                    target: dpad
                    function onLeftPressedChanged() { leftArrow.requestPaint() } 
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
                id: rightArrow
                anchors.centerIn: parent
                width: 10
                height: 12
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.fillStyle = dpad.rightPressed ? "#aeb4bf" : "#515862"
                    ctx.beginPath()
                    ctx.moveTo(0, 0)
                    ctx.lineTo(10, 6)
                    ctx.lineTo(0, 12)
                    ctx.fill()
                }
                Connections { 
                    target: dpad
                    function onRightPressedChanged() { rightArrow.requestPaint() } 
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
