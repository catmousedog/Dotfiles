// BluetoothIndicator.qml
// Left click: paired devices, right click: power on/off

import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.components.generic

IconText {
    id: root

    icon: getIcon()
    text: getText()
    color: getColor()

    iconSize: ConfigService.get("right.bluetooth.iconSize")
    iconYOffset: ConfigService.get("right.bluetooth.iconYOffset")
    spacing: ConfigService.get("right.bluetooth.spacing")

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                BluetoothService.setEnabled(!BluetoothService.enabled);
            else
                popup.toggle();
        }
    }

    Popup {
        id: popup
        anchorItem: root
        title: "Bluetooth"

        MenuRow {
            icon: BluetoothService.enabled ? "󰂯" : "󰂲"
            text: BluetoothService.enabled ? "On" : "Off"
            active: BluetoothService.enabled
            onClicked: BluetoothService.setEnabled(!BluetoothService.enabled)
        }

        Separator {
            visible: BluetoothService.enabled
        }

        Repeater {
            model: BluetoothService.enabled ? BluetoothService.paired : []

            delegate: MenuRow {
                required property var modelData
                icon: BluetoothService.icon(modelData)
                text: modelData.name
                active: modelData.connected
                dimmed: !modelData.connected
                detail: BluetoothService.busy(modelData) ? "…" : modelData.connected && modelData.batteryAvailable ? Math.round(modelData.battery * 100) + "%" : ""
                onClicked: BluetoothService.toggleDevice(modelData)
            }
        }

        MenuRow {
            visible: BluetoothService.enabled && BluetoothService.paired.length === 0
            text: "No paired devices"
            dimmed: true
        }
    }

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
            return Theme.accent;
        }
        return null;
    }
}
