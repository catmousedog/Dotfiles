// KeyboardService.qml

pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property string layout

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
