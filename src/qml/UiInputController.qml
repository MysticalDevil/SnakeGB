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

    function handleDirection(dx, dy) {
        if (dy < 0) {
            controller.commandController.dispatch(controller.actionMap.NavUp)
        } else if (dy > 0) {
            controller.commandController.dispatch(controller.actionMap.NavDown)
        } else if (dx < 0) {
            controller.commandController.dispatch(controller.actionMap.NavLeft)
        } else if (dx > 0) {
            controller.commandController.dispatch(controller.actionMap.NavRight)
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
        if (dy < 0) {
            controller.dispatchAction(controller.actionMap.NavUp)
        } else if (dy > 0) {
            controller.dispatchAction(controller.actionMap.NavDown)
        } else if (dx < 0) {
            controller.dispatchAction(controller.actionMap.NavLeft)
        } else if (dx > 0) {
            controller.dispatchAction(controller.actionMap.NavRight)
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
        if (event.key === Qt.Key_Up) {
            controller.dispatchAction(controller.actionMap.NavUp)
        } else if (event.key === Qt.Key_Down) {
            controller.dispatchAction(controller.actionMap.NavDown)
        } else if (event.key === Qt.Key_Left) {
            controller.dispatchAction(controller.actionMap.NavLeft)
        } else if (event.key === Qt.Key_Right) {
            controller.dispatchAction(controller.actionMap.NavRight)
        } else if (event.key === Qt.Key_S || event.key === Qt.Key_Return) {
            controller.shellBridge.startHeld = true
            controller.inputPressController.onStartPressed()
            controller.dispatchAction(controller.actionMap.Start)
        } else if (event.key === Qt.Key_A || event.key === Qt.Key_Z) {
            controller.shellBridge.primaryPressed = true
            controller.dispatchAction(controller.actionMap.Primary)
        } else if (event.key === Qt.Key_F6) {
            controller.dispatchAction(controller.actionMap.ToggleIconLab)
        } else if (event.key === Qt.Key_F7) {
            controller.debugController.cycleStaticScene(1)
        } else if (event.key === Qt.Key_B || event.key === Qt.Key_X) {
            controller.shellBridge.secondaryPressed = true
            controller.dispatchAction(controller.actionMap.Secondary)
        } else if (event.key === Qt.Key_C || event.key === Qt.Key_Y) {
            controller.dispatchAction(controller.actionMap.ToggleShellColor)
        } else if (event.key === Qt.Key_Shift) {
            if (controller.inputPressController.selectKeyDown) {
                return
            }
            controller.inputPressController.selectKeyDown = true
            controller.shellBridge.selectHeld = true
            controller.inputPressController.onSelectPressed()
        } else if (event.key === Qt.Key_M) {
            controller.dispatchAction(controller.actionMap.ToggleMusic)
        } else if (event.key === Qt.Key_Back) {
            controller.dispatchAction(controller.actionMap.Back)
        } else if (event.key === Qt.Key_Escape) {
            controller.dispatchAction(controller.actionMap.Escape)
        }
    }

    function handleKeyReleased(event) {
        if (event.isAutoRepeat) {
            return
        }
        controller.clearDirectionVisuals()
        if (event.key === Qt.Key_S || event.key === Qt.Key_Return) {
            controller.shellBridge.startHeld = false
            controller.inputPressController.onStartReleased()
        } else if (event.key === Qt.Key_A || event.key === Qt.Key_Z) {
            controller.shellBridge.primaryPressed = false
        } else if (event.key === Qt.Key_B || event.key === Qt.Key_X) {
            controller.shellBridge.secondaryPressed = false
        } else if (event.key === Qt.Key_Shift) {
            controller.inputPressController.selectKeyDown = false
            controller.shellBridge.selectHeld = false
            controller.inputPressController.onSelectReleased()
            controller.dispatchAction(controller.actionMap.SelectShort)
        }
    }
}
