// KeyBoardIndicator.qml
// Left click: pick a keyboard layout, right click: next layout (same as SUPER+space)

import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.components.generic

Bartext {
    id: root

    text: KeyboardService.short

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                KeyboardService.next();
            else
                popup.toggle();
        }
    }

    Popup {
        id: popup
        anchorItem: root
        title: "Keyboard layout"

        Repeater {
            model: KeyboardService.layouts

            delegate: MenuRow {
                required property var modelData
                required property int index
                readonly property bool current: index === KeyboardService.activeIndex
                icon: modelData.code.toUpperCase()
                text: modelData.name
                active: current
                clickable: !current
                onClicked: KeyboardService.setLayout(index)
            }
        }

        Separator {}

        MenuRow {
            clickable: false
            dimmed: true
            icon: "󰌌"
            text: "Next layout"
            detail: "SUPER+Space"
        }
    }
}
