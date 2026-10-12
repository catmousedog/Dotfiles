// NetworkService.qml
// Active connection (wired preferred over wifi) and its signal strength.

pragma Singleton

import Quickshell
import Quickshell.Networking
import QtQuick

Singleton {
    id: root

    readonly property var devices: Networking.devices.values
    readonly property var wired: devices.find(d => d.type === DeviceType.Wired && d.connected) ?? null
    readonly property var wifi: devices.find(d => d.type === DeviceType.Wifi && d.connected) ?? null
    readonly property var wifiNetwork: wifi ? wifi.networks.values.find(n => n.connected) ?? null : null
    readonly property var device: wired ?? wifi
    readonly property bool connected: device !== null
    readonly property real signal: wifiNetwork?.signalStrength ?? 0  // 0..1
}
