// BluetoothService.qml

pragma Singleton

import Quickshell
import Quickshell.Bluetooth
import QtQuick

Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property var devices: adapter ? adapter.devices.values : []
    readonly property var connected: devices.filter(d => d.connected)

    // Devices paired before (with bluetoothctl), connected ones first
    readonly property var paired: devices.filter(d => d.paired || d.bonded).sort((a, b) => (b.connected - a.connected) || a.name.localeCompare(b.name))

    function setEnabled(on) {
        if (adapter)
            adapter.enabled = on;
    }

    function toggleDevice(device) {
        if (device.connected)
            device.disconnect();
        else
            device.connect();
    }

    function busy(device) {
        return device.state === BluetoothDeviceState.Connecting || device.state === BluetoothDeviceState.Disconnecting;
    }

    function icon(device) {
        const icons = {
            "audio-headset": "󰋋",
            "audio-headphones": "󰋋",
            "audio-card": "󰓃",
            "input-mouse": "󰍽",
            "input-keyboard": "󰌌",
            "input-gaming": "󰊴",
            "phone": "󰏲",
            "computer": "󰟀"
        };
        return icons[device.icon] ?? "󰂯";
    }
}
