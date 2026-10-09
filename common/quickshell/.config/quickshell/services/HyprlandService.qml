// HyprlandService.qml

pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property int gapsOut: 0
    property int gapsIn: 0

    Component.onCompleted: {
        gapsOutProc.running = true;
        gapsInProc.running = true;
    }

    Process {
        id: gapsOutProc
        command: ["hyprctl", "getoption", "general:gaps_out", "-j"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const parsed = JSON.parse(data);
                    root.gapsOut = parseInt(parsed.css.split(" ")[0]);
                } catch (e) {
                    console.error("[HyprlandService] Failed to parse gaps_out:", e);
                }
            }
        }
    }

    Process {
        id: gapsInProc
        command: ["hyprctl", "getoption", "general:gaps_in", "-j"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const parsed = JSON.parse(data);
                    root.gapsIn = parseInt(parsed.css.split(" ")[0]);
                } catch (e) {
                    console.error("[HyprlandService] Failed to parse gaps_in:", e);
                }
            }
        }
    }
}
