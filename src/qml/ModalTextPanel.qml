import QtQuick

Item {
    id: textPanel
    property string titleText: ""
    property string bodyText: ""
    property string hintText: ""
    property string gameFont: ""
    property color titleColor: "white"
    property color bodyColor: titleColor
    property color hintColor: bodyColor
    property int titleSize: 18
    property int bodySize: 11
    property int hintSize: 9
    property bool titleBold: true
    property bool bodyBold: true
    property bool hintBold: true
    property int lineSpacing: 4
    property int horizontalPadding: 10

    anchors.fill: parent

    Column {
        anchors.centerIn: parent
        width: parent.width - (textPanel.horizontalPadding * 2)
        spacing: textPanel.lineSpacing

        Text {
            visible: textPanel.titleText.length > 0
            text: textPanel.titleText
            color: textPanel.titleColor
            font.family: textPanel.gameFont
            font.pixelSize: textPanel.titleSize
            font.bold: textPanel.titleBold
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            visible: textPanel.bodyText.length > 0
            text: textPanel.bodyText
            color: textPanel.bodyColor
            font.family: textPanel.gameFont
            font.pixelSize: textPanel.bodySize
            font.bold: textPanel.bodyBold
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            visible: textPanel.hintText.length > 0
            text: textPanel.hintText
            color: textPanel.hintColor
            font.family: textPanel.gameFont
            font.pixelSize: textPanel.hintSize
            font.bold: textPanel.hintBold
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
