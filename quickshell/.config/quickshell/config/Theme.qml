// Theme.qml

pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import QtCore

Singleton {
    id: root

    function changeAlpha(color: string, alpha: real): string {
        return Qt.rgba(color.r, color.g, color.b, alpha);
    }

    function getColor(name: string): string {
        return json[name] ?? "";
    }

    property string rosewater: json.rosewater
    property string flamingo: json.flamingo
    property string pink: json.pink
    property string mauve: json.mauve
    property string red: json.red
    property string maroon: json.maroon
    property string peach: json.peach
    property string yellow: json.yellow
    property string green: json.green
    property string teal: json.teal
    property string sky: json.sky
    property string sapphire: json.sapphire
    property string blue: json.blue
    property string lavender: json.lavender
    property string text: json.text
    property string subtext1: json.subtext1
    property string subtext0: json.subtext0
    property string overlay2: json.overlay2
    property string overlay1: json.overlay1
    property string overlay0: json.overlay0
    property string surface2: json.surface2
    property string surface1: json.surface1
    property string surface0: json.surface0
    property string base: json.base
    property string mantle: json.mantle
    property string crust: json.crust

    FileView {
        path: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/themes/theme.json"

        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: json
            property string rosewater
            property string flamingo
            property string pink
            property string mauve
            property string red
            property string maroon
            property string peach
            property string yellow
            property string green
            property string teal
            property string sky
            property string sapphire
            property string blue
            property string lavender
            property string text
            property string subtext1
            property string subtext0
            property string overlay2
            property string overlay1
            property string overlay0
            property string surface2
            property string surface1
            property string surface0
            property string base
            property string mantle
            property string crust
        }
    }
}
