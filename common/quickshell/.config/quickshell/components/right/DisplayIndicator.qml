// DisplayIndicator.qml
// Only while an external screen is connected.
// Left click: what each screen does, right click: mirror <-> extend

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services
import qs.components.generic

IconText {
    id: root

    visible: DisplayService.connected.length > 0
    icons: ["󰍺", "󱒃", "󰶐"]
    icon: DisplayService.icon()

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                DisplayService.toggle();
            else
                popup.toggle();
        }
    }

    readonly property var modeNames: ({
            off: "Off",
            extend: "Extend",
            mirror: "Mirror"
        })

    // the screen whose modes are shown in the popup
    property string expanded: ""

    Popup {
        id: popup
        anchorItem: root
        title: "Displays"
        onVisibleChanged: if (!visible)
            root.expanded = ""

        Repeater {
            model: DisplayService.screens

            delegate: ColumnLayout {
                id: screen
                required property var modelData
                readonly property bool open: root.expanded === modelData.name
                Layout.fillWidth: true
                spacing: 2

                MenuRow {
                    clickable: screen.modelData.connected
                    icon: "󰍹"
                    text: screen.modelData.label
                    detail: screen.modelData.connected ? root.modeNames[screen.modelData.mode] : "not connected"
                    active: screen.open
                    dimmed: !screen.modelData.connected
                    onClicked: root.expanded = screen.open ? "" : screen.modelData.name
                }

                Repeater {
                    model: screen.open ? DisplayService.modes : []

                    delegate: MenuRow {
                        required property string modelData
                        readonly property bool current: screen.modelData.mode === modelData
                        indent: 16
                        icon: current ? "󰐾" : "󰐽"
                        text: root.modeNames[modelData]
                        active: current
                        clickable: !current
                        onClicked: {
                            DisplayService.set(screen.modelData.name, modelData);
                            root.expanded = "";
                        }
                    }
                }
            }
        }
    }
}
