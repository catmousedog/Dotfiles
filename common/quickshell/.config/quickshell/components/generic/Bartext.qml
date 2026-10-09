// Bartext.qml

import Quickshell
import QtQuick
import qs.services

Text {
    color: ConfigService.getColor("common.font.color")
    font.pointSize: ConfigService.get("common.font.size")
    font.family: ConfigService.get("common.font.family")
    font.weight: ConfigService.get("common.font.weight")
}
