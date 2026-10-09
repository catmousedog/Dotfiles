// HyprlandService.qml
// Hyprland options the bar follows, re-read when Hyprland reloads its config.

pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property int gapsOut: 0
    property int gapsIn: 0
    property int borderSize: 0

    Component.onCompleted: refresh()

    function refresh() {
        optionsProc.running = true;
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "configreloaded")
                root.refresh();
        }
    }

    // one hyprctl call for all options: --batch prints the JSON replies one after another
    Process {
        id: optionsProc
        command: ["hyprctl", "-j", "--batch", "getoption general:gaps_out; getoption general:gaps_in; getoption general:border_size"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const replies = JSON.parse("[" + text.trim().replace(/}\s*{/g, "},{") + "]");
                    for (const reply of replies) {
                        const value = reply.int ?? parseInt(reply.css.split(" ")[0]);
                        if (reply.option === "general:gaps_out")
                            root.gapsOut = value;
                        else if (reply.option === "general:gaps_in")
                            root.gapsIn = value;
                        else if (reply.option === "general:border_size")
                            root.borderSize = value;
                    }
                } catch (e) {
                    console.error("[HyprlandService] Failed to parse hyprctl options:", e, text);
                }
            }
        }
    }
}
