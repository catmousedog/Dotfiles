// Bar.qml

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
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

    implicitHeight: ConfigService.get("common.bar.size") * fontMetrics.height
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

    // above fullscreen windows while the overview is open (on every screen),
    // which sits just below the bar, see OverviewOverlay.qml
    WlrLayershell.layer: OverviewService.active ? WlrLayer.Overlay : WlrLayer.Top

    Left {}

    Center {}

    Right {}
}
