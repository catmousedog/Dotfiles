// MediaPlayer.qml
// Controls for the current MPRIS player (Spotify, Firefox, ...), hidden when there is none.

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services
import qs.components.generic

Barbox {
    id: root

    readonly property var player: MediaService.player

    visible: player !== null
    implicitWidth: row.implicitWidth + implicitHeight

    component Button: Bartext {
        id: button
        signal clicked
        property bool enabledButton: true
        color: !enabledButton ? Theme.overlay0 : mouse.containsMouse ? Theme.blue : Theme.text

        MouseArea {
            id: mouse
            anchors.fill: parent
            anchors.margins: -4
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: if (button.enabledButton)
                button.clicked()
        }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 12

        Button {
            text: "󰒮"
            enabledButton: root.player?.canGoPrevious ?? false
            onClicked: root.player.previous()
        }

        Button {
            text: root.player?.isPlaying ? "󰏤" : "󰐊"
            enabledButton: root.player?.canTogglePlaying ?? false
            onClicked: root.player.togglePlaying()
        }

        Button {
            text: "󰒭"
            enabledButton: root.player?.canGoNext ?? false
            onClicked: root.player.next()
        }

        Bartext {
            text: MediaService.artist ? `${MediaService.title} · ${MediaService.artist}` : MediaService.title
            color: root.player?.isPlaying ? Theme.text : Theme.subtext0
            elide: Text.ElideRight
            Layout.maximumWidth: 380
        }
    }
}
