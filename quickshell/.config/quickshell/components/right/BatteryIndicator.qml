// BatteryIndicator.qml

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services
import qs.components.generic

Loader {
    active: BatteryService.hasBattery

    sourceComponent: IconText {
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
