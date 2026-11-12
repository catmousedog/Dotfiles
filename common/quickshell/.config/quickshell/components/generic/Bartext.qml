// Bartext.qml

import Quickshell
import QtQuick
import qs.services

Text {
    // for "red when ..., else normal": color: cond ? Theme.red : defaultColor
    readonly property color defaultColor: ConfigService.getColor("common.font.color")

    color: defaultColor
    font.pointSize: ConfigService.get("common.font.size")
    font.family: ConfigService.get("common.font.family")
    font.weight: ConfigService.get("common.font.weight")
}
