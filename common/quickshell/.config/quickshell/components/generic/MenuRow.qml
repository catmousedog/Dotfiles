// MenuRow.qml
// Clickable row for a Popup: icon, label and an optional detail on the right.

import QtQuick
import QtQuick.Layouts
import qs.config

Rectangle {
    id: root

    property string icon: ""
    property string text: ""
    property string detail: ""
    property bool active: false
    property bool dimmed: false
    // false for a heading: no hover, no click
    property bool clickable: true
    property int indent: 0

    signal clicked

    readonly property color foreground: active ? Theme.accent : dimmed ? Theme.muted : Theme.fg

    Layout.fillWidth: true
    implicitWidth: row.implicitWidth + row.anchors.leftMargin + row.anchors.rightMargin
    implicitHeight: row.implicitHeight + 10
    radius: height / 2
    color: clickable && mouse.containsMouse ? Theme.surface : "transparent"

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin: 10 + root.indent
        anchors.rightMargin: 10
        spacing: 10

        Bartext {
            text: root.icon
            color: root.foreground
            horizontalAlignment: Text.AlignHCenter
            // wide enough for a layout code ("BE") too
            Layout.preferredWidth: Math.max(font.pointSize * 1.6, implicitWidth)
        }

        Bartext {
            text: root.text
            color: root.foreground
            elide: Text.ElideRight
            Layout.fillWidth: true
            Layout.maximumWidth: 320
        }

        Bartext {
            visible: root.detail !== ""
            text: root.detail
            color: Theme.subtle
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.clickable
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
