// BluetoothService.qml

pragma Singleton

import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import QtQuick
import QtCore

Singleton {
    id: root

    readonly property var adapter: Bluetooth?.defaultAdapter ?? null
    readonly property var devices: adapter ? adapter.devices.values : []
    readonly property var connected: devices.filter(d => d.connected)
    readonly property var enabled: adapter ? adapter.enabled : false

    property var knownDevices: []

    Component.onCompleted: root.loadKnown()

    FileView {
        id: devicesFile
        path: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/quickshell/local/bluetooth_devices.json"
        watchChanges: false
        blockLoading: true
    }

    function loadKnown() {
        try {
            root.knownDevices = JSON.parse(devicesFile.text());
        } catch (e) {
            console.error("[BluetoothService] Failed to parse bluetooth_devices.json:", e);
        }
    }

    function device(mac) {
        return devices.find(d => d.address === mac) ?? null;
    }

    function connectKnown(name) {
        var mac = root.knownDevices.find(d => d.name === name)?.mac ?? null;
        if (!mac) {
            console.warn("[BluetoothService] Unknown device:", name);
            return;
        }
        root.connectDevice(mac);
    }

    function connectDevice(mac) {
        const dev = device(mac);
        if (!dev) {
            console.warn("[BluetoothService] Device not found:", mac);
            return;
        }
        if (dev.connected) {
            console.info("[BluetoothService] Device already connected:", mac);
            return;
        }
        dev.connect();
    }

    function disconnectDevice(mac) {
        const dev = device(mac);
        if (!dev) {
            console.warn("[BluetoothService] Device not found:", mac);
            return;
        }
        if (!dev.connected) {
            console.info("[BluetoothService] Device already disconnected:", mac);
            return;
        }
        dev.disconnect();
    }
}
