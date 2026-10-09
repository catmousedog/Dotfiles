// Popup.qml
// Dropdown under a bar item, styled like a Barbox. Closes on a click outside or Escape.
//
//     Popup { id: popup; anchorItem: someItem; title: "..."; MenuRow { ... } }
//     popup.toggle()
//
// With interactive: false it takes no focus, for tooltips opened on hover.

import Quickshell
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.config
import qs.services

PopupWindow {
    id: root

    required property Item anchorItem
    property string title: ""
    property int padding: 10
    property int minWidth: 220
    property bool interactive: true
    default property alias content: column.data

    // distance from the top of anchorItem to just below the bar, set on open
    property real dropHeight: anchorItem.height

    color: "transparent"
    grabFocus: interactive

    // the popup's top right corner sits below the item's right edge and grows to the
    // left, so it never lines up with the bar's own edges
    anchor.item: anchorItem
    anchor.rect.width: anchorItem.width
    anchor.rect.height: dropHeight
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left

    implicitWidth: box.implicitWidth
    implicitHeight: box.implicitHeight

    function toggle() {
        if (visible)
            close();
        else
            open();
    }

    function close() {
        visible = false;
    }

    function open() {
        let bar = anchorItem;
        while (bar.parent)
            bar = bar.parent;
        dropHeight = bar.height - anchorItem.mapToItem(bar, 0, 0).y + 2 * HyprlandService.gapsOut;
        visible = true;
    }

    // A Barbox paints its gradient under an opaque fill; here the fill is see-through,
    // so the gradient is masked down to a ring instead.
    Item {
        id: box
        anchors.fill: parent
        implicitWidth: Math.max(column.implicitWidth, root.minWidth) + 2 * root.padding
        implicitHeight: column.implicitHeight + 2 * root.padding

        readonly property real radius: 18
        readonly property int borderWidth: 2

        Rectangle {
            id: gradientFill
            anchors.fill: parent
            radius: box.radius
            visible: false
            layer.enabled: true
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: Theme.red
                }
                GradientStop {
                    position: 1.0
                    color: Theme.blue
                }
            }
        }

        Item {
            id: ringMask
            anchors.fill: parent
            visible: false
            layer.enabled: true

            Rectangle {
                anchors.fill: parent
                anchors.margins: box.borderWidth
                radius: box.radius - box.borderWidth
                color: "black"
            }
        }

        MultiEffect {
            anchors.fill: parent
            source: gradientFill
            maskEnabled: true
            maskInverted: true
            maskSource: ringMask
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: box.borderWidth
            radius: box.radius - box.borderWidth
            color: Qt.alpha(Theme.base, 0.85)
        }

        focus: true
        Keys.onEscapePressed: root.visible = false

        ColumnLayout {
            id: column
            anchors.fill: parent
            anchors.margins: root.padding
            spacing: 2

            Bartext {
                visible: root.title !== ""
                text: root.title
                color: Theme.subtext0
                Layout.leftMargin: 8
                Layout.bottomMargin: 4
            }
        }
    }
}
