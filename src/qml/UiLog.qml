import QtQuick

QtObject {
    id: logger

    property var runtimeLogger
    readonly property string logMode: typeof appLogMode === "string" ? appLogMode : "release"
    readonly property bool isDebug: logMode === "debug"
    readonly property bool isDevOrDebug: logMode === "dev" || logMode === "debug"

    function inputSummary(message) {
        if (!isDevOrDebug || !runtimeLogger) {
            return
        }
        runtimeLogger.inputSummary(`[Input] ${message}`)
    }

    function inputDebug(message) {
        if (!isDebug || !runtimeLogger) {
            return
        }
        runtimeLogger.inputDebug(`[Input] ${message}`)
    }

    function routingSummary(message) {
        if (!isDevOrDebug || !runtimeLogger) {
            return
        }
        runtimeLogger.routingSummary(`[Route] ${message}`)
    }

    function routingDebug(message) {
        if (!isDebug || !runtimeLogger) {
            return
        }
        runtimeLogger.routingDebug(`[Route] ${message}`)
    }

    function injectWarning(message) {
        if (!isDevOrDebug || !runtimeLogger) {
            return
        }
        runtimeLogger.injectWarning(`[Inject] ${message}`)
    }
}
