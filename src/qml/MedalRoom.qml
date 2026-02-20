import QtQuick
import QtQuick.Controls

Rectangle {
    id: medalRoot
    anchors.fill: parent
    color: p0
    z: 110

    property color p0
    property color p3
    property string gameFont
    signal closeRequested

    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Text {
            text: "ACHIEVEMENTS"
            color: p3
            font.family: gameFont
            font.pixelSize: 14
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ListView {
            id: medalList
            width: parent.width
            height: parent.height - 50
            model: gameLogic.medalLibrary
            currentIndex: gameLogic.medalIndex
            clip: true
            spacing: 5
            onCurrentIndexChanged: medalList.positionViewAtIndex(currentIndex, ListView.Contain)

            delegate: Rectangle {
                width: parent.width
                height: 40
                color: gameLogic.medalIndex === index ? p2 : p1
                border.color: gameLogic.medalIndex === index ? p3 : p2
                border.width: 1

                readonly property bool unlocked: gameLogic.achievements.indexOf(modelData.id) !== -1

                Row {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 8
                    
                    Rectangle {
                        width: 24; height: 24
                        color: unlocked ? p3 : p0
                        radius: 12
                        border.color: p3
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            anchors.centerIn: parent
                            text: unlocked ? "★" : "?"
                            color: unlocked ? p0 : p3
                            font.pixelSize: 12
                        }
                    }

                    Column {
                        width: parent.width - 40
                        Text {
                            text: unlocked ? modelData.id : "?????????"
                            color: p3
                            font.family: gameFont
                            font.pixelSize: 9
                            font.bold: true
                        }
                        Text {
                            text: unlocked ? "UNLOCKED" : modelData.hint
                            color: p3
                            font.family: gameFont
                            font.pixelSize: 7
                            opacity: 0.7
                        }
                    }
                }
            }
        }

        Text {
            text: "START to Back"
            color: p3
            font.family: gameFont
            font.pixelSize: 8
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
