// Bar.qml

import Quickshell
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

    implicitHeight: screen.height * ConfigService.get("common.layout.heightFactor")
    implicitWidth: screen.width - 2 * HyprlandService.gapsOut

    anchors.top: true
    // margins.top: ConfigService.get("common.layout.marginTop")
    // margins.right: ConfigService.get("common.layout.marginSide")
    // margins.left: ConfigService.get("common.layout.marginSide")

    margins.top: HyprlandService.gapsOut
    margins.right: HyprlandService.gapsOut
    margins.left: HyprlandService.gapsOut
    color: "transparent"

    Left {}

    Center {}

    Right {}
}
