import QtQuick

Item {
    id: root
    width: 120
    height: 120

    property bool upPressed: false
    property bool downPressed: false
    property bool leftPressed: false
    property bool rightPressed: false

    signal upClicked
    signal downClicked
    signal leftClicked
    signal rightClicked

    Rectangle {
        width: 110
        height: 35
        color: "#222"
        anchors.centerIn: parent
        radius: 5
    }

    Rectangle {
        width: 35
        height: 110
        color: "#222"
        anchors.centerIn: parent
        radius: 5
    }

    component DPadButton : Rectangle {
        property bool active: false
        signal pressAction
        width: 35
        height: 35
        color: (mouseArea.pressed || active) ? "#555" : "transparent"
        radius: 5
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                pressAction()
            }
        }
    }

    component ArrowGlyph : Canvas {
        property int direction: 0 // 0 up, 1 down, 2 left, 3 right
        width: 14
        height: 14
        anchors.centerIn: parent
        opacity: 0.55
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.fillStyle = "#111"
            ctx.beginPath()
            if (direction === 0) {
                ctx.moveTo(width / 2, 2)
                ctx.lineTo(2, height - 2)
                ctx.lineTo(width - 2, height - 2)
            } else if (direction === 1) {
                ctx.moveTo(2, 2)
                ctx.lineTo(width - 2, 2)
                ctx.lineTo(width / 2, height - 2)
            } else if (direction === 2) {
                ctx.moveTo(2, height / 2)
                ctx.lineTo(width - 2, 2)
                ctx.lineTo(width - 2, height - 2)
            } else {
                ctx.moveTo(2, 2)
                ctx.lineTo(width - 2, height / 2)
                ctx.lineTo(2, height - 2)
            }
            ctx.closePath()
            ctx.fill()
        }
    }

    DPadButton {
        id: upBtn
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        active: root.upPressed
        onPressAction: {
            upClicked()
        }
        ArrowGlyph { direction: 0 }
    }

    DPadButton {
        id: downBtn
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        active: root.downPressed
        onPressAction: {
            downClicked()
        }
        ArrowGlyph { direction: 1 }
    }

    DPadButton {
        id: leftBtn
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        active: root.leftPressed
        onPressAction: {
            leftClicked()
        }
        ArrowGlyph { direction: 2 }
    }

    DPadButton {
        id: rightBtn
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        active: root.rightPressed
        onPressAction: {
            rightClicked()
        }
        ArrowGlyph { direction: 3 }
    }
}
