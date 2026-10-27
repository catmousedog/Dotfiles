// TemperatureService.qml
// CPU / GPU temperature in °C, -1 when the machine has no such sensor.
// hwmon files don't signal changes, so they're re-read every left.temperature.interval ms

pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string cpuPath: ""
    property string gpuPath: ""

    readonly property int cpu: cpuPath ? parse(cpuFile.text()) : -1
    readonly property int gpu: gpuPath ? parse(gpuFile.text()) : -1

    function parse(text: string): int {
        const milli = parseInt(text);
        return isNaN(milli) ? -1 : Math.round(milli / 1000);
    }

    // finds the sensors once; the hwmon numbers change between boots, the names don't
    // cpu: AMD (k10temp, zenpower) or Intel (coretemp) package
    // gpu: amdgpu junction (only the discrete card has one), else edge (integrated)
    Process {
        running: true
        command: ["sh", "-c", `
            for f in /sys/class/hwmon/hwmon*/temp*_label; do
                case "$(cat "\${f%/*}/name"):$(cat "$f")" in
                    k10temp:Tctl|zenpower:Tdie|"coretemp:Package id 0") cpu=\${f%_label}_input ;;
                    amdgpu:junction) gpu=\${f%_label}_input ;;
                    amdgpu:edge) edge=\${f%_label}_input ;;
                esac
            done
            echo "$cpu"
            echo "\${gpu:-$edge}"
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n");
                root.cpuPath = lines[0] ?? "";
                root.gpuPath = lines[1] ?? "";
            }
        }
    }

    FileView {
        id: cpuFile
        path: root.cpuPath
        blockLoading: true
    }

    FileView {
        id: gpuFile
        path: root.gpuPath
        blockLoading: true
    }

    Timer {
        interval: ConfigService.get("left.temperature.interval")
        running: root.cpuPath !== "" || root.gpuPath !== ""
        repeat: true
        onTriggered: {
            if (root.cpuPath)
                cpuFile.reload();
            if (root.gpuPath)
                gpuFile.reload();
        }
    }
}
