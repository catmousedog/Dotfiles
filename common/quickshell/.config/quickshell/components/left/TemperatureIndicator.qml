// TemperatureIndicator.qml
// CPU and GPU temperature, red from left.temperature.warn; a sensor the machine lacks is left out

import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.components.generic

Barbox {
    id: root

    readonly property int warn: ConfigService.get("left.temperature.warn")

    implicitHeight: parent.height
    implicitWidth: row.implicitWidth + implicitHeight
    visible: TemperatureService.cpu >= 0 || TemperatureService.gpu >= 0

    component Temperature: RowLayout {
        id: temperature

        property string label
        property int value: -1

        visible: value >= 0
        spacing: ConfigService.get("left.temperature.spacing")

        Bartext {
            text: temperature.label
            color: Theme.muted
        }

        Bartext {
            text: temperature.value + "°"
            color: temperature.value >= root.warn ? Theme.red : ConfigService.getColor("common.font.color")
        }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: ConfigService.get("right.spacing")

        Temperature {
            label: "CPU"
            value: TemperatureService.cpu
        }

        Temperature {
            label: "GPU"
            value: TemperatureService.gpu
        }
    }
}
