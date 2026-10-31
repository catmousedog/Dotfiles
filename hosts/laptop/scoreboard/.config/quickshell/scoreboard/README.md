# Quiz scoreboard (temporary, laptop only)

A live scoreboard for a quiz, shown above fullscreen slides (pdfpc) on the
projector. Clicks go straight through it, and it never takes the keyboard.

This whole stow package (`hosts/laptop/scoreboard`) plus a few lines in
`common/quickshell/.config/quickshell/shell.qml` and the laptop's `host.lua` were
added in one commit. To remove it: `git revert <that commit> && make`. The scores
stay in `~/.local/share/quiz-scoreboard/` until you delete them.

## Configure

`teams.json`, 2 to 4 teams, edits apply right away:

```json
{ "teams": [
  { "id": "a", "name": "The Quizzards", "short": "QZ", "color": "red" },
  { "id": "b", "name": "Team Two",      "short": "T2", "color": "#4aa3ff" }
] }
```

`color` is a theme role (`red`, `pink`, `accent`, ...: it follows the theme) or
any hex color.

`config.json`:

| key           | meaning                                                         |
| ------------- | --------------------------------------------------------------- |
| `monitors`    | outputs to show on (`hyprctl monitors`); if none of them is connected, the focused one |
| `screenScale` | size per output, e.g. `{"eDP-1": 0.6}` for a small copy on the laptop |
| `vertical`    | `top` / `bottom`                                                |
| `horizontal`  | `left` / `center` / `right`                                     |
| `margins`     | `{"x": 32, "y": 32}` from the anchored edges                    |
| `labels`      | `name` or `short`                                               |
| `scoreSize`   | pixel size of the score digits                                  |
| `opacity`     | of the card background                                          |

`host.lua` currently **mirrors** HDMI-A-1 to eDP-1. While it does, the projector
isn't a separate screen: only the eDP-1 copy exists, and the projector shows it
through the mirror (at its `screenScale`). For a big copy on the projector and a
small one on the laptop, make HDMI-A-1 an extended output (drop `mirror`).

## Control

| keys                     | command               | does                       |
| ------------------------ | --------------------- | -------------------------- |
| SUPER+ALT+1..4           | `score 2`             | +1 for team 1-4            |
| SUPER+ALT+SHIFT+1..4     | `score 2 -1`          | -1 for team 1-4            |
|                          | `score a 3`           | add 3 (negative works too) |
|                          | `score set a 10`      | set a score                |
| SUPER+ALT+Z              | `score undo`          | take back the last change (repeatable) |
|                          | `score reset`         | everyone back to 0         |
| SUPER+ALT+S              | `score toggle`        | show / hide (`show`, `hide`) |
|                          | `score status`        | prints `QZ 7 \| T2 8`      |

Teams can be given by id, number (1-4) or short label. The digit keys are bound
by keycode, so they work on the Belgian layout without shift. `score` is a
wrapper around `qs ipc call -- score <function> ...`. The `--` is needed:
without it qs takes `show` as its own command.

KDE Connect: add commands like `~/.local/bin/score a 1` under Run commands, and
they show up as buttons on the phone.

## Scores file

`~/.local/share/quiz-scoreboard/scores.jsonl` is the only source of truth.
Every change is appended as one line and nothing is ever rewritten. The scores
are what replaying it from the last reset gives, so they survive reloads and
restarts, and editing the file by hand updates the overlay right away.

```
{"ts":"2026-10-31T19:02:11.000Z","team":"a","delta":2}
{"ts":"2026-10-31T19:03:40.000Z","team":"b","delta":-1,"note":"optional"}
{"ts":"2026-10-31T19:04:02.000Z","type":"undo","team":"b","delta":1}
{"ts":"2026-10-31T19:30:00.000Z","type":"reset"}
```

`ts` is optional in hand-written lines. Lines that aren't valid JSON, or name a
team that isn't in `teams.json`, are skipped with a warning in `qs log`. A
missing file is created.
