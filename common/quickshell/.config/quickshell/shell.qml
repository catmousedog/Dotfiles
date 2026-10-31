// shell.qml

import QtQuick
import Quickshell
import Quickshell.Io
import qs.components
import qs.services

ShellRoot {
    Variants {
        model: Quickshell.screens

        delegate: StatusBar {
        }

    }

    // Only exists while a screenshot is being taken, so it starts clean every time
    LazyLoader {
        active: ScreenshotService.active

        ScreenshotOverlay {
        }

    }

    // Zoomed out watrix grid on every monitor, also only exists while open
    LazyLoader {
        active: OverviewService.active

        Variants {
            model: Quickshell.screens

            delegate: OverviewOverlay {
            }

        }

    }

    // Quiz scoreboard (temporary): only the laptop stows scoreboard/, see
    // hosts/laptop/scoreboard. Loaded only once the file turns out to exist, so
    // other machines don't log a missing file. By its real path: quickshell's own
    // qs:@ files only cover what it found on load, the siblings would be missing.
    FileView {
        path: Quickshell.shellPath("scoreboard/Scoreboard.qml")
        printErrors: false
        // source before active, both bound at once it never loads
        onLoaded: {
            scoreboardLoader.source = "file://" + path;
            scoreboardLoader.active = true;
        }
    }

    LazyLoader {
        id: scoreboardLoader
    }

}
