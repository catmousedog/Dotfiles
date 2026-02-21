// AudioIndicator.qml

import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.components.generic

IconText {

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
            AudioService.volume = volume;
        }
    }

    function getIcon() {
        var deviceIcon = AudioService.icon;
        if (deviceIcon == "audio-card-analog") {
            return "";
        } else if (deviceIcon == "audio-headset") {
            return "󱡏";
        } else if (deviceIcon == "audio-card") {
            return "";
        }
        return "";
    }

    function getText() {
        var volume = Math.round(AudioService.volume * 100);
        var volumeText = volume.toString().padStart(2, " ");
        return volumeText + "%";
    }
}
