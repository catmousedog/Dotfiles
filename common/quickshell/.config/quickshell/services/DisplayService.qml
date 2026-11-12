// DisplayService.qml
// What each external screen does (extend / mirror / off), through the
// `display` script. The screens and modes come from the host's host.lua, see
// ~/.config/hypr/conf/display.lua.

pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // [{name, label, mode, connected}] in host.lua's order
    property var screens: []
    readonly property var connected: screens.filter(s => s.connected)
    readonly property var modes: ["extend", "mirror", "off"]

    readonly property string script: Quickshell.env("HOME") + "/.local/bin/display"
    readonly property string statePath: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/display/modes"

    Component.onCompleted: refresh()

    function refresh() {
        statusProc.running = true;
    }

    function set(name, mode) {
        run([root.script, "set", name, mode]);
    }

    function toggle() {
        run([root.script, "toggle"]);
    }

    function run(command) {
        actionProc.command = command;
        actionProc.running = true;
    }

    function icon() {
        if (connected.some(s => s.mode === "extend"))
            return "󰍺";
        if (connected.some(s => s.mode === "mirror"))
            return "󱒃";
        return "󰶐";
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name.startsWith("monitoradded") || event.name.startsWith("monitorremoved") || event.name === "configreloaded")
                root.refresh();
        }
    }

    // mirror on/off fires no monitor event, the saved modes file changes either way
    FileView {
        path: root.statePath
        watchChanges: true
        printErrors: false
        onFileChanged: root.refresh()
    }

    Process {
        id: statusProc
        command: [root.script, "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.screens = JSON.parse(text);
                } catch (e) {
                    console.error("[DisplayService] Failed to parse `display status`:", e, text);
                }
            }
        }
    }

    Process {
        id: actionProc
        onExited: root.refresh()
    }
}
