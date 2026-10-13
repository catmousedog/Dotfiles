// ScreenshotOverlay.qml
// Fullscreen region selector over a frozen capture of the screen.
//
//   drag                  select a region, drag again outside it to start over
//   drag inside / edges   move / resize the selection
//   arrows                move the selection while held, against a screen edge it shrinks
//   shift + arrows        resize the selection, its top left corner stays put
//   alt + either          the same, slower
//   tab / shift + tab     select the focused window, then cycle through the others
//   ctrl+tab              select a box in the center of the screen
//   ctrl+a                select the whole screen
//   ctrl+c / enter        copy the selection, or the whole screen without one
//   + shift               also save it as a file
//   double click          copy the selection
//   right click           drop the selection, or cancel without one
//   escape                cancel

pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.components.generic
import qs.config
import qs.services

PanelWindow {
    id: win

    screen: ScreenshotService.screen
    color: "transparent"

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "screenshot"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    readonly property real dim: ConfigService.get("screenshot.dim")
    readonly property real borderWidth: ConfigService.get("screenshot.borderWidth")
    // how fast held arrow keys move and resize, in image pixels per second
    readonly property real moveSpeed: ConfigService.get("screenshot.moveSpeed")
    readonly property real resizeSpeed: ConfigService.get("screenshot.resizeSpeed")
    // what is left of those speeds while alt is held
    readonly property real slowFactor: ConfigService.get("screenshot.slowFactor")
    // size of the ctrl+tab box, as a fraction of the screen
    readonly property real defaultBox: ConfigService.get("screenshot.defaultBox")
    // how close to an edge the pointer has to be to grab it
    readonly property real grabMargin: 8

    // image pixels per logical pixel, to keep the selection on whole image pixels
    readonly property real pixelScale: frozen.sourceSize.width > 0 && width > 0 ? frozen.sourceSize.width / width : 1

    // Selection corners. Not ordered: dragging an edge past the opposite one flips it.
    property real x1: 0
    property real y1: 0
    property real x2: 0
    property real y2: 0
    readonly property real sx: Math.min(x1, x2)
    readonly property real sy: Math.min(y1, y2)
    readonly property real sw: Math.abs(x2 - x1)
    readonly property real sh: Math.abs(y2 - y1)
    readonly property bool hasSelection: sw > 0 && sh > 0

    // which of ScreenshotService.windows tab selected last, -1 before the first tab
    property int windowIndex: -1

    property bool capturing: false

    function snap(v: real): real {
        return Math.round(v * pixelScale) / pixelScale;
    }

    function clearSelection(): void {
        x1 = x2 = y1 = y2 = 0;
    }

    function moveSelection(x: real, y: real): void {
        const w = sw, h = sh;
        x1 = snap(Math.max(0, Math.min(width - w, x)));
        y1 = snap(Math.max(0, Math.min(height - h, y)));
        x2 = x1 + w;
        y2 = y1 + h;
    }

    function select(x: real, y: real, w: real, h: real): void {
        x1 = snap(Math.max(0, x));
        y1 = snap(Math.max(0, y));
        x2 = snap(Math.min(width, x + w));
        y2 = snap(Math.min(height, y + h));
    }

    // Select the next (step 1) or previous (step -1) window, the whole screen if there are none
    function selectWindow(step: int): void {
        const windows = ScreenshotService.windows;
        if (windows.length === 0) {
            select(0, 0, width, height);
            return;
        }
        if (windowIndex < 0)
            windowIndex = step > 0 ? 0 : windows.length - 1;
        else
            windowIndex = (windowIndex + step + windows.length) % windows.length;
        const w = windows[windowIndex];
        select(w.x, w.y, w.w, w.h);
    }

    // Move the selection with the keyboard. Against a screen edge the far side
    // keeps coming, so it shrinks instead of stopping.
    function pushSelection(dx: real, dy: real): void {
        const min = 1 / pixelScale;
        const l = sx + dx, r = sx + sw + dx, t = sy + dy, b = sy + sh + dy;
        x1 = snap(Math.max(0, Math.min(width - min, l)));
        x2 = snap(Math.min(width, Math.max(min, r)));
        y1 = snap(Math.max(0, Math.min(height - min, t)));
        y2 = snap(Math.min(height, Math.max(min, b)));
    }

    // Grow or shrink the selection from its top left corner
    function resizeSelection(dw: real, dh: real): void {
        const l = sx, t = sy, min = 1 / pixelScale;
        x1 = l;
        y1 = t;
        x2 = l + snap(Math.max(min, Math.min(width - l, sw + dw)));
        y2 = t + snap(Math.max(min, Math.min(height - t, sh + dh)));
    }

    // What a press at this position would do: "new", "move" or "resize" (with the edges it grabs)
    function hitTest(px: real, py: real): var {
        if (!hasSelection)
            return { mode: "new" };
        const m = grabMargin;
        if (px >= sx - m && px <= sx + sw + m && py >= sy - m && py <= sy + sh + m) {
            const left = Math.abs(px - sx) <= m;
            const right = !left && Math.abs(px - sx - sw) <= m;
            const top = Math.abs(py - sy) <= m;
            const bottom = !top && Math.abs(py - sy - sh) <= m;
            if (left || right || top || bottom)
                return { mode: "resize", left, right, top, bottom };
            return { mode: "move" };
        }
        return { mode: "new" };
    }

    function cursorFor(hit: var): int {
        if (hit.mode === "move")
            return Qt.SizeAllCursor;
        if (hit.mode !== "resize")
            return Qt.CrossCursor;
        if ((hit.left && hit.top) || (hit.right && hit.bottom))
            return Qt.SizeFDiagCursor;
        if ((hit.right && hit.top) || (hit.left && hit.bottom))
            return Qt.SizeBDiagCursor;
        return hit.left || hit.right ? Qt.SizeHorCursor : Qt.SizeVerCursor;
    }

    // Render the selected part of the capture at its original resolution and hand it over
    function capture(save: bool): void {
        if (capturing || frozen.status !== Image.Ready)
            return;
        capturing = true;
        if (!hasSelection) {
            x1 = y1 = 0;
            x2 = width;
            y2 = height;
        }
        const path = ScreenshotService.outputPath(save);
        const size = Qt.size(Math.round(sw * pixelScale), Math.round(sh * pixelScale));
        const ok = cropper.grabToImage(result => {
            if (result.saveToFile(path)) {
                ScreenshotService.finish(path, save);
            } else {
                console.warn("[ScreenshotOverlay] could not write", path);
                ScreenshotService.cancel();
            }
        }, size);
        if (!ok)
            ScreenshotService.cancel();
    }

    Connections {
        target: ScreenshotService

        function onConfirmRequested(save) {
            win.capture(save);
        }
    }

    // The selection, cut out of a second copy of the capture. Sits underneath
    // the visible one, it only exists to be grabbed by capture().
    Item {
        id: cropper
        width: win.sw
        height: win.sh
        clip: true

        Image {
            x: -win.sx
            y: -win.sy
            width: win.width
            height: win.height
            source: frozen.source
            cache: false
            smooth: false
        }
    }

    Image {
        id: frozen
        anchors.fill: parent
        source: "file://" + ScreenshotService.shot
        cache: false
        smooth: false
    }

    // Dim everything but the selection. Without a selection the bottom one covers the screen.
    Rectangle {
        color: Qt.rgba(0, 0, 0, win.dim)
        width: win.width
        height: win.sy
    }
    Rectangle {
        color: Qt.rgba(0, 0, 0, win.dim)
        y: win.sy + win.sh
        width: win.width
        height: win.height - y
    }
    Rectangle {
        color: Qt.rgba(0, 0, 0, win.dim)
        y: win.sy
        width: win.sx
        height: win.sh
    }
    Rectangle {
        color: Qt.rgba(0, 0, 0, win.dim)
        x: win.sx + win.sw
        y: win.sy
        width: win.width - x
        height: win.sh
    }

    // Selection outline with the bar's gradient, drawn outside of the selected pixels.
    // A Barbox fills its inside, so this is the same gradient as four edges instead.
    Item {
        id: outline
        visible: win.hasSelection
        x: win.sx - win.borderWidth
        y: win.sy - win.borderWidth
        width: win.sw + 2 * win.borderWidth
        height: win.sh + 2 * win.borderWidth

        component Edge: Rectangle {
            width: outline.width
            height: win.borderWidth
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: Theme.accent2
                }
                GradientStop {
                    position: 1.0
                    color: Theme.accent
                }
            }
        }

        Edge {}
        Edge {
            y: outline.height - height
        }
        Rectangle {
            width: win.borderWidth
            height: outline.height
            color: Theme.accent2
        }
        Rectangle {
            x: outline.width - width
            width: win.borderWidth
            height: outline.height
            color: Theme.accent
        }
    }

    // Size of the selection in image pixels, or a hint while there is none
    Barbox {
        id: label
        readonly property real gap: 10

        implicitWidth: labelText.implicitWidth + 30
        implicitHeight: labelText.implicitHeight + 14

        x: win.hasSelection ? Math.max(gap, Math.min(win.width - width - gap, win.sx + (win.sw - width) / 2)) : (win.width - width) / 2
        y: {
            if (!win.hasSelection)
                return win.height - height - 60;
            const below = win.sy + win.sh + gap;
            if (below + height + gap <= win.height)
                return below;
            const above = win.sy - height - gap;
            // no room around the selection: put it inside
            return above >= gap ? above : win.sy + win.sh - height - gap;
        }

        Text {
            id: labelText
            anchors.centerIn: parent
            color: ConfigService.getColor("common.font.color")
            font.pointSize: ConfigService.get("common.font.size")
            font.family: ConfigService.get("common.font.family")
            font.weight: ConfigService.get("common.font.weight")
            text: win.hasSelection ? Math.round(win.sw * win.pixelScale) + " × " + Math.round(win.sh * win.pixelScale) : "Drag or Tab to select  ·  Enter to copy  ·  Shift+Enter to save  ·  Esc to cancel"
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        focus: true

        // what the current drag does
        property string mode: ""
        // which corner coordinate follows the pointer on each axis: 0 none, 1 or 2
        property int dragX: 0
        property int dragY: 0
        property real grabX: 0
        property real grabY: 0

        // Arrow keys currently held down. Opposite keys cancel out, two axes combine.
        property bool keyLeft: false
        property bool keyRight: false
        property bool keyUp: false
        property bool keyDown: false
        property bool keyShift: false
        property bool keyAlt: false
        readonly property int keyX: (keyRight ? 1 : 0) - (keyLeft ? 1 : 0)
        readonly property int keyY: (keyDown ? 1 : 0) - (keyUp ? 1 : 0)
        // the part of a pixel the held keys have not moved yet
        property real restX: 0
        property real restY: 0

        // Returns false for keys that are not arrows
        function setArrow(key: int, down: bool): bool {
            switch (key) {
            case Qt.Key_Left: keyLeft = down; break;
            case Qt.Key_Right: keyRight = down; break;
            case Qt.Key_Up: keyUp = down; break;
            case Qt.Key_Down: keyDown = down; break;
            default: return false;
            }
            return true;
        }

        // Move, or with shift resize, the selection by whole image pixels
        function nudge(dx: int, dy: int): void {
            if (!win.hasSelection || (dx === 0 && dy === 0))
                return;
            const x = dx / win.pixelScale, y = dy / win.pixelScale;
            if (keyShift)
                win.resizeSelection(x, y);
            else
                win.pushSelection(x, y);
        }

        // Glide for as long as arrow keys are held
        FrameAnimation {
            running: mouse.keyX !== 0 || mouse.keyY !== 0
            onTriggered: {
                const speed = (mouse.keyShift ? win.resizeSpeed : win.moveSpeed) * (mouse.keyAlt ? win.slowFactor : 1);
                mouse.restX += mouse.keyX * speed * frameTime;
                mouse.restY += mouse.keyY * speed * frameTime;
                const dx = Math.trunc(mouse.restX), dy = Math.trunc(mouse.restY);
                mouse.restX -= dx;
                mouse.restY -= dy;
                mouse.nudge(dx, dy);
            }
        }

        cursorShape: pressed && mode === "move" ? Qt.ClosedHandCursor : win.cursorFor(pressed ? { mode: "new" } : win.hitTest(mouseX, mouseY))

        onPressed: event => {
            if (event.button === Qt.RightButton) {
                mode = "";
                if (win.hasSelection)
                    win.clearSelection();
                else
                    ScreenshotService.cancel();
                return;
            }

            const px = win.snap(event.x), py = win.snap(event.y);
            const hit = win.hitTest(event.x, event.y);
            // order the corners so 1 is the top left one
            const l = win.sx, t = win.sy, r = l + win.sw, b = t + win.sh;
            win.x1 = l; win.y1 = t; win.x2 = r; win.y2 = b;

            mode = hit.mode === "move" ? "move" : "resize";
            if (hit.mode === "move") {
                grabX = event.x - l;
                grabY = event.y - t;
            } else if (hit.mode === "resize") {
                dragX = hit.left ? 1 : hit.right ? 2 : 0;
                dragY = hit.top ? 1 : hit.bottom ? 2 : 0;
            } else {
                win.x1 = win.x2 = px;
                win.y1 = win.y2 = py;
                dragX = dragY = 2;
            }
        }

        onPositionChanged: event => {
            if (!(pressedButtons & Qt.LeftButton) || mode === "")
                return;
            if (mode === "move") {
                win.moveSelection(event.x - grabX, event.y - grabY);
                return;
            }
            const px = win.snap(Math.max(0, Math.min(win.width, event.x)));
            const py = win.snap(Math.max(0, Math.min(win.height, event.y)));
            if (dragX === 1)
                win.x1 = px;
            else if (dragX === 2)
                win.x2 = px;
            if (dragY === 1)
                win.y1 = py;
            else if (dragY === 2)
                win.y2 = py;
        }

        onReleased: {
            mode = "";
            // a plain click outside of the selection drops it
            if (win.sw < 2 || win.sh < 2)
                win.clearSelection();
        }

        onDoubleClicked: event => {
            if (event.button === Qt.LeftButton && win.hasSelection)
                win.capture(false);
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                ScreenshotService.cancel();
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || (event.key === Qt.Key_C && event.modifiers & Qt.ControlModifier)) {
                // with shift: save to a file as well
                win.capture(event.modifiers & Qt.ShiftModifier);
            } else if (event.key === Qt.Key_A && event.modifiers & Qt.ControlModifier) {
                win.select(0, 0, win.width, win.height);
            } else if (event.key === Qt.Key_Tab && event.modifiers & Qt.ControlModifier) {
                const w = win.width * win.defaultBox, h = win.height * win.defaultBox;
                win.select((win.width - w) / 2, (win.height - h) / 2, w, h);
            } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
                win.selectWindow(event.key === Qt.Key_Tab ? 1 : -1);
            } else if (event.key === Qt.Key_Shift) {
                keyShift = true;
            } else if (event.key === Qt.Key_Alt) {
                keyAlt = true;
            } else if (!event.isAutoRepeat && setArrow(event.key, true)) {
                // modifiers may have been held since before the overlay opened
                keyShift = event.modifiers & Qt.ShiftModifier;
                keyAlt = event.modifiers & Qt.AltModifier;
                restX = restY = 0;
                // nothing to move yet: start from the focused window
                if (!win.hasSelection)
                    win.selectWindow(1);
            }
            event.accepted = true;
        }

        Keys.onReleased: event => {
            if (event.isAutoRepeat)
                return;
            if (event.key === Qt.Key_Shift)
                keyShift = false;
            else if (event.key === Qt.Key_Alt)
                keyAlt = false;
            else
                setArrow(event.key, false);
        }
    }
}
