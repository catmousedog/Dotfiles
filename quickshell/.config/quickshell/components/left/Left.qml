// Left.qml

import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.services
import qs.components.generic

RowLayout {

    implicitHeight: parent.height
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    layoutDirection: Qt.LeftToRight

    Barbox {
        implicitHeight: parent.height
        implicitWidth: parent.height * 1.1

        Bartext {
            anchors.centerIn: parent
            text: WorkspaceService.activeWorkspace?.name ?? ""
        }
    }

    Barbox {
        id: test
        implicitHeight: parent.height
        implicitWidth: {
            let len = TrayService.items.length;
            if (len == 0) {
                return 0;
            } else {
                return len * 100;
            }
        }

        Bartext {
            function trayStatusText() {
                let len = TrayService.items.length;
                text = "";
                for (let i = 0; i < len; i++) {
                    const item = TrayService.items[i];
                    text += item.id;
                }
                return text;
            }

            anchors.centerIn: parent
            text: trayStatusText()
        }
    }
}
