// Right.qml

import Quickshell
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import qs.services
import qs.components.generic

Barbox {
    implicitHeight: parent.height
    implicitWidth: parent.width * ConfigService.get("right.widthFactor")
    anchors.right: parent.right

    RowLayout {
        id: row

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        layoutDirection: Qt.RightToLeft
        spacing: ConfigService.get("right.spacing")

        BatteryIndicator {}

        AudioIndicator {}

        BluetoothIndicator {}
    }
}
