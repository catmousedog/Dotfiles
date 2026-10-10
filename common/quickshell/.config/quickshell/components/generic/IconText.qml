// IconText.qml

import QtQuick
import QtQuick.Layouts
import qs.services

Item {
    id: root

    implicitWidth: iconWidth + (textText.visible ? spacing + textText.implicitWidth : 0) + Math.max(0, iconXOffset)
    implicitHeight: textText.implicitHeight

    // shared
    property var color: null
    property var spacing: 2

    // Icon
    property string icon: ""
    property real iconSize: -1
    property real iconXOffset: 0
    property real iconYOffset: 0
    // every icon this item can show: the widest one sets the width, so the bar
    // doesn't move when the icon changes (the icon font is not monospace)
    property var icons: []
    readonly property real iconWidth: Math.ceil(Math.max(iconText.implicitWidth, ...icons.map(i => iconMetrics.advanceWidth(i))))

    FontMetrics {
        id: iconMetrics
        font: iconText.font
    }

    // Text
    property string text: ""
    property real textSize: -1

    Bartext {
        id: iconText
        text: root.icon
        // named explicitly: fontconfig's fallback can pick another font that has
        // something else at the same private-use codepoint (gsfonts, U+EFCF)
        font.family: ConfigService.get("common.font.iconFamily")
        anchors.left: root.left
        width: root.iconWidth
        horizontalAlignment: Text.AlignHCenter
        // the icon font has its own line height: sit on the text's baseline
        anchors.baseline: textText.baseline
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
