// BatteryService.qml

pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import QtQuick

Singleton {

    readonly property var device: UPower.displayDevice
    readonly property bool hasBattery: device.isLaptopBattery
    readonly property real percentage: device.percentage
    readonly property var state: device.state

    readonly property bool charging: state === UPowerDeviceState.Charging
    readonly property bool full: state === UPowerDeviceState.FullyCharged
    readonly property bool discharging: state === UPowerDeviceState.Discharging

    // Time remaining in seconds — 0 if not applicable
    readonly property real timeToEmpty: device.timeToEmpty
    readonly property real timeToFull: device.timeToFull

    // Power profile, needs power-profiles-daemon (laptop only)
    readonly property var profile: PowerProfiles.profile

    function cycleProfile() {
        const order = [PowerProfile.PowerSaver, PowerProfile.Balanced];
        if (PowerProfiles.hasPerformanceProfile)
            order.push(PowerProfile.Performance);
        PowerProfiles.profile = order[(order.indexOf(profile) + 1) % order.length];
    }
}
