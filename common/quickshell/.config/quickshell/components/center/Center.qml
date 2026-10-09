// Center.qml

import Quickshell
import QtQuick
import qs.services
import qs.components.generic

Item {
    anchors.fill: parent

    Barbox {
        id: clock
        implicitHeight: parent.height
        implicitWidth: parent.width * ConfigService.get("center.widthFactor")
        anchors.centerIn: parent

        Bartext {
            anchors.centerIn: parent
            text: TimeService.format(ConfigService.get("center.clock.format"))
        }
    }

    // left of the clock, so the clock stays in the middle
    MediaPlayer {
        implicitHeight: parent.height
        anchors.right: clock.left
        anchors.rightMargin: HyprlandService.gapsOut
    }
}
