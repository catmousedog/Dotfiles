// ScoreboardService.qml
// Quiz scores for ScoreboardOverlay. The scores file is the only source of
// truth: every change is a line appended to it and the scores are what
// replaying it gives, so hand edits and scripts show up the same way.
//
// One JSON object per line ("ts" is optional when reading):
//   {"ts": "...", "team": "a", "delta": 2, "note": "..."}   a score change
//   {"ts": "...", "type": "undo", "team": "a", "delta": -2} takes back the last change
//   {"ts": "...", "type": "reset"}                          everyone back to 0

pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import qs.config

Scope {
    id: root

    readonly property var defaults: ({
            monitors: [],
            screenScale: {},
            vertical: "top",
            horizontal: "center",
            margins: {
                x: 32,
                y: 32
            },
            labels: "name",
            scoreSize: 96,
            opacity: 0.9,
            spacing: 20
        })
    // teams without a color of their own, as theme roles
    readonly property var fallbackColors: ["red", "blue", "green", "yellow"]

    property var config: defaults
    // [{ id, name, short, color, index }], index counting from 1
    property var teams: []
    // team id -> score
    property var scores: ({})
    // changes since the last reset that undo can still take back, newest last
    property var undoStack: []
    // false until the scores file has been read once
    property bool loaded: false
    property bool shown: false

    readonly property string scorePath: (Quickshell.env("XDG_DATA_HOME") || Quickshell.env("HOME") + "/.local/share") + "/quiz-scoreboard/scores.jsonl"

    // Every connected screen from config.monitors, else the focused one
    readonly property var screens: {
        const listed = Quickshell.screens.filter(s => root.config.monitors.includes(s.name));
        if (listed.length > 0)
            return listed;
        const name = Hyprland.focusedMonitor?.name;
        return [Quickshell.screens.find(s => s.name === name) ?? Quickshell.screens[0]];
    }

    // a theme role ("red") or anything a color accepts ("#4aa3ff")
    function teamColor(team: var): color {
        return Theme.getColor(team.color) || team.color;
    }

    function label(team: var): string {
        return config.labels === "short" ? team.short : team.name;
    }

    function loadConfig(text: string): void {
        try {
            config = Object.assign({}, defaults, JSON.parse(text));
        } catch (e) {
            console.warn("[Scoreboard] Failed to parse config.json:", e);
        }
    }

    function loadTeams(text: string): void {
        let list;
        try {
            list = JSON.parse(text).teams ?? [];
        } catch (e) {
            console.warn("[Scoreboard] Failed to parse teams.json:", e);
            return;
        }
        if (list.length > 4) {
            console.warn("[Scoreboard] More than 4 teams, only showing the first 4");
            list = list.slice(0, 4);
        }
        if (list.length < 2)
            console.warn("[Scoreboard] Expected 2 to 4 teams, got", list.length);
        teams = list.map((t, i) => {
            const name = t.name ?? "Team " + (i + 1);
            return {
                id: String(t.id ?? i + 1),
                name: name,
                short: t.short ?? name.slice(0, 2).toUpperCase(),
                color: t.color ?? fallbackColors[i],
                index: i + 1
            };
        });
        // a team that just appeared may already have lines in the file
        if (scoreFile.loaded)
            replay(scoreFile.text());
    }

    function replay(text: string): void {
        // the scores can be read before the teams, loadTeams replays again
        if (teams.length === 0)
            return;
        const next = {};
        for (const t of teams)
            next[t.id] = 0;
        let stack = [];

        text.split("\n").forEach((line, i) => {
            if (line.trim() === "")
                return;
            let event;
            try {
                event = JSON.parse(line);
            } catch (e) {
                console.warn(`[Scoreboard] scores.jsonl line ${i + 1}: not valid JSON, skipped`);
                return;
            }
            if (event.type === "reset") {
                for (const id in next)
                    next[id] = 0;
                stack = [];
                return;
            }
            const delta = Number(event.delta);
            if (!(event.team in next) || !Number.isInteger(delta)) {
                console.warn(`[Scoreboard] scores.jsonl line ${i + 1}: unknown team or bad delta, skipped`);
                return;
            }
            next[event.team] += delta;
            if (event.type === "undo")
                stack.pop();
            else
                stack.push({
                    team: event.team,
                    delta: delta
                });
        });

        scores = next;
        undoStack = stack;
        loaded = true;
    }

    // Appends one event. The overlay only changes once the file watcher sees it.
    function append(event: var): void {
        const line = JSON.stringify(Object.assign({
            ts: new Date().toISOString()
        }, event));
        Quickshell.execDetached(["sh", "-c", 'mkdir -p "${2%/*}" && printf "%s\\n" "$1" >> "$2"', "sh", line, scorePath]);
    }

    // A team by id, number (1-4) or short label
    function resolveTeam(name: string): var {
        const key = String(name).trim().toLowerCase();
        const team = teams.find(t => t.id.toLowerCase() === key) ?? (/^\d+$/.test(key) ? teams[parseInt(key) - 1] : undefined) ?? teams.find(t => t.short.toLowerCase() === key);
        if (!team)
            console.warn("[Scoreboard] No team", name);
        return team ?? null;
    }

    function add(name: string, n: int): void {
        const team = resolveTeam(name);
        if (team && n !== 0)
            append({
                team: team.id,
                delta: n
            });
    }

    function set(name: string, value: int): void {
        const team = resolveTeam(name);
        const delta = team ? value - (scores[team.id] ?? 0) : 0;
        if (delta !== 0)
            append({
                team: team.id,
                delta: delta,
                note: "set " + value
            });
    }

    function undo(): void {
        const last = undoStack[undoStack.length - 1];
        if (!last) {
            console.warn("[Scoreboard] Nothing to undo");
            return;
        }
        // right away, so a second undo before the file is read back goes further
        undoStack = undoStack.slice(0, -1);
        append({
            type: "undo",
            team: last.team,
            delta: -last.delta
        });
    }

    function reset(): void {
        append({
            type: "reset"
        });
    }

    function status(): string {
        return teams.map(t => `${t.short} ${scores[t.id] ?? 0}`).join(" | ");
    }

    FileView {
        path: Quickshell.shellPath("scoreboard/config.json")
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.loadConfig(text())
    }

    FileView {
        path: Quickshell.shellPath("scoreboard/teams.json")
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.loadTeams(text())
    }

    FileView {
        id: scoreFile
        path: root.scorePath
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.replay(text())
        onLoadFailed: createFile.running = true
    }

    Process {
        id: createFile
        command: ["sh", "-c", 'mkdir -p "${1%/*}" && touch "$1"', "sh", root.scorePath]
        onExited: scoreFile.reload()
    }

    // Bound in the laptop's host.lua: SUPER+ALT+1-4 and SUPER+ALT+SHIFT+1-4
    Instantiator {
        model: 8

        delegate: GlobalShortcut {
            required property int index
            readonly property int team: index % 4 + 1
            readonly property int step: index < 4 ? 1 : -1

            appid: "quickshell"
            name: (step > 0 ? "scoreUp" : "scoreDown") + team
            description: (step > 0 ? "+1 for team " : "-1 for team ") + team
            onPressed: root.add(String(team), step)
        }
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "scoreUndo"
        description: "Take back the last score change"
        onPressed: root.undo()
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "scoreToggle"
        description: "Show or hide the scoreboard"
        onPressed: root.shown = !root.shown
    }

    // qs ipc call score add a 2, see ~/.local/bin/score
    IpcHandler {
        target: "score"

        function add(team: string, n: int): void {
            root.add(team, n);
        }

        function set(team: string, value: int): void {
            root.set(team, value);
        }

        function undo(): void {
            root.undo();
        }

        function reset(): void {
            root.reset();
        }

        function toggle(): void {
            root.shown = !root.shown;
        }

        function show(): void {
            root.shown = true;
        }

        function hide(): void {
            root.shown = false;
        }

        function status(): string {
            return root.status();
        }
    }
}
