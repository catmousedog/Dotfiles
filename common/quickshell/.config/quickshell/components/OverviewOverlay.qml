// OverviewOverlay.qml
// The watrix grid zoomed out: one cell per logical workspace, split per
// monitor. Each monitor box shows its windows scaled down to where they sit,
// with their icon.
//
//   arrows / hjkl         move the selection
//   enter / click         go to the selected workspace
//   1-9                   go to that workspace, counted left to right, top to bottom
//   escape / right click  close, as does clicking outside the grid or the keybind again

pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import qs.config
import qs.services

PanelWindow {
    id: win

    screen: OverviewService.screen
    color: "transparent"

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "overview"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    readonly property int matrix: OverviewService.matrix
    readonly property real dim: ConfigService.get("overview.dim")
    // height of a cell, as a fraction of the screen height
    readonly property real cellScale: ConfigService.get("overview.cellScale")
    readonly property real iconSize: ConfigService.get("overview.iconSize")
    readonly property real spacing: ConfigService.get("overview.spacing")
    readonly property real borderWidth: HyprlandService.borderSize || ConfigService.get("common.theme.borderWidth")
    readonly property real cellHeight: height * cellScale

    // same arrows as the workspace indicator in the bar
    readonly property var arrows: ["󰁛", "󰁝", "󰁜", "󰁍", "", "󰁔", "󰁂", "󰁅", "󰁃"]

    // the cell enter would go to, starts on the current one
    property int selected: Math.max(0, OverviewService.current)

    function move(dx: int, dy: int): void {
        const row = Math.max(0, Math.min(matrix - 1, Math.floor(selected / matrix) + dy));
        const col = Math.max(0, Math.min(matrix - 1, selected % matrix + dx));
        selected = row * matrix + col;
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, win.dim)
    }

    // clicks that miss the grid close it
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: OverviewService.close()
    }

    Rectangle {
        id: panel

        anchors.centerIn: parent
        implicitWidth: grid.implicitWidth + 2 * win.spacing
        implicitHeight: grid.implicitHeight + 2 * win.spacing
        radius: win.spacing * 1.5
        color: Theme.bg
        border.color: Theme.accent
        border.width: win.borderWidth

        // keep clicks between cells from reaching the close area
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: event => {
                if (event.button === Qt.RightButton)
                    OverviewService.close();
            }
        }

        Grid {
            id: grid

            anchors.centerIn: parent
            columns: win.matrix
            spacing: win.spacing

            Repeater {
                model: OverviewService.numWorkspaces

                delegate: Rectangle {
                    id: cell

                    required property int index

                    readonly property bool isCurrent: index === OverviewService.current
                    readonly property bool isSelected: index === win.selected
                    readonly property int count: {
                        let n = 0;
                        for (let m = 0; m < OverviewService.monitors.length; m++)
                            n += OverviewService.toplevels(index, m).length;
                        return n;
                    }

                    implicitWidth: monitorRow.implicitWidth + 2 * win.spacing
                    implicitHeight: win.cellHeight
                    radius: win.spacing
                    color: isSelected ? Theme.surface_hi : count > 0 ? Theme.surface : Theme.bg_alt
                    border.color: isCurrent ? Theme.accent : isSelected ? Theme.overlay : "transparent"
                    border.width: win.borderWidth

                    // faint arrow in the background, like the bar shows for this cell
                    Text {
                        anchors.centerIn: parent
                        text: win.arrows[cell.index]
                        color: Theme.muted
                        opacity: cell.count > 0 ? 0.15 : 0.5
                        font.family: ConfigService.get("common.font.family")
                        font.pixelSize: win.cellHeight * 0.4
                        font.weight: 1000
                    }

                    Row {
                        id: monitorRow

                        anchors.centerIn: parent
                        spacing: win.spacing

                        Repeater {
                            model: OverviewService.monitors

                            // one box per monitor, shaped like it
                            delegate: Rectangle {
                                id: monitorBox

                                required property var modelData
                                required property int index

                                readonly property var toplevels: OverviewService.toplevels(cell.index, index)
                                readonly property var logical: OverviewService.logicalSize(modelData)
                                // box pixels per layout pixel
                                readonly property real scale: width / Math.max(1, logical.w)

                                implicitHeight: win.cellHeight - 2 * win.spacing
                                implicitWidth: implicitHeight * (logical.w / Math.max(1, logical.h))
                                radius: win.spacing / 2
                                color: "transparent"
                                border.color: Theme.overlay
                                border.width: OverviewService.monitors.length > 1 ? 1 : 0

                                Item {
                                    anchors.fill: parent
                                    clip: true

                                    Repeater {
                                        // tiled first so floating windows end up on top
                                        model: monitorBox.toplevels.filter(t => t.lastIpcObject?.at).sort((a, b) => (a.lastIpcObject.floating ? 1 : 0) - (b.lastIpcObject.floating ? 1 : 0))

                                        delegate: Rectangle {
                                            id: windowBox

                                            required property var modelData
                                            readonly property var ipc: modelData.lastIpcObject

                                            x: (ipc.at[0] - monitorBox.modelData.x) * monitorBox.scale
                                            y: (ipc.at[1] - monitorBox.modelData.y) * monitorBox.scale
                                            width: Math.max(2, ipc.size[0] * monitorBox.scale)
                                            height: Math.max(2, ipc.size[1] * monitorBox.scale)
                                            radius: 3
                                            color: Theme.bg_deep
                                            border.color: modelData.activated ? Theme.accent : Theme.overlay
                                            border.width: Math.max(1, win.borderWidth / 2)

                                            IconImage {
                                                anchors.centerIn: parent
                                                implicitSize: Math.min(win.iconSize, windowBox.width - 4, windowBox.height - 4)
                                                visible: implicitSize > 6
                                                source: OverviewService.appIcon(windowBox.modelData)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: win.selected = cell.index
                        onClicked: OverviewService.goTo(cell.index)
                    }
                }
            }
        }
    }

    Item {
        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            const k = event.key;
            if (k === Qt.Key_Escape)
                OverviewService.close();
            else if (k === Qt.Key_Return || k === Qt.Key_Enter || k === Qt.Key_Space)
                OverviewService.goTo(win.selected);
            else if (k === Qt.Key_Left || k === Qt.Key_H)
                win.move(-1, 0);
            else if (k === Qt.Key_Right || k === Qt.Key_L)
                win.move(1, 0);
            else if (k === Qt.Key_Up || k === Qt.Key_K)
                win.move(0, -1);
            else if (k === Qt.Key_Down || k === Qt.Key_J)
                win.move(0, 1);
            else if (k >= Qt.Key_1 && k <= Qt.Key_9)
                OverviewService.goTo(k - Qt.Key_1);
            event.accepted = true;
        }
    }
}
