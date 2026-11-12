// BatteryService.qml

pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import QtQuick

Singleton {
    id: root

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
    // whichever applies right now: until empty, or until full
    readonly property real timeLeft: discharging ? timeToEmpty : charging ? timeToFull : 0

    // watts in or out of the battery
    readonly property real rate: Math.abs(device.changeRate)

    // the physical battery (the display device is a composite without health)
    readonly property var battery: UPower.devices.values.find(d => d.isLaptopBattery) ?? null
    readonly property real health: battery?.healthSupported ? battery.healthPercentage : -1

    readonly property string stateName: {
        if (charging)
            return "Charging";
        if (discharging)
            return "On battery";
        if (full)
            return "Full";
        return "Plugged in";
    }

    // 9840 -> "2h 44m", compact: "2:44"
    function formatTime(seconds, compact) {
        const minutes = Math.round(seconds / 60);
        const h = Math.floor(minutes / 60);
        const m = minutes % 60;
        if (compact)
            return `${h}:${m.toString().padStart(2, "0")}`;
        return h > 0 ? `${h}h ${m}m` : `${m}m`;
    }

    /* ------------------------------------ Power profile ----------------------------------- */
    // needs power-profiles-daemon (laptop only)

    readonly property var profile: PowerProfiles.profile

    // what the battery popup offers, in order; colors are Theme role names
    readonly property var profiles: [
        {
            value: PowerProfile.PowerSaver,
            name: "Power saver",
            icon: "󰾆",
            color: "green"
        },
        {
            value: PowerProfile.Balanced,
            name: "Balanced",
            icon: "󰾅",
            color: "accent"
        },
        ...(PowerProfiles.hasPerformanceProfile ? [
                {
                    value: PowerProfile.Performance,
                    name: "Performance",
                    icon: "󰓅",
                    color: "red"
                }
            ] : [])
    ]

    readonly property var currentProfile: profiles.find(p => p.value === profile) ?? profiles[1]

    function setProfile(value) {
        PowerProfiles.profile = value;
    }
}
