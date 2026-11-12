// SectionHeader.qml
// Heading inside a Popup, with an optional value on the right:
//
//     SectionHeader { text: "Power profile"; detail: "Balanced"; detailColor: Theme.green }

import QtQuick
import QtQuick.Layouts
import qs.config

RowLayout {
    id: root

    property string text: ""
    property string detail: ""
    property color detailColor: Theme.subtle

    Layout.fillWidth: true
    Layout.leftMargin: 8
    Layout.rightMargin: 8
    Layout.bottomMargin: 4

    Bartext {
        text: root.text
        color: Theme.subtle
        Layout.fillWidth: true
    }

    Bartext {
        visible: root.detail !== ""
        text: root.detail
        color: root.detailColor

        Behavior on color {
            ColorAnimation {
                duration: 220
            }
        }
    }
}
