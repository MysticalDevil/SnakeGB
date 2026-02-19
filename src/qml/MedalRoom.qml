import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    anchors.fill: parent
    color: p0
    visible: false
    z: 150

    property color p0
    property color p3
    property string gameFont

    signal closeRequested

    onVisibleChanged: {
        if (visible) {
            medalList.focus = true
        }
    }

    Column {
        id: header
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 20
        spacing: 5

        Text {
            text: "MEDAL COLLECTION"
            font.family: gameFont
            font.pixelSize: 14
            font.bold: true
            color: p3
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            width: parent.width
            height: 1
            color: p3
        }
    }

    ListView {
        id: medalList
        anchors.top: header.bottom
        anchors.bottom: footer.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        clip: true
        model: gameLogic.medalLibrary
        spacing: 8
        boundsBehavior: Flickable.StopAtBounds

        delegate: Column {
            width: medalList.width
            spacing: 2

            property bool isUnlocked: {
                var unlockedList = gameLogic.achievements
                var found = false
                for (var i = 0; i < unlockedList.length; i++) {
                    if (unlockedList[i] === modelData.id) {
                        found = true
                        break
                    }
                }
                return found
            }

            Text {
                text: isUnlocked ? ("★ " + modelData.id) : "??? [Locked]"
                font.family: gameFont
                font.pixelSize: 10
                font.bold: isUnlocked
                color: p3
                width: parent.width
                wrapMode: Text.WordWrap
            }

            Text {
                text: isUnlocked ? "Status: Unlocked!" : ("Hint: " + modelData.hint)
                font.family: gameFont
                font.pixelSize: 8
                color: p3
                opacity: 0.6
                width: parent.width
                wrapMode: Text.WordWrap
            }

            Rectangle {
                width: parent.width
                height: 1
                color: p3
                opacity: 0.1
            }
        }

        // Handle Keys for Navigation
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Up) {
                medalList.flick(0, 500)
                event.accepted = true
            } else if (event.key === Qt.Key_Down) {
                medalList.flick(0, -500)
                event.accepted = true
            } else if (event.key === Qt.Key_B || event.key === Qt.Key_X || event.key === Qt.Key_Back) {
                root.closeRequested()
                event.accepted = true
            }
        }
    }

    Rectangle {
        id: footer
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 20
        height: 20
        color: "transparent"

        Text {
            anchors.centerIn: parent
            text: qsTr("UP/DOWN to Scroll | B to Close")
            font.family: gameFont
            font.pixelSize: 8
            color: p3
            opacity: 0.6
        }
    }
}
