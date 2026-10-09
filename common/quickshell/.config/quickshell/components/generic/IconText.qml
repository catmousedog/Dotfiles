// IconText.qml

import QtQuick
import QtQuick.Layouts
import qs.services

Item {
    id: root

    implicitWidth: iconText.implicitWidth + (textText.visible ? spacing + textText.implicitWidth : 0) + Math.max(0, iconXOffset)
    implicitHeight: textText.implicitHeight

    // shared
    property var color: null
    property var spacing: 2

    // Icon
    property string icon: ""
    property real iconSize: -1
    property real iconXOffset: 0
    property real iconYOffset: 0

    // Text
    property string text: ""
    property real textSize: -1

    Bartext {
        id: iconText
        text: root.icon
        anchors.left: root.left
        transform: Translate {
            x: root.iconXOffset
            y: root.iconYOffset
        }

        Binding {
            when: root.color !== null
            target: iconText
            property: "color"
            value: root.color
        }

        Binding {
            when: root.iconSize >= 0
            target: iconText
            property: "font.pointSize"
            value: root.iconSize
        }
    }

    Bartext {
        id: textText
        text: root.text
        anchors.right: root.right
        visible: root.text !== ""

        Binding {
            when: root.color !== null
            target: textText
            property: "color"
            value: root.color
        }

        Binding {
            when: root.textSize >= 0
            target: textText
            property: "font.pointSize"
            value: root.textSize
        }
    }
}
