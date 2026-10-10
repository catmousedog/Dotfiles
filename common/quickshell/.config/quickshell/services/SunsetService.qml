// SunsetService.qml
// Night light: runs hyprsunset while enabled, quitting it restores the colors

pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool enabled: false
    readonly property int temperature: ConfigService.get("right.sunset.temperature")

    function toggle() {
        enabled = !enabled;
    }

    Process {
        command: ["hyprsunset", "--temperature", root.temperature]
        running: root.enabled
        // hyprsunset missing or crashed
        onRunningChanged: if (!running)
            root.enabled = false
    }
}
