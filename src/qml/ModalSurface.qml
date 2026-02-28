import QtQuick

Item {
    id: modalSurface
    property bool active: false
    property var blurSourceItem: null
    property real blurScale: 2.5
    property color tintColor: "transparent"
    property color panelColor: "white"
    property color panelBorderColor: "black"
    property color panelInnerBorderColor: Qt.rgba(1, 1, 1, 0.12)
    property real panelWidth: 184
    property real panelHeight: 64
    property real panelRadius: 4
    property real panelOffsetY: 0
    property real contentMargin: 0
    default property alias content: panelContent.data
    property alias panelItem: panel
    property alias contentItem: panelContent

    anchors.fill: parent
    visible: active

    ShaderEffectSource {
        id: blurSource
        sourceItem: modalSurface.blurSourceItem
        live: true
        recursive: false
        hideSource: false
    }

    ShaderEffect {
        anchors.fill: parent
        visible: modalSurface.visible && !!modalSurface.blurSourceItem
        property variant source: blurSource
        property vector2d texelStep: Qt.vector2d(1.0 / Math.max(1.0, width), 1.0 / Math.max(1.0, height))
        property real blurScale: modalSurface.blurScale
        fragmentShader: "qrc:/shaders/src/qml/blur.frag.qsb"
    }

    Rectangle {
        anchors.fill: parent
        color: modalSurface.tintColor
    }

    Rectangle {
        id: panel
        width: modalSurface.panelWidth
        height: modalSurface.panelHeight
        radius: modalSurface.panelRadius
        anchors.centerIn: parent
        anchors.verticalCenterOffset: modalSurface.panelOffsetY
        color: modalSurface.panelColor
        border.color: modalSurface.panelBorderColor
        border.width: 1

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: Math.max(0, modalSurface.panelRadius - 1)
            color: "transparent"
            border.color: modalSurface.panelInnerBorderColor
            border.width: 1
        }

        Item {
            id: panelContent
            anchors.fill: parent
            anchors.margins: modalSurface.contentMargin
        }
    }
}
