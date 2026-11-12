// Segmented.qml
// One pill split into icon buttons, for picking one of a few states in a Popup.
// The current one is filled with its own color and the fill slides between them.
//
//     Segmented {
//         options: [{ value: x, icon: "󰾅", color: "accent" }, ...]   // color: a Theme role
//         current: x
//         onSelected: value => ...
//     }

import QtQuick
import QtQuick.Layouts
import qs.config

Rectangle {
    id: root

    property var options: []
    property var current
    signal selected(var value)

    readonly property int currentIndex: options.findIndex(o => o.value === current)
    readonly property int inset: 3
    readonly property real segmentWidth: (width - 2 * inset) / Math.max(1, options.length)
    readonly property real segmentHeight: height - 2 * inset

    Layout.fillWidth: true
    implicitWidth: options.length * 56
    implicitHeight: 36
    radius: height / 2
    color: Theme.surface

    // the fill behind the current option
    Rectangle {
        visible: root.currentIndex >= 0
        x: root.inset + Math.max(0, root.currentIndex) * root.segmentWidth
        y: root.inset
        width: root.segmentWidth
        height: root.segmentHeight
        radius: height / 2
        color: Theme.getColor(root.options[root.currentIndex]?.color ?? "accent")

        Behavior on x {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }
        Behavior on color {
            ColorAnimation {
                duration: 220
            }
        }
    }

    Row {
        x: root.inset
        y: root.inset

        Repeater {
            model: root.options

            delegate: Item {
                id: segment
                required property var modelData
                required property int index
                readonly property bool isCurrent: index === root.currentIndex

                width: root.segmentWidth
                height: root.segmentHeight

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: Theme.surface_hi
                    opacity: !segment.isCurrent && mouse.containsMouse ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 120
                        }
                    }
                }

                Icon {
                    anchors.centerIn: parent
                    text: segment.modelData.icon
                    color: segment.isCurrent ? Theme.bg : mouse.containsMouse ? Theme.fg : Theme.subtle

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: segment.isCurrent ? Qt.ArrowCursor : Qt.PointingHandCursor
                    onClicked: if (!segment.isCurrent)
                        root.selected(segment.modelData.value)
                }
            }
        }
    }
}
