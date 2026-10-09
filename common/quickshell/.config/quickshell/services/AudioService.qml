// AudioService.qml

pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Services.Pipewire

Singleton {
    id: root

    // Bind the pipewire node so its volume will be tracked
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.nodes]
    }

    readonly property var defaultSink: Pipewire.defaultAudioSink
    readonly property var defaultAudio: defaultSink?.audio ?? null
    readonly property real volume: defaultAudio?.volume ?? 0
    readonly property bool muted: defaultAudio?.muted ?? false

    // Hardware outputs (speakers, headsets, HDMI, bluetooth), not app streams, minus the
    // ones matching "right.audio.hidden" (parts of the device name or description)
    readonly property var hidden: (ConfigService.get("right.audio.hidden") ?? []).map(h => h.toLowerCase())
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.audio && n.isSink && !n.isStream && !hidden.some(h => `${n.name} ${n.description}`.toLowerCase().includes(h)))

    function setVolume(volume) {
        if (defaultAudio)
            defaultAudio.volume = volume;
    }

    function toggleMute() {
        if (defaultAudio)
            defaultAudio.muted = !defaultAudio.muted;
    }

    function setDefaultSink(node) {
        Pipewire.preferredDefaultAudioSink = node;
    }

    // "right.audio.names" maps part of a device's name to a nicer one
    function sinkName(node) {
        const label = node.nickname || node.description || node.name;
        const names = ConfigService.get("right.audio.names") ?? {};
        for (const key of Object.keys(names)) {
            if (label.includes(key) || node.name.includes(key))
                return names[key];
        }
        return label;
    }

    function sinkIcon(node) {
        const props = node.properties ?? {};
        const text = `${node.name} ${node.description} ${props["device.form-factor"] ?? ""}`.toLowerCase();
        if (/headset|headphone|earbud/.test(text))
            return "󰋋";
        if (node.name.startsWith("bluez"))
            return "󰂰";
        if (/hdmi|displayport/.test(text))
            return "󰍹";
        return "󰓃";
    }

    /* ------------------------------------ Card profiles ----------------------------------- */
    // Some cards (laptop HDMI) only expose a sink after switching the card profile,
    // what `pactl set-card-profile` does. Enabled with "right.audio.profiles".

    readonly property bool profilesEnabled: ConfigService.get("right.audio.profiles") ?? false

    // [{ card, profile, description, active }]
    property var profiles: []

    function refreshProfiles() {
        if (profilesEnabled)
            cardsProc.running = true;
    }

    function setProfile(entry) {
        Quickshell.execDetached(["pactl", "set-card-profile", entry.card, entry.profile]);
        refreshTimer.restart();
    }

    Timer {
        id: refreshTimer
        interval: 500
        onTriggered: root.refreshProfiles()
    }

    Process {
        id: cardsProc
        command: ["pactl", "--format=json", "list", "cards"]
        stdout: StdioCollector {
            onStreamFinished: {
                const pattern = new RegExp(ConfigService.get("right.audio.profilePattern"), "i");
                const result = [];
                try {
                    for (const card of JSON.parse(text)) {
                        for (const [name, profile] of Object.entries(card.profiles ?? {})) {
                            if (!pattern.test(name) || profile.available === false || !profile.sinks)
                                continue;
                            result.push({
                                card: card.name,
                                profile: name,
                                description: profile.description,
                                active: name === card.active_profile
                            });
                        }
                    }
                } catch (e) {
                    console.warn("[AudioService] Failed to parse pactl cards:", e);
                }
                root.profiles = result;
            }
        }
    }
}
