// Scoreboard.qml
// Quiz scoreboard, loaded by shell.qml when this file exists. Only the laptop
// stows it (hosts/laptop/scoreboard), see README.md next to it.

pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

Scope {
    ScoreboardService {
        id: scoreboard
    }

    LazyLoader {
        active: scoreboard.shown

        Variants {
            model: scoreboard.screens

            delegate: ScoreboardOverlay {
                service: scoreboard
            }
        }
    }
}
