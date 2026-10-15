// OverviewOverlay.qml
// The watrix grid zoomed out: one cell per logical workspace, split per
// monitor. Each monitor box shows its windows scaled down to where they sit,
// with their icon, colored per app (overview.appColors in the config). A fullscreen window fills
// its whole monitor box, which is the whole cell on a single monitor; other
// windows there are drawn over it.
//
//   arrows                move the selection
//   enter / click         go to the selected workspace
//   1-9                   go to that workspace, counted left to right, top to bottom
//   escape / right click  close, as does clicking outside the grid or the keybind again

pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import qs.components.generic
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

    // The bar joins this layer while the overview is open (StatusBar.qml) and
    // misc.lua orders the overview below it: like the special workspace,
    // everything but the bar gets dimmed and blurred, fullscreen windows too.
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
    readonly property string fontFamily: ConfigService.get("common.font.family")

    // same arrows as the workspace indicator in the bar
    readonly property var arrows: ["󰁛", "󰁝", "󰁜", "󰁍", "", "󰁔", "󰁂", "󰁅", "󰁃"]


    // the cell enter would go to, starts on the current one
    property int selected: Math.max(0, OverviewService.current)

    // Where the pointer last selected from. Hovering only selects once the
    // pointer really moves away from there: opening keeps the current cell, and
    // cells shifting under a still pointer (after an arrow key) don't count.
    property point lastPointer: Qt.point(-1, -1)

    function pointerMoved(p: point): bool {
        if (lastPointer.x < 0) {
            lastPointer = p;
            return false;
        }
        if (Math.abs(p.x - lastPointer.x) + Math.abs(p.y - lastPointer.y) <= 3)
            return false;
        lastPointer = p;
        return true;
    }

    function move(dx: int, dy: int): void {
        const row = Math.max(0, Math.min(matrix - 1, Math.floor(selected / matrix) + dy));
        const col = Math.max(0, Math.min(matrix - 1, selected % matrix + dx));
        selected = row * matrix + col;
    }

    // the tint over an opaque base, so overlapping windows don't mix
    function windowFill(toplevel: var): color {
        return Qt.tint(Theme.bg_deep, Theme.changeAlpha(OverviewService.appColor(toplevel), toplevel.activated ? 0.35 : 0.2));
    }

    function windowBorder(toplevel: var): color {
        return Theme.changeAlpha(OverviewService.appColor(toplevel), 0.8);
    }

    function isFullscreen(toplevel: var): bool {
        return ((toplevel.lastIpcObject?.fullscreen ?? 0) & 2) !== 0;
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.changeAlpha(Theme.bg_deep, win.dim)
    }

    // clicks that miss the grid close it
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: OverviewService.close()
    }

    GradientFrame {
        id: panel

        anchors.centerIn: parent
        implicitWidth: grid.implicitWidth + 4 * win.spacing
        implicitHeight: grid.implicitHeight + 4 * win.spacing
        radius: win.spacing * 2
        // dim, the cells inside already have plenty of borders
        borderColor: Theme.surface_alt
        borderWidth: win.borderWidth
        fill: Theme.bg

        // grows in as it opens
        scale: 0.94
        opacity: 0
        Component.onCompleted: {
            scale = 1;
            opacity = 1;
        }

        Behavior on scale {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutBack
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 160
            }
        }

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

                delegate: GradientFrame {
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

                    implicitWidth: monitorRow.implicitWidth + 2 * borderWidth
                    implicitHeight: win.cellHeight
                    radius: win.spacing * 1.2
                    borderWidth: win.borderWidth
                    lit: isCurrent
                    borderColor: isSelected ? Theme.changeAlpha(Theme.accent, 0.6) : count > 0 ? Theme.surface_alt : Theme.surface
                    fill: isSelected ? Theme.surface_alt : count > 0 ? Theme.surface : Theme.bg_alt

                    // the selection lifts a little above its neighbours
                    z: isSelected ? 1 : 0
                    scale: isSelected ? 1.04 : 1

                    Behavior on scale {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }

                    // the arrow the bar shows for this cell, faint behind the windows
                    Text {
                        anchors.centerIn: parent
                        text: win.arrows[cell.index]
                        color: cell.isCurrent ? Theme.accent : cell.isSelected ? Theme.fg : Theme.muted
                        opacity: cell.count > 0 ? 0.18 : cell.isCurrent || cell.isSelected ? 0.8 : 0.4
                        font.family: win.fontFamily
                        font.pixelSize: win.cellHeight * 0.4
                        font.weight: 1000
                    }

                    Row {
                        id: monitorRow

                        anchors.centerIn: parent
                        spacing: win.spacing

                        Repeater {
                            model: OverviewService.monitors

                            // One box per monitor, filling the cell's height with its
                            // rounded corners. Windows sit inset from its edges, in an
                            // area shaped like the monitor; fullscreen ones fill it all.
                            delegate: Rectangle {
                                id: monitorBox

                                required property var modelData
                                required property int index

                                readonly property var toplevels: OverviewService.toplevels(cell.index, index)
                                readonly property var logical: OverviewService.logicalSize(modelData)
                                readonly property real inset: win.spacing
                                // box pixels per layout pixel, inside the inset
                                readonly property real scale: (height - 2 * inset) / Math.max(1, logical.h)

                                function stack(t: var): int {
                                    return win.isFullscreen(t) ? 0 : t.lastIpcObject.floating ? 2 : 1;
                                }

                                implicitHeight: win.cellHeight - 2 * cell.borderWidth
                                implicitWidth: (implicitHeight - 2 * inset) * (logical.w / Math.max(1, logical.h)) + 2 * inset
                                radius: Math.max(0, cell.radius - cell.borderWidth)
                                color: "transparent"
                                border.color: Theme.changeAlpha(Theme.overlay, 0.5)
                                border.width: OverviewService.monitors.length > 1 ? 1 : 0
                                clip: true

                                Repeater {
                                    // fullscreen first, then tiled, then floating, so the
                                    // right ones end up on top
                                    model: monitorBox.toplevels.filter(t => t.lastIpcObject?.at).sort((a, b) => monitorBox.stack(a) - monitorBox.stack(b))

                                    delegate: Rectangle {
                                        id: windowBox

                                        required property var modelData
                                        readonly property var ipc: modelData.lastIpcObject
                                        readonly property bool fullscreen: win.isFullscreen(modelData)

                                        x: fullscreen ? 0 : monitorBox.inset + (ipc.at[0] - monitorBox.modelData.x) * monitorBox.scale
                                        y: fullscreen ? 0 : monitorBox.inset + (ipc.at[1] - monitorBox.modelData.y) * monitorBox.scale
                                        width: fullscreen ? monitorBox.width : Math.max(2, ipc.size[0] * monitorBox.scale)
                                        height: fullscreen ? monitorBox.height : Math.max(2, ipc.size[1] * monitorBox.scale)
                                        radius: fullscreen ? monitorBox.radius : 4
                                        color: win.windowFill(modelData)
                                        border.color: win.windowBorder(modelData)
                                        border.width: Math.max(1, win.borderWidth / 2)

                                        IconImage {
                                            anchors.centerIn: parent
                                            implicitSize: Math.min(win.iconSize, windowBox.width - 6, windowBox.height - 6)
                                            visible: implicitSize > 6
                                            source: OverviewService.appIcon(windowBox.modelData)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPositionChanged: mouse => {
                            if (win.pointerMoved(mapToItem(null, mouse.x, mouse.y)))
                                win.selected = cell.index;
                        }
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
            else if (k === Qt.Key_Left)
                win.move(-1, 0);
            else if (k === Qt.Key_Right)
                win.move(1, 0);
            else if (k === Qt.Key_Up)
                win.move(0, -1);
            else if (k === Qt.Key_Down)
                win.move(0, 1);
            else if (k >= Qt.Key_1 && k <= Qt.Key_9)
                OverviewService.goTo(k - Qt.Key_1);
            event.accepted = true;
        }
    }
}
