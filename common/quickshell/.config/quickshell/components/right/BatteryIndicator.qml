// BatteryIndicator.qml
// Click: cycle the power profile (power saver / balanced / performance)

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.config
import qs.services
import qs.components.generic

Loader {
    active: BatteryService.hasBattery
    // hidden, not just empty, so the row doesn't keep spacing for it on the desktop
    visible: active

    sourceComponent: Item {
        implicitWidth: row.implicitWidth
        implicitHeight: row.implicitHeight

        RowLayout {
            id: row
            anchors.fill: parent
            spacing: ConfigService.get("right.battery.spacing") * 2

            Bartext {
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
                color: BatteryService.profile === PowerProfile.Performance ? Theme.peach : BatteryService.profile === PowerProfile.PowerSaver ? Theme.green : ConfigService.getColor("common.font.color")
            }

            IconText {
                icon: getIcon()
                text: getText()
                color: getColor()

                iconSize: ConfigService.get("right.battery.iconSize")
                iconYOffset: ConfigService.get("right.battery.iconYOffset")
                spacing: ConfigService.get("right.battery.spacing")

                function getIcon() {
                    if (BatteryService.discharging) {
                        const icons = ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"];
                        return icons[Math.floor(BatteryService.percentage * 10)];
                    }
                    if (BatteryService.charging) {
                        const icons = ["󰢟", "󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"];
                        return icons[Math.floor(BatteryService.percentage * 10)];
                    }
                    if (BatteryService.full) {
                        return "󰁹";
                    }
                    return "󰂑";
                }

                function getText() {
                    return Math.round(BatteryService.percentage * 100) + "%";
                }

                function getColor() {
                    if (BatteryService.percentage <= .1) {
                        return Theme.red;
                    }
                    return null; // default color
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: BatteryService.cycleProfile()
        }
    }
}
