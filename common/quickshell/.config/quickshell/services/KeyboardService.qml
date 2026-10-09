// KeyboardService.qml

pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property string layout

    // Time of the last shift + scroll, sent by a Hyprland bind (see keybinds.lua)
    // because the bar itself never receives keyboard modifiers
    property real shiftScrollAt: 0

    GlobalShortcut {
        appid: "quickshell"
        name: "shiftScroll"
        description: "Sent on shift + scroll, for the workspace indicator"
        onPressed: root.shiftScrollAt = Date.now()
    }

    Process {
        id: initFetch
        command: ["hyprctl", "-j", "devices"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const devices = JSON.parse(text);
                    const kb = devices.keyboards.find(k => k.main);
                    if (kb)
                        root.layout = kb.active_keymap;
                } catch (e) {
                    console.warn("Failed to parse hyprctl devices:", e);
                }
            }
        }
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "activelayout") {
                // activelayout has 2 args: keyboardName, layoutName
                const args = event.parse(2);
                root.layout = args[1];  // e.g. "English (US)" or "Belgian"
            }
        }
    }
}
