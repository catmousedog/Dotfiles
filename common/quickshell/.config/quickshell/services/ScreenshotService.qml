// ScreenshotService.qml
// Takes a frozen capture of the focused monitor with grim, then lets
// ScreenshotOverlay pick a region of it. The result goes to the clipboard and,
// if asked for when taking it, to a file as well.

pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // true while the overlay is open
    property bool active: false
    property string monitor: ""
    // the frozen capture the overlay shows and crops from
    property string shot: ""

    // Visible windows of that monitor as { x, y, w, h } relative to it, most
    // recently focused first. The overlay cycles through them with tab.
    property var windows: []

    readonly property var screen: Quickshell.screens.find(s => s.name === monitor) ?? null
    readonly property string tmpDir: Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"
    readonly property string saveDir: ConfigService.get("screenshot.directory").replace(/^~/, Quickshell.env("HOME"))

    signal confirmRequested(save: bool)

    function start(): void {
        if (active || grim.running)
            return;
        monitor = Hyprland.focusedMonitor?.name ?? Quickshell.screens[0].name;
        shot = tmpDir + "/quickshell-screenshot-" + Date.now() + ".ppm";
        // ppm: no time lost compressing an image that is thrown away again
        grim.command = ["sh", "-c", 'mkdir -p "$1" && exec grim -t ppm -o "$2" "$3"', "sh", saveDir, monitor, shot];
        grim.running = true;
        windows = [];
        clients.running = true;
    }

    function cancel(): void {
        if (!active)
            return;
        active = false;
        Quickshell.execDetached(["rm", "-f", shot]);
    }

    // Where the overlay should write the cropped png
    function outputPath(save: bool): string {
        if (save)
            return saveDir + "/Screenshot_" + Qt.formatDateTime(new Date(), "yyyy-MM-dd_HH-mm-ss") + ".png";
        return shot.replace(/\.ppm$/, ".png");
    }

    // Called by the overlay once the png is written
    function finish(png: string, save: bool): void {
        active = false;
        // wl-copy has read the file by the time it returns, so it can be removed right after
        const script = `wl-copy -t image/png < "$1"
            if [ "$3" = save ]; then
                notify-send -a Screenshot -i "$1" "Screenshot saved" "$1"
            else
                notify-send -a Screenshot -t 2000 "Screenshot copied"
                rm -f "$1"
            fi
            rm -f "$2"`;
        Quickshell.execDetached(["sh", "-c", script, "sh", png, shot, save ? "save" : "copy"]);
    }

    Process {
        id: grim
        onExited: exitCode => {
            if (exitCode === 0)
                root.active = true;
            else
                console.warn("[ScreenshotService] grim failed with code", exitCode);
        }
    }

    function parseWindows(text: string): void {
        try {
            const [clientsJson, monitorsJson] = text.split("@@");
            const mon = JSON.parse(monitorsJson).find(m => m.name === monitor);
            // a shown special workspace sits on top of the regular one
            const special = mon.specialWorkspace.name !== "" ? mon.specialWorkspace.id : null;
            const onTop = c => c.workspace.id === special ? 0 : 1;
            windows = JSON.parse(clientsJson)
                .filter(c => c.mapped && !c.hidden && (c.workspace.id === special || c.workspace.id === mon.activeWorkspace.id))
                .sort((a, b) => onTop(a) - onTop(b) || a.focusHistoryID - b.focusHistoryID)
                .map(c => ({ x: c.at[0] - mon.x, y: c.at[1] - mon.y, w: c.size[0], h: c.size[1] }));
        } catch (e) {
            console.warn("[ScreenshotService] Failed to parse hyprctl output:", e);
        }
    }

    Process {
        id: clients
        command: ["sh", "-c", "hyprctl -j clients; echo @@; hyprctl -j monitors"]
        stdout: StdioCollector {
            onStreamFinished: root.parseWindows(text)
        }
    }

    // Bound in keybinds.lua
    GlobalShortcut {
        appid: "quickshell"
        name: "screenshot"
        description: "Select a region and copy it to the clipboard"
        onPressed: root.start()
    }

    // quickshell ipc call screenshot start
    IpcHandler {
        target: "screenshot"

        function start(): void {
            root.start();
        }

        function confirm(save: bool): void {
            root.confirmRequested(save);
        }

        function cancel(): void {
            root.cancel();
        }
    }
}
