// BatteryIndicator.qml

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.config
import qs.services
import qs.components.generic

Loader {
    active: BatteryService.hasBattery
    // hidden, not just empty, so the row doesn't keep spacing for it on the desktop
    visible: active

    sourceComponent: IconText {
        icon: getIcon()
        text: getText()
        color: getColor()

        iconSize: ConfigService.get("right.battery.iconSize")
        iconYOffset: ConfigService.get("right.battery.iconYOffset")
        spacing: ConfigService.get("right.battery.spacing")

        readonly property var dischargingIcons: ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
        readonly property var chargingIcons: ["󰢟", "󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
        icons: [...dischargingIcons, ...chargingIcons, "󰂑"]

        function getIcon() {
            if (BatteryService.discharging)
                return dischargingIcons[Math.floor(BatteryService.percentage * 10)];
            if (BatteryService.charging)
                return chargingIcons[Math.floor(BatteryService.percentage * 10)];
            if (BatteryService.full)
                return "󰁹";
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
