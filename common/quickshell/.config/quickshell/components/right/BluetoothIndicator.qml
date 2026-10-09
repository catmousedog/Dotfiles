import QtQuick
import QtQuick.Controls
import Quickshell
import qs.config
import qs.services
import qs.components.generic

IconText {
    icon: getIcon()
    text: getText()
    color: getColor()

    iconSize: ConfigService.get("right.bluetooth.iconSize")
    iconYOffset: ConfigService.get("right.bluetooth.iconYOffset")
    spacing: ConfigService.get("right.bluetooth.spacing")

    function getIcon() {
        if (BluetoothService.enabled) {
            return "󰂯";
        } else {
            return "󰂲";
        }
    }

    function getText() {
        if (BluetoothService.enabled) {
            if (BluetoothService.connected.length > 0) {
                return BluetoothService.connected.length.toString();
            }
        }
        return "";
    }

    function getColor() {
        if (BluetoothService.connected.length > 0) {
            return Theme.blue;
        }
        return null;
    }
}
