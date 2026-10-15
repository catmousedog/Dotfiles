// shell.qml

import QtQuick
import Quickshell
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

    // Zoomed out watrix grid, also only exists while open
    LazyLoader {
        active: OverviewService.active

        OverviewOverlay {
        }

    }

}
