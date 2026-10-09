// TrayIndicator.qml

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.components.generic

Barbox {
    id: root

    readonly property real iconSize: ConfigService.get("left.tray.iconSize")
    readonly property real trayItemSpacing: ConfigService.get("left.tray.spacing")

    implicitHeight: parent.height
    implicitWidth: TrayService.items.length > 0 ? trayRow.implicitWidth + 12 : 0
    visible: TrayService.items.length > 0

    RowLayout {
        id: trayRow
        anchors.centerIn: parent
        spacing: root.trayItemSpacing

        Repeater {
            model: TrayService.items

            delegate: Item {
                id: trayItem

                required property var modelData

                implicitWidth: root.iconSize
                implicitHeight: root.iconSize
                Layout.alignment: Qt.AlignVCenter

                IconImage {
                    anchors.fill: parent
                    source: trayItem.modelData.icon
                }
            }
        }
    }
}
