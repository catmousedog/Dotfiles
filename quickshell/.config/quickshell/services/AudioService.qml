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
    readonly property var icon: defaultSink.properties["device.icon-name"]
    readonly property real volume: defaultAudio.volume

    function setVolume(volume) {
        defaultAudio.volume = volume;
    }
}
