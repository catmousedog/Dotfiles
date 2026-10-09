// Center.qml

import Quickshell
import QtQuick
import qs.services
import qs.components.generic

Barbox {
    implicitHeight: parent.height
    implicitWidth: parent.width * ConfigService.get("center.widthFactor")
    anchors.centerIn: parent

    Bartext {
        anchors.centerIn: parent
        text: TimeService.format(ConfigService.get("center.clock.format"))
    }
}
