// NetworkService.qml
// Active connection (wired preferred over wifi) and its current up/down speed.

pragma Singleton

import Quickshell
import Quickshell.Io
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

    // bytes per second, from the interface counters in sysfs
    property real down: 0
    property real up: 0
    property real lastRx: -1
    property real lastTx: -1
    property real lastTime: 0

    onDeviceChanged: {
        lastRx = -1;
        down = up = 0;
    }

    Timer {
        interval: 2000
        running: root.device !== null
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            countersProc.command = ["cat", `/sys/class/net/${root.device.name}/statistics/rx_bytes`, `/sys/class/net/${root.device.name}/statistics/tx_bytes`];
            countersProc.running = true;
        }
    }

    Process {
        id: countersProc
        stdout: StdioCollector {
            onStreamFinished: {
                const [rx, tx] = text.trim().split("\n").map(Number);
                const now = Date.now();
                if (root.lastRx >= 0 && now > root.lastTime) {
                    const seconds = (now - root.lastTime) / 1000;
                    root.down = Math.max(0, (rx - root.lastRx) / seconds);
                    root.up = Math.max(0, (tx - root.lastTx) / seconds);
                }
                root.lastRx = rx;
                root.lastTx = tx;
                root.lastTime = now;
            }
        }
    }

    function formatSpeed(bytes) {
        const units = ["B/s", "KB/s", "MB/s", "GB/s"];
        let i = 0;
        while (bytes >= 1000 && i < units.length - 1) {
            bytes /= 1000;
            i++;
        }
        return `${bytes.toFixed(bytes < 10 && i > 0 ? 1 : 0)} ${units[i]}`;
    }
}
