import QtQuick
import QtQuick.Controls

Item {
    id: dpad
    width: 102
    height: 102

    property bool upPressed: false
    property bool downPressed: false
    property bool leftPressed: false
    property bool rightPressed: false

    signal upClicked
    signal downClicked
    signal leftClicked
    signal rightClicked

    readonly property int arm: 34
    readonly property int cross: 94
    readonly property int pressX: (rightPressed ? 1 : 0) - (leftPressed ? 1 : 0)
    readonly property int pressY: (downPressed ? 1 : 0) - (upPressed ? 1 : 0)

    Item {
        id: crossRoot
        anchors.centerIn: parent
        width: dpad.cross
        height: dpad.cross
        x: dpad.pressX
        y: dpad.pressY

        Canvas {
            id: crossShadow
            anchors.fill: parent
            x: 1
            y: 1
            opacity: 0.10
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                drawCrossPath(ctx, width, height, dpad.arm)
                ctx.fillStyle = "#000000"
                ctx.fill()
            }
        }

        Canvas {
            id: crossBody
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                drawCrossPath(ctx, width, height, dpad.arm)

                var g = ctx.createLinearGradient(0, 0, width, height)
                g.addColorStop(0.0, "#3f4a5a")
                g.addColorStop(0.48, "#384354")
                g.addColorStop(1.0, "#313c4c")
                ctx.fillStyle = g
                ctx.fill()

                ctx.lineWidth = 1.5
                ctx.strokeStyle = "#141b24"
                ctx.lineJoin = "round"
                ctx.stroke()

                // Subtle top-left highlight to avoid hard/plastic look.
                ctx.save()
                drawCrossPath(ctx, width, height, dpad.arm)
                ctx.clip()
                var hg = ctx.createLinearGradient(0, 0, width, height)
                hg.addColorStop(0.0, "rgba(255,255,255,0.06)")
                hg.addColorStop(0.45, "rgba(255,255,255,0.00)")
                hg.addColorStop(1.0, "rgba(0,0,0,0.04)")
                ctx.fillStyle = hg
                ctx.fillRect(0, 0, width, height)
                ctx.restore()
            }
        }

        Canvas {
            id: pressMask
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                drawCrossPath(ctx, width, height, dpad.arm)
                ctx.clip()
                ctx.fillStyle = "rgba(0,0,0,0.14)"
                if (dpad.upPressed) {
                    ctx.fillRect((width - dpad.arm) / 2, 0, dpad.arm, (height - dpad.arm) / 2 + 1)
                }
                if (dpad.downPressed) {
                    ctx.fillRect((width - dpad.arm) / 2, (height + dpad.arm) / 2 - 1, dpad.arm, (height - dpad.arm) / 2 + 1)
                }
                if (dpad.leftPressed) {
                    ctx.fillRect(0, (height - dpad.arm) / 2, (width - dpad.arm) / 2 + 1, dpad.arm)
                }
                if (dpad.rightPressed) {
                    ctx.fillRect((width + dpad.arm) / 2 - 1, (height - dpad.arm) / 2, (width - dpad.arm) / 2 + 1, dpad.arm)
                }
            }
        }

        Canvas {
            id: arrows
            anchors.fill: parent
            opacity: 0.16
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                drawTri(ctx, width / 2, 15, 5, "up")
                drawTri(ctx, width / 2, height - 15, 5, "down")
                drawTri(ctx, 15, height / 2, 5, "left")
                drawTri(ctx, width - 15, height / 2, 5, "right")
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: 18
            height: 18
            radius: 9
            color: "#232c39"
            border.color: "#151d27"
            border.width: 1
        }

        Rectangle {
            anchors.centerIn: parent
            width: 10
            height: 4
            radius: 2
            color: Qt.rgba(1, 1, 1, 0.03)
        }
    }

    Item {
        anchors.fill: crossRoot
        anchors.centerIn: parent

        MouseArea {
            x: (parent.width - dpad.arm) / 2
            y: 0
            width: dpad.arm
            height: (parent.height - dpad.arm) / 2 + 8
            onPressed: { dpad.upPressed = true; dpad.upClicked() }
            onReleased: dpad.upPressed = false
            onCanceled: dpad.upPressed = false
        }

        MouseArea {
            x: (parent.width - dpad.arm) / 2
            y: (parent.height + dpad.arm) / 2 - 8
            width: dpad.arm
            height: (parent.height - dpad.arm) / 2 + 8
            onPressed: { dpad.downPressed = true; dpad.downClicked() }
            onReleased: dpad.downPressed = false
            onCanceled: dpad.downPressed = false
        }

        MouseArea {
            x: 0
            y: (parent.height - dpad.arm) / 2
            width: (parent.width - dpad.arm) / 2 + 8
            height: dpad.arm
            onPressed: { dpad.leftPressed = true; dpad.leftClicked() }
            onReleased: dpad.leftPressed = false
            onCanceled: dpad.leftPressed = false
        }

        MouseArea {
            x: (parent.width + dpad.arm) / 2 - 8
            y: (parent.height - dpad.arm) / 2
            width: (parent.width - dpad.arm) / 2 + 8
            height: dpad.arm
            onPressed: { dpad.rightPressed = true; dpad.rightClicked() }
            onReleased: dpad.rightPressed = false
            onCanceled: dpad.rightPressed = false
        }
    }

    Connections {
        target: dpad
        function onUpPressedChanged() { pressMask.requestPaint() }
        function onDownPressedChanged() { pressMask.requestPaint() }
        function onLeftPressedChanged() { pressMask.requestPaint() }
        function onRightPressedChanged() { pressMask.requestPaint() }
    }

    function drawCrossPath(ctx, w, h, arm) {
        var t = (w - arm) / 2
        var b = t + arm
        ctx.beginPath()
        ctx.moveTo(t, 0)
        ctx.lineTo(b, 0)
        ctx.lineTo(b, t)
        ctx.lineTo(w, t)
        ctx.lineTo(w, b)
        ctx.lineTo(b, b)
        ctx.lineTo(b, h)
        ctx.lineTo(t, h)
        ctx.lineTo(t, b)
        ctx.lineTo(0, b)
        ctx.lineTo(0, t)
        ctx.lineTo(t, t)
        ctx.closePath()
    }

    function drawTri(ctx, cx, cy, s, dir) {
        ctx.fillStyle = "rgba(12,17,22,0.55)"
        ctx.beginPath()
        if (dir === "up") {
            ctx.moveTo(cx, cy - s); ctx.lineTo(cx - s, cy + s); ctx.lineTo(cx + s, cy + s)
        } else if (dir === "down") {
            ctx.moveTo(cx - s, cy - s); ctx.lineTo(cx + s, cy - s); ctx.lineTo(cx, cy + s)
        } else if (dir === "left") {
            ctx.moveTo(cx - s, cy); ctx.lineTo(cx + s, cy - s); ctx.lineTo(cx + s, cy + s)
        } else {
            ctx.moveTo(cx - s, cy - s); ctx.lineTo(cx + s, cy); ctx.lineTo(cx - s, cy + s)
        }
        ctx.closePath()
        ctx.fill()
    }
}
