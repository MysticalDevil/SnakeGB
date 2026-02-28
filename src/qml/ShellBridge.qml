import QtQuick

QtObject {
    id: bridge

    property bool upPressed: false
    property bool downPressed: false
    property bool leftPressed: false
    property bool rightPressed: false
    property bool primaryPressed: false
    property bool secondaryPressed: false
    property bool selectPressed: false
    property bool startPressed: false

    signal directionRequested(int dx, int dy)
    signal primaryRequested()
    signal secondaryRequested()
    signal selectPressBegan()
    signal selectPressEnded()
    signal selectRequested()
    signal startPressBegan()
    signal startPressEnded()
    signal startRequested()
    signal shellColorToggleRequested()
    signal volumeRequested(real value, bool withHaptic)

    function setDirectionPressed(dx, dy) {
        upPressed = dy < 0
        downPressed = dy > 0
        leftPressed = dx < 0
        rightPressed = dx > 0
    }

    function clearDirectionPressed() {
        upPressed = false
        downPressed = false
        leftPressed = false
        rightPressed = false
    }
}
