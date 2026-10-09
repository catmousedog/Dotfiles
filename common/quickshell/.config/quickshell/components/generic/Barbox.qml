// Barbox.qml

import Quickshell
import QtQuick
import qs.config
import qs.services

Rectangle {
    id: root

    property int borderWidth: ConfigService.get("common.theme.borderWidth")

    /* ---------------------------------- Position and Size --------------------------------- */
    radius: implicitHeight / 2

    /* ---------------------------------------- Theme --------------------------------------- */
    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop {
            position: 0.0
            color: Theme.red
        }
        GradientStop {
            position: 1.0
            color: Theme.blue
        }
    }

    Rectangle {
        anchors.centerIn: parent

        implicitHeight: parent.height - 2 * root.borderWidth
        implicitWidth: parent.width - 2 * root.borderWidth
        radius: implicitHeight / 2

        color: Theme.base
        enabled: false
    }
}
