// Barbox.qml

import Quickshell
import QtQuick
import qs.config
import qs.services

Rectangle {
    id: root

    // same as Hyprland's window borders; the config value is used until hyprctl answers
    property int borderWidth: HyprlandService.borderSize || ConfigService.get("common.theme.borderWidth")

    /* ---------------------------------- Position and Size --------------------------------- */
    radius: implicitHeight / 2

    /* ---------------------------------------- Theme --------------------------------------- */
    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop {
            position: 0.0
            color: Theme.accent2
        }
        GradientStop {
            position: 1.0
            color: Theme.accent
        }
    }

    Rectangle {
        anchors.centerIn: parent

        implicitHeight: parent.height - 2 * root.borderWidth
        implicitWidth: parent.width - 2 * root.borderWidth
        radius: Math.max(0, root.radius - root.borderWidth)

        color: Theme.bg
        enabled: false
    }
}
