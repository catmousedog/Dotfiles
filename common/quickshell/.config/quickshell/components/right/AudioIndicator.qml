// AudioIndicator.qml
// Scroll: volume, left click: choose output, right click: mute

import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.components.generic

IconText {
    id: root

    icon: getIcon()
    text: getText()

    iconSize: ConfigService.get("right.audio.iconSize")
    iconYOffset: ConfigService.get("right.audio.iconYOffset")
    spacing: ConfigService.get("right.audio.spacing")

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            const delta = event.angleDelta.y > 0 ? 1 : -1;
            var volume = AudioService.volume;
            volume = Math.min(1, Math.max(0, volume + delta * ConfigService.get("right.audio.scrollInterval") / 100));
            AudioService.setVolume(volume);
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                AudioService.toggleMute();
            else
                popup.toggle();
        }
    }

    Popup {
        id: popup
        anchorItem: root
        title: "Output"
        onVisibleChanged: if (visible)
            AudioService.refreshProfiles()

        Repeater {
            model: AudioService.sinks

            delegate: MenuRow {
                required property var modelData
                icon: AudioService.sinkIcon(modelData)
                text: AudioService.sinkName(modelData)
                active: modelData === AudioService.defaultSink
                onClicked: AudioService.setDefaultSink(modelData)
            }
        }

        Separator {
            visible: AudioService.profiles.length > 0
        }

        Repeater {
            model: AudioService.profiles

            delegate: MenuRow {
                required property var modelData
                icon: modelData.profile.includes("hdmi") ? "󰍹" : "󰓃"
                text: modelData.description
                detail: "profile"
                active: modelData.active
                onClicked: AudioService.setProfile(modelData)
            }
        }
    }

    function getIcon() {
        if (AudioService.muted || AudioService.volume === 0) {
            return "";
        }
        return "";
    }

    function getText() {
        var volume = Math.round(AudioService.volume * 100);
        var volumeText = volume.toString().padStart(2, " ");
        return volumeText + "%";
    }
}
