// GradientFrame.qml
// A box with a border that fades into the same accent2 -> accent gradient as
// Barbox while lit, and is a plain borderColor otherwise. Children are drawn
// on top of the fill.

import QtQuick
import qs.config

Rectangle {
    id: root

    property bool lit: false
    property color fill: Theme.bg
    property color borderColor: "transparent"
    property real borderWidth: 2

    color: borderColor

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        opacity: root.lit ? 1 : 0

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: Theme.accent2
            }
            GradientStop {
                position: 1.0
                color: Theme.accent
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: root.borderWidth
        radius: Math.max(0, root.radius - root.borderWidth)
        color: root.fill

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }
}
