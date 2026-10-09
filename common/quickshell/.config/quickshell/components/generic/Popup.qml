// Popup.qml
// Dropdown under a bar item, styled like a Barbox. Closes on a click outside or Escape.
//
//     Popup { id: popup; anchorItem: someItem; title: "..."; MenuRow { ... } }
//     popup.toggle()
//
// With interactive: false it takes no focus, for tooltips opened on hover.

import Quickshell
import QtQuick
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

    anchor.item: anchorItem
    anchor.rect.width: anchorItem.width
    anchor.rect.height: dropHeight
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom

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
        dropHeight = bar.height - anchorItem.mapToItem(bar, 0, 0).y + HyprlandService.gapsOut;
        visible = true;
    }

    Barbox {
        id: box
        anchors.fill: parent
        radius: 18
        implicitWidth: Math.max(column.implicitWidth, root.minWidth) + 2 * root.padding
        implicitHeight: column.implicitHeight + 2 * root.padding

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
