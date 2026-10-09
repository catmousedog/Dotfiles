// WorkspaceIndicator.qml
// Scroll: move up/down the watrix grid, shift + scroll: left/right

import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.components.generic

Barbox {

    implicitHeight: parent.height
    implicitWidth: parent.height * 1.1

    WheelHandler {
        property real last: 0

        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            // one step per 250 ms, touchpads send a burst of events
            if (Date.now() - last < 250)
                return;
            last = Date.now();
            // shift turns a vertical wheel into a horizontal one on some setups
            const delta = event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x;
            const horizontal = (event.modifiers & Qt.ShiftModifier) || event.angleDelta.y === 0;
            const dir = horizontal ? (delta > 0 ? "left" : "right") : (delta > 0 ? "up" : "down");
            Quickshell.execDetached([Quickshell.env("HOME") + "/.config/hypr/scripts/watrix.fish", "workspace", dir]);
        }
    }

    Bartext {
        anchors.centerIn: parent
        text: getIcon()
        font.weight: 1000

        function getIcon() {
            let id = WorkspaceService.activeWorkspace?.id ?? -1;
            if (id == -1)
                return "";

            id = (id - 1) % 9;

            const icons = ["󰁛", "󰁝", "󰁜", "󰁍", "", "󰁔", "󰁂", "󰁅", "󰁃"];
            return icons[id];
        }
    }
}
