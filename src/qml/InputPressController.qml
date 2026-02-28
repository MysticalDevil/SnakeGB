import QtQuick
import SnakeGB 1.0

Item {
    id: controller

    property int currentState: AppState.Splash
    property bool hasSave: false
    property bool iconDebugMode: false
    property var actionMap: ({})
    property var showOsd
    property var dispatchUiAction

    property bool selectPressActive: false
    property bool selectLongPressConsumed: false
    property bool selectKeyDown: false
    property bool startPressActive: false
    property bool saveClearConfirmPending: false

    function beforeDispatch(action) {
        if (controller.saveClearConfirmPending && action !== controller.actionMap.Primary) {
            cancelSaveClearConfirm(false)
        }
    }

    function onSelectPressed() {
        controller.selectPressActive = true
        controller.selectLongPressConsumed = false
        selectHoldTimer.restart()
    }

    function onSelectReleased() {
        controller.selectPressActive = false
        selectHoldTimer.stop()
    }

    function onStartPressed() {
        controller.startPressActive = true
    }

    function onStartReleased() {
        controller.startPressActive = false
    }

    function triggerSelectShort() {
        if (controller.iconDebugMode) {
            return true
        }
        if (controller.selectLongPressConsumed) {
            controller.selectLongPressConsumed = false
            return true
        }
        if (controller.dispatchUiAction) {
            controller.dispatchUiAction(controller.actionMap.SelectShort)
        }
        return true
    }

    function confirmSaveClear() {
        if (!controller.saveClearConfirmPending ||
                controller.currentState !== AppState.StartMenu ||
                !controller.hasSave) {
            return false
        }
        controller.saveClearConfirmPending = false
        saveClearConfirmTimer.stop()
        if (controller.dispatchUiAction) {
            controller.dispatchUiAction("delete_save")
            controller.dispatchUiAction("feedback_heavy")
        }
        if (controller.showOsd) {
            controller.showOsd("SAVE CLEARED")
        }
        return true
    }

    function cancelSaveClearConfirm(showToast) {
        if (!controller.saveClearConfirmPending) {
            return
        }
        controller.saveClearConfirmPending = false
        saveClearConfirmTimer.stop()
        if (showToast && controller.showOsd) {
            controller.showOsd("SAVE CLEAR CANCELED")
        }
    }

    Timer {
        id: selectHoldTimer
        interval: 700
        repeat: false
        onTriggered: {
            if (!controller.selectPressActive || controller.selectLongPressConsumed) {
                return
            }
            if (controller.currentState === AppState.StartMenu &&
                    controller.hasSave &&
                    controller.startPressActive) {
                controller.selectLongPressConsumed = true
                controller.saveClearConfirmPending = true
                saveClearConfirmTimer.restart()
                if (controller.showOsd) {
                    controller.showOsd("PRESS A TO CLEAR SAVE")
                }
            }
        }
    }

    Timer {
        id: saveClearConfirmTimer
        interval: 2600
        repeat: false
        onTriggered: controller.cancelSaveClearConfirm(true)
    }
}
