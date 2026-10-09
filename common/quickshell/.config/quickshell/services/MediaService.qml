// MediaService.qml
// The media player to show: the one playing, else the last one shown, else any.

pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQml
import QtQuick

Singleton {
    id: root

    readonly property var players: Mpris.players.values
    property var player: null

    readonly property string title: player?.trackTitle || player?.identity || ""
    readonly property string artist: player?.trackArtist ?? ""

    onPlayersChanged: pick()

    function pick() {
        const playing = players.find(p => p.isPlaying);
        if (playing)
            player = playing;
        else if (!player || !players.includes(player))
            player = players[0] ?? null;
    }

    // re-pick whenever any player starts or stops
    Instantiator {
        model: Mpris.players
        delegate: Connections {
            required property var modelData
            target: modelData
            function onIsPlayingChanged() {
                root.pick();
            }
        }
    }
}
