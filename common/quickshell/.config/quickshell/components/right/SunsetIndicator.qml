// SunsetIndicator.qml
// Click: night light on / off (hyprsunset)

import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.components.generic

IconText {
    icon: SunsetService.enabled ? "󰖔" : "󰖙"
    iconYOffset: -1
    color: SunsetService.enabled ? Theme.yellow : null

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: SunsetService.toggle()
    }
}
