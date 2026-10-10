// NetworkIndicator.qml
// Hover: connection details and current speed

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services
import qs.components.generic

IconText {
    id: root

    icon: {
        if (NetworkService.wired)
            return "󰈀";
        if (NetworkService.wifi) {
            const icons = ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"];
            return icons[Math.min(4, Math.floor(NetworkService.signal * 5))];
        }
        return "󰤮";
    }
    color: NetworkService.connected ? ConfigService.getColor("common.font.color") : Theme.red

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onContainsMouseChanged: containsMouse ? tooltip.open() : tooltip.close()
    }

    Popup {
        id: tooltip
        anchorItem: root
        interactive: false
        minWidth: 200
        title: NetworkService.wired ? "Ethernet" : NetworkService.wifi ? "Wi-Fi" : "Disconnected"

        MenuRow {
            visible: NetworkService.connected
            icon: NetworkService.wired ? "󰈀" : "󰖩"
            text: NetworkService.wifiNetwork?.name ?? NetworkService.device?.name ?? ""
            detail: NetworkService.wired ? `${NetworkService.wired.linkSpeed} Mb/s` : `${Math.round(NetworkService.signal * 100)}%`
        }

        MenuRow {
            visible: NetworkService.connected
            icon: "󰁅"
            text: NetworkService.formatSpeed(NetworkService.down)
        }

        MenuRow {
            visible: NetworkService.connected
            icon: "󰁝"
            text: NetworkService.formatSpeed(NetworkService.up)
        }
    }
}
