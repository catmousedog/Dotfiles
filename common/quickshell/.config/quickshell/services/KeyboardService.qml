// KeyboardService.qml

pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // The layouts from Hyprland's kb_layout / kb_variant, in order:
    // [{ code: "be", variant: "", name: "Belgian" }, ...]
    property var layouts: []
    property int activeIndex: -1
    readonly property var active: layouts[activeIndex] ?? null

    // "BE", empty until hyprctl answered
    readonly property string short: active ? active.code.toUpperCase() : ""

    function setLayout(index) {
        Quickshell.execDetached(["hyprctl", "switchxkblayout", "all", index.toString()]);
    }

    function next() {
        Quickshell.execDetached(["hyprctl", "switchxkblayout", "all", "next"]);
    }

    // Time of the last shift + scroll, sent by a Hyprland bind (see keybinds.lua)
    // because the bar itself never receives keyboard modifiers
    property real shiftScrollAt: 0

    GlobalShortcut {
        appid: "quickshell"
        name: "shiftScroll"
        description: "Sent on shift + scroll, for the workspace indicator"
        onPressed: root.shiftScrollAt = Date.now()
    }

    /* ------------------------------------- Layout names ------------------------------------ */
    // xkb's own descriptions ("Russian (phonetic, YAZHERTY)"), from the rules list

    property var layoutNames: ({})
    property var variantNames: ({})

    FileView {
        path: "/usr/share/X11/xkb/rules/base.lst"
        onLoaded: {
            const layouts = {};
            const variants = {};
            let section = "";
            for (const line of text().split("\n")) {
                if (line.startsWith("! ")) {
                    section = line.slice(2).trim();
                    continue;
                }
                const m = line.match(/^\s+(\S+)\s+(.*)$/);
                if (!m)
                    continue;
                if (section === "layout")
                    layouts[m[1]] = m[2];
                else if (section === "variant") {
                    // "phonetic_YAZHERTY ru: Russian (phonetic, YAZHERTY)"
                    const v = m[2].match(/^(\S+): (.*)$/);
                    if (v)
                        variants[`${v[1]}(${m[1]})`] = v[2];
                }
            }
            root.layoutNames = layouts;
            root.variantNames = variants;
            root.refresh();
        }
    }

    /* ---------------------------------------- State --------------------------------------- */

    // Hyprland sends activelayout once per keyboard device: ask once for the burst
    function refresh() {
        refreshTimer.restart();
    }

    Timer {
        id: refreshTimer
        interval: 30
        onTriggered: devicesProc.running = true
    }

    Process {
        id: devicesProc
        command: ["hyprctl", "-j", "devices"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const keyboards = JSON.parse(text).keyboards;
                    const kb = keyboards.find(k => k.main) ?? keyboards[0];
                    if (!kb)
                        return;
                    const codes = kb.layout.split(",");
                    const variants = kb.variant.split(",");
                    root.layouts = codes.map((code, i) => {
                        const variant = variants[i] ?? "";
                        const name = (variant && root.variantNames[`${code}(${variant})`]) || root.layoutNames[code] || kb.active_keymap;
                        return {
                            code,
                            variant,
                            name
                        };
                    });
                    root.activeIndex = kb.active_layout_index;
                } catch (e) {
                    console.warn("Failed to parse hyprctl devices:", e);
                }
            }
        }
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            // the event only names the keymap, so ask for the index; configreloaded
            // picks up a changed kb_layout
            if (event.name === "activelayout" || event.name === "configreloaded")
                root.refresh();
        }
    }
}
