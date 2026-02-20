import QtQuick
import QtQuick.Controls

Rectangle {
    id: medalRoot
    anchors.fill: parent
    color: p0
    z: 1000

    property color p0
    property color p3
    property string gameFont

    Column {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10

        Text {
            text: "ACHIEVEMENTS"
            color: p3
            font.family: gameFont
            font.pixelSize: 20
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle { width: parent.width; height: 2; color: p3; opacity: 0.5 }

        ListView {
            id: medalList
            width: parent.width
            height: parent.height - 60
            model: gameLogic.medalLibrary
            currentIndex: gameLogic.medalIndex
            clip: true
            spacing: 6
            onCurrentIndexChanged: medalList.positionViewAtIndex(currentIndex, ListView.Contain)

            delegate: Rectangle {
                width: parent.width
                height: 42
                color: gameLogic.medalIndex === index ? p2 : p1
                border.color: p3
                border.width: gameLogic.medalIndex === index ? 2 : 1

                readonly property bool unlocked: gameLogic.achievements.indexOf(modelData.id) !== -1

                Row {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 12
                    
                    Rectangle {
                        width: 28; height: 28
                        color: unlocked ? p3 : p0
                        radius: 14
                        border.color: p3
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            anchors.centerIn: parent
                            text: unlocked ? "★" : "?"
                            color: unlocked ? p0 : p3
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }

                    Column {
                        width: parent.width - 50
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            text: unlocked ? modelData.id : "?????????"
                            color: p3
                            font.family: gameFont
                            font.pixelSize: 11
                            font.bold: true
                        }
                        Text {
                            text: unlocked ? "UNLOCKED" : modelData.hint
                            color: p3
                            font.family: gameFont
                            font.pixelSize: 7
                            opacity: 0.7
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
    }
}
