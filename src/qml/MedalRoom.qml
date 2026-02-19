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

    Column {
        anchors.centerIn: parent
        width: parent.width - 40
        spacing: 10

        Text {
            text: "MEDAL COLLECTION"
            font.family: gameFont
            font.pixelSize: 16
            font.bold: true
            color: p3
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            width: parent.width
            height: 1
            color: p3
        }

        Repeater {
            model: gameLogic.medalLibrary
            delegate: Column {
                width: parent.width
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
                    text: isUnlocked ? "Unlocked!" : ("Hint: " + modelData.hint)
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
        }

        Text {
            text: qsTr("Press B to Close")
            font.family: gameFont
            font.pixelSize: 8
            color: p3
            opacity: 0.6
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    // Capture input to allow closing
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_B || event.key === Qt.Key_X || event.key === Qt.Key_Back) {
            root.closeRequested()
            event.accepted = true
        }
    }
}
