// OverviewService.qml
// Zoomed out view of the watrix grid, see OverviewOverlay. Every cell shows
// the windows of that logical workspace on each monitor, so empty ones stand out.

pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import qs.config

Singleton {
    id: root

    // same as watrix-common.fish
    readonly property int matrix: 3
    readonly property int numWorkspaces: matrix * matrix

    // true while the overlay is open
    property bool active: false
    // the monitor it opened on
    property string monitor: ""

    readonly property var screen: Quickshell.screens.find(s => s.name === monitor) ?? null

    // Same order as get_monitors in watrix-common.fish: built-in panels first,
    // then alphabetical. Index i owns workspaces [i * 9 + 1, i * 9 + 9].
    readonly property var monitors: Hyprland.monitors.values.slice().sort((a, b) => {
        const ae = a.name.startsWith("eDP"), be = b.name.startsWith("eDP");
        return ae !== be ? (ae ? -1 : 1) : a.name.localeCompare(b.name);
    })

    // logical id [0, 9[ of the focused workspace, -1 for a special one
    readonly property int current: {
        const id = Hyprland.focusedWorkspace?.id ?? -1;
        return id < 1 ? -1 : (id - 1) % numWorkspaces;
    }

    function toggle(): void {
        if (active) {
            active = false;
            return;
        }
        monitor = Hyprland.focusedMonitor?.name ?? Quickshell.screens[0].name;
        // window classes and positions come from hyprctl clients, monitor
        // rotation from hyprctl monitors: make sure they are up to date
        Hyprland.refreshToplevels();
        Hyprland.refreshMonitors();
        active = true;
    }

    function close(): void {
        active = false;
    }

    // Windows on logical workspace id of monitor index mon
    function toplevels(id: int, mon: int): var {
        const actual = id + mon * numWorkspaces + 1;
        const ws = Hyprland.workspaces.values.find(w => w.id === actual);
        return ws ? ws.toplevels.values : [];
    }

    // Size of a monitor in layout coordinates, which is what window positions use
    function logicalSize(monitor: var): var {
        const rotated = (monitor.lastIpcObject?.transform ?? 0) % 2 === 1;
        const scale = monitor.scale || 1;
        return {
            w: (rotated ? monitor.height : monitor.width) / scale,
            h: (rotated ? monitor.width : monitor.height) / scale
        };
    }

    // Icons replaced in the rofi launcher, desktop entry id -> icon name or path.
    // Read from the same apps.txt so both show the same icon.
    property var iconOverrides: ({})

    FileView {
        path: Quickshell.env("HOME") + "/.config/rofi/apps.txt"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const overrides = {};
            for (const line of text().split("\n")) {
                const match = line.match(/^\s*([^#\s]\S*)\s+.*\bicon=(\S+)/);
                if (match)
                    overrides[match[1]] = match[2];
            }
            root.iconOverrides = overrides;
        }
    }

    function appId(toplevel: var): string {
        return toplevel.wayland?.appId || toplevel.lastIpcObject?.class || "";
    }

    function iconFor(appId: string): string {
        const entry = appId ? DesktopEntries.heuristicLookup(appId) : null;
        const override = iconOverrides[entry?.id ?? appId];
        if (override && /^[~\/]/.test(override))
            return "file://" + override.replace(/^~/, Quickshell.env("HOME"));
        return Quickshell.iconPath(override || entry?.icon || appId, "application-x-executable");
    }

    function appIcon(toplevel: var): string {
        return iconFor(appId(toplevel));
    }

    // Window colors per app id or desktop entry id, as theme roles ("green",
    // "blue", ...) so they follow the theme. Unlisted apps get the muted color.
    readonly property var appColors: ConfigService.get("overview.appColors") ?? {}

    function appColor(toplevel: var): color {
        const id = appId(toplevel);
        const entryId = id ? DesktopEntries.heuristicLookup(id)?.id : null;
        return Theme.getColor(appColors[id] ?? appColors[entryId] ?? "") || Theme.muted;
    }

    function goTo(id: int): void {
        active = false;
        Quickshell.execDetached([Quickshell.env("HOME") + "/.config/hypr/scripts/watrix.fish", "goto", String(id)]);
    }

    // Bound in keybinds.lua
    GlobalShortcut {
        appid: "quickshell"
        name: "overview"
        description: "Show the watrix grid"
        onPressed: root.toggle()
    }

    // quickshell ipc call overview toggle
    IpcHandler {
        target: "overview"

        function toggle(): void {
            root.toggle();
        }
    }
}
