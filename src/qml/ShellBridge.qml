import QtQuick

QtObject {
    id: bridge

    property bool upPressed: false
    property bool downPressed: false
    property bool leftPressed: false
    property bool rightPressed: false
    property bool primaryPressed: false
    property bool secondaryPressed: false
    property bool selectHeld: false
    property bool startHeld: false

    signal directionTriggered(int dx, int dy)
    signal primaryTriggered()
    signal secondaryTriggered()
    signal selectPressed()
    signal selectReleased()
    signal selectTriggered()
    signal startPressed()
    signal startReleased()
    signal startTriggered()
    signal shellColorToggleTriggered()
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
