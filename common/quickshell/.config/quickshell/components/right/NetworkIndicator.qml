// NetworkIndicator.qml
// Hover: connection name and signal strength

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services
import qs.components.generic

IconText {
    id: root

    // wired, wifi by signal strength, disconnected
    icons: ["󰈀", "󰤯", "󰤟", "󰤢", "󰤥", "󰤨", "󰤮"]
    icon: {
        if (NetworkService.wired)
            return icons[0];
        if (NetworkService.wifi)
            return icons[1 + Math.min(4, Math.floor(NetworkService.signal * 5))];
        return icons[6];
    }
    iconYOffset: -1
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
    }
}
