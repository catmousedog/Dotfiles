// Bar.qml

import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.services
import qs.components.generic
import qs.components.left
import qs.components.center
import qs.components.right

PanelWindow {
    required property var modelData
    screen: modelData

    implicitHeight: 2.2 * fontMetrics.height
    implicitWidth: screen.width - 2 * HyprlandService.gapsOut

    Text {
        id: hiddenSizer
        visible: false
        font.family: ConfigService.get("common.font.family")
        font.pixelSize: ConfigService.get("common.font.size")
    }

    FontMetrics {
        id: fontMetrics
        font: hiddenSizer.font
    }

    anchors.top: true

    margins.top: HyprlandService.gapsOut
    margins.right: HyprlandService.gapsOut
    margins.left: HyprlandService.gapsOut
    // margins.bottom: HyprlandService.gapsIn
    color: "transparent"

    Left {}

    Center {}

    Right {}
}
