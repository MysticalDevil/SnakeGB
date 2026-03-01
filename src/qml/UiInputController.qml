import QtQuick
import SnakeGB 1.0

QtObject {
    id: controller

    property var commandController
    property var actionRouter
    property var inputPressController
    property var debugController
    property var shellBridge
    property var audioSettingsViewModel
    property var showVolumeOsd
    property bool iconDebugMode: false
    property var actionMap: ({})
    readonly property var directionActionByAxis: ({
        up: "NavUp",
        down: "NavDown",
        left: "NavLeft",
        right: "NavRight"
    })
    readonly property var pressedKeyActions: ({
        [Qt.Key_Up]: { type: "dispatch", action: "NavUp" },
        [Qt.Key_Down]: { type: "dispatch", action: "NavDown" },
        [Qt.Key_Left]: { type: "dispatch", action: "NavLeft" },
        [Qt.Key_Right]: { type: "dispatch", action: "NavRight" },
        [Qt.Key_A]: { type: "primary_press" },
        [Qt.Key_Z]: { type: "primary_press" },
        [Qt.Key_B]: { type: "secondary_press" },
        [Qt.Key_X]: { type: "secondary_press" },
        [Qt.Key_S]: { type: "start_press" },
        [Qt.Key_Return]: { type: "start_press" },
        [Qt.Key_C]: { type: "dispatch", action: "ToggleShellColor" },
        [Qt.Key_Y]: { type: "dispatch", action: "ToggleShellColor" },
        [Qt.Key_M]: { type: "dispatch", action: "ToggleMusic" },
        [Qt.Key_Back]: { type: "dispatch", action: "Back" },
        [Qt.Key_Escape]: { type: "dispatch", action: "Escape" },
        [Qt.Key_F6]: { type: "dispatch", action: "ToggleIconLab" },
        [Qt.Key_F7]: { type: "static_cycle", step: 1 },
        [Qt.Key_Shift]: { type: "select_press" }
    })
    readonly property var releasedKeyActions: ({
        [Qt.Key_A]: { type: "primary_release" },
        [Qt.Key_Z]: { type: "primary_release" },
        [Qt.Key_B]: { type: "secondary_release" },
        [Qt.Key_X]: { type: "secondary_release" },
        [Qt.Key_S]: { type: "start_release" },
        [Qt.Key_Return]: { type: "start_release" },
        [Qt.Key_Shift]: { type: "select_release" }
    })

    function dispatchAction(action) {
        controller.inputPressController.beforeDispatch(action)
        controller.actionRouter.route(action)
    }

    function setDpadPressed(dx, dy) {
        controller.shellBridge.setDirectionPressed(dx, dy)
    }

    function clearDirectionVisuals() {
        controller.shellBridge.clearDirectionPressed()
    }

    function actionForDirection(dx, dy) {
        if (dy < 0) {
            return controller.actionMap[controller.directionActionByAxis.up]
        }
        if (dy > 0) {
            return controller.actionMap[controller.directionActionByAxis.down]
        }
        if (dx < 0) {
            return controller.actionMap[controller.directionActionByAxis.left]
        }
        if (dx > 0) {
            return controller.actionMap[controller.directionActionByAxis.right]
        }
        return ""
    }

    function handleDirection(dx, dy) {
        const action = controller.actionForDirection(dx, dy)
        if (action !== "") {
            controller.commandController.dispatch(action)
        }
        controller.setDpadPressed(dx, dy)
    }

    function handlePrimaryAction() {
        if (controller.inputPressController.confirmSaveClear()) {
            return
        }
        if (controller.debugController.handleEasterInput("A")) {
            return
        }
        controller.commandController.dispatch(controller.actionMap.Primary)
    }

    function handleSecondaryAction() {
        if (controller.debugController.handleEasterInput("B")) {
            return
        }
        controller.commandController.dispatch(controller.actionMap.Secondary)
    }

    function handleStartAction() {
        if (controller.iconDebugMode) {
            return
        }
        controller.commandController.dispatch(controller.actionMap.Start)
    }

    function handleSelectShortAction() {
        controller.inputPressController.triggerSelectShort()
    }

    function handleBackAction() {
        if (controller.iconDebugMode) {
            controller.debugController.exitIconLab()
            return
        }
        controller.commandController.dispatch(controller.actionMap.Back)
    }

    function cancelSaveClearConfirm(showToast) {
        controller.inputPressController.cancelSaveClearConfirm(showToast)
    }

    function handleShellBridgeDirection(dx, dy) {
        const action = controller.actionForDirection(dx, dy)
        if (action !== "") {
            controller.dispatchAction(action)
        }
    }

    function handlePressedDispatch(actionKey) {
        controller.dispatchAction(controller.actionMap[actionKey])
    }

    function handlePrimaryPressed() {
        controller.shellBridge.primaryPressed = true
        controller.dispatchAction(controller.actionMap.Primary)
    }

    function handleSecondaryPressed() {
        controller.shellBridge.secondaryPressed = true
        controller.dispatchAction(controller.actionMap.Secondary)
    }

    function handleStartPressed() {
        controller.shellBridge.startHeld = true
        controller.inputPressController.onStartPressed()
        controller.dispatchAction(controller.actionMap.Start)
    }

    function handleSelectPressed() {
        if (controller.inputPressController.selectKeyDown) {
            return
        }
        controller.inputPressController.selectKeyDown = true
        controller.shellBridge.selectHeld = true
        controller.inputPressController.onSelectPressed()
    }

    function handleStartReleased() {
        controller.shellBridge.startHeld = false
        controller.inputPressController.onStartReleased()
    }

    function handleSelectReleased() {
        controller.inputPressController.selectKeyDown = false
        controller.shellBridge.selectHeld = false
        controller.inputPressController.onSelectReleased()
        controller.dispatchAction(controller.actionMap.SelectShort)
    }

    function applyKeyAction(actionSpec) {
        if (!actionSpec) {
            return
        }
        switch (actionSpec.type) {
        case "dispatch":
            controller.handlePressedDispatch(actionSpec.action)
            break
        case "primary_press":
            controller.handlePrimaryPressed()
            break
        case "secondary_press":
            controller.handleSecondaryPressed()
            break
        case "start_press":
            controller.handleStartPressed()
            break
        case "select_press":
            controller.handleSelectPressed()
            break
        case "static_cycle":
            controller.debugController.cycleStaticScene(actionSpec.step)
            break
        case "primary_release":
            controller.shellBridge.primaryPressed = false
            break
        case "secondary_release":
            controller.shellBridge.secondaryPressed = false
            break
        case "start_release":
            controller.handleStartReleased()
            break
        case "select_release":
            controller.handleSelectReleased()
            break
        }
    }

    function handleShellColorToggle() {
        controller.commandController.dispatch("feedback_ui")
        controller.commandController.dispatch("toggle_shell_color")
    }

    function handleVolumeRequested(value, withHaptic) {
        controller.audioSettingsViewModel.volume = value
        controller.showVolumeOsd(value)
        if (withHaptic) {
            controller.commandController.dispatch("feedback_light")
        }
    }

    function handleKeyPressed(event) {
        if (event.isAutoRepeat) {
            return
        }
        controller.applyKeyAction(controller.pressedKeyActions[event.key])
    }

    function handleKeyReleased(event) {
        if (event.isAutoRepeat) {
            return
        }
        controller.clearDirectionVisuals()
        controller.applyKeyAction(controller.releasedKeyActions[event.key])
    }
}
