// WorkspaceService.qml
// Parts taken from https://github.com/caioax/lyne-dots

pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Hyprland

Singleton {
    readonly property var parentWindow: QsWindow.window
    readonly property var parentScreen: parentWindow?.screen ?? null

    property var currentMonitor: {
        if (!Hyprland)
            return null;
        return (parentScreen ? Hyprland.monitorFor(parentScreen) : null) ?? Hyprland.focusedMonitor ?? null;
    }

    readonly property string monitorName: currentMonitor?.name ?? "test"
    property var activeWorkspace: currentMonitor?.activeWorkspace ?? null
}
