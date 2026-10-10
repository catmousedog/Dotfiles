// PowerProfileIndicator.qml
// Click: cycle the power profile (power saver / balanced / performance)

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.config
import qs.services
import qs.components.generic

Bartext {
    // laptops only, the desktop has no power-profiles-daemon
    visible: BatteryService.hasBattery

    text: {
        switch (BatteryService.profile) {
        case PowerProfile.PowerSaver:
            return "󰾆";
        case PowerProfile.Performance:
            return "󰓅";
        default:
            return "󰾅";
        }
    }
    color: BatteryService.profile === PowerProfile.Performance ? Theme.orange : BatteryService.profile === PowerProfile.PowerSaver ? Theme.green : ConfigService.getColor("common.font.color")

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: BatteryService.cycleProfile()
    }
}
