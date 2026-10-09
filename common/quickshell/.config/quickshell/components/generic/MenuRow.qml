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

    signal clicked

    readonly property color foreground: active ? Theme.accent : dimmed ? Theme.muted : Theme.fg

    Layout.fillWidth: true
    implicitWidth: row.implicitWidth + 2 * row.anchors.leftMargin
    implicitHeight: row.implicitHeight + 10
    radius: height / 2
    color: mouse.containsMouse ? Theme.surface : "transparent"

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10

        Bartext {
            text: root.icon
            color: root.foreground
            horizontalAlignment: Text.AlignHCenter
            Layout.preferredWidth: font.pointSize * 1.6
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
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
