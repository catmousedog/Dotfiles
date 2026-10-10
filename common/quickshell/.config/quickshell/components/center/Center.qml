// Center.qml

import Quickshell
import QtQuick
import qs.services
import qs.components.generic

Barbox {
    implicitHeight: parent.height
    // at least widthFactor of the screen, wider when the clock needs it
    implicitWidth: Math.max(parent.width * ConfigService.get("center.widthFactor"), clock.implicitWidth + implicitHeight)
    anchors.centerIn: parent

    Bartext {
        id: clock
        anchors.centerIn: parent
        text: TimeService.format(ConfigService.get("center.clock.format"))
    }
}
