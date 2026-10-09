// Right.qml

import Quickshell
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import qs.services
import qs.components.generic

Barbox {
    implicitHeight: parent.height
    // at least widthFactor of the screen, wider when the items need it
    implicitWidth: Math.max(parent.width * ConfigService.get("right.widthFactor"), row.implicitWidth + implicitHeight)
    anchors.right: parent.right

    RowLayout {
        id: row

        anchors.centerIn: parent
        layoutDirection: Qt.RightToLeft
        spacing: ConfigService.get("right.spacing")

        BatteryIndicator {}

        AudioIndicator {}

        BluetoothIndicator {}

        NetworkIndicator {}

        KeyBoardIndicator {}
    }
}
