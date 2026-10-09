// WorkspaceIndicator.qml

import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.components.generic

Barbox {

    implicitHeight: parent.height
    implicitWidth: parent.height * 1.1

    Bartext {
        anchors.centerIn: parent
        text: getIcon()
        font.weight: 1000

        function getIcon() {
            let id = WorkspaceService.activeWorkspace?.id ?? -1;
            if (id == -1)
                return "";

            id = (id - 1) % 9;

            const icons = ["󰁛", "󰁝", "󰁜", "󰁍", "", "󰁔", "󰁂", "󰁅", "󰁃"];
            return icons[id];
        }
    }
}
