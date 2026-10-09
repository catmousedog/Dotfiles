// AudioService.qml

pragma Singleton
import Quickshell
import QtQuick
import Quickshell.Services.Pipewire

Singleton {
    // Bind the pipewire node so its volume will be tracked
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.nodes]
    }

    readonly property var defaultSink: Pipewire.defaultAudioSink
    readonly property var defaultAudio: defaultSink?.audio ?? null
    readonly property real volume: defaultAudio?.volume ?? 0
    readonly property bool muted: defaultAudio?.muted ?? false

    function setVolume(volume) {
        if (defaultAudio)
            defaultAudio.volume = volume;
    }
}
