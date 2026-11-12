// Barbox.qml
// A pill on the bar: a GradientFrame that is always lit, with Hyprland's border width.

import QtQuick
import qs.services

GradientFrame {
    // same as Hyprland's window borders; the config value is used until hyprctl answers
    borderWidth: HyprlandService.borderSize || ConfigService.get("common.theme.borderWidth")
    radius: implicitHeight / 2
    lit: true
}
