// ScoreboardOverlay.qml
// A row of team cards, readable from the back of the room: the team's label in
// a pill of its color, the score big underneath. A change bumps the number and
// floats "+N" / "−N" next to it. Sits above fullscreen windows (pdfpc) and lets
// every click through.

pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.components.generic
import qs.config
import qs.services

PanelWindow {
    id: win

    required property var modelData
    required property var service

    readonly property var config: service.config
    // a smaller copy on the screen you look at yourself, config.screenScale
    readonly property real sizeFactor: config.screenScale?.[modelData.name] ?? 1
    readonly property real scoreSize: config.scoreSize * sizeFactor
    readonly property real spacing: config.spacing * sizeFactor
    readonly property real borderWidth: Math.max(2, 5 * sizeFactor)
    readonly property string fontFamily: ConfigService.get("common.font.family")
    // every card as wide as the widest label needs, and room for a 3 digit score
    readonly property real cardWidth: Math.max(scoreSize * 2.2, ...Array.from(row.children).map(c => c.labelWidth ?? 0)) + 2 * spacing

    // black or white, whichever reads better on c
    function inkFor(c: color): color {
        return 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b > 0.55 ? "#111111" : "#ffffff";
    }

    screen: modelData
    color: "transparent"

    anchors.top: config.vertical !== "bottom"
    anchors.bottom: config.vertical === "bottom"
    anchors.left: config.horizontal === "left"
    anchors.right: config.horizontal === "right"
    margins.top: config.margins.y
    margins.bottom: config.margins.y
    margins.left: config.margins.x
    margins.right: config.margins.x
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "scoreboard"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // empty input region: clicks go to whatever is underneath
    mask: Region {}

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row

        spacing: win.spacing

        Repeater {
            model: win.service.teams

            delegate: GradientFrame {
                id: card

                required property var modelData

                readonly property color teamColor: win.service.teamColor(modelData)
                readonly property int score: win.service.scores[modelData.id] ?? 0
                readonly property real labelWidth: pill.implicitWidth
                property int last: 0

                implicitWidth: win.cardWidth
                implicitHeight: pill.implicitHeight + scoreText.implicitHeight + 2 * win.spacing
                radius: win.spacing
                borderWidth: win.borderWidth
                borderColor: teamColor
                fill: Theme.changeAlpha(Theme.bg, win.config.opacity)

                Component.onCompleted: last = score

                onScoreChanged: {
                    const delta = score - last;
                    last = score;
                    if (delta === 0 || !win.service.loaded)
                        return;
                    flash.text = (delta > 0 ? "+" : "−") + Math.abs(delta);
                    bump.restart();
                    flashAnim.restart();
                }

                Rectangle {
                    id: pill

                    anchors.top: parent.top
                    anchors.topMargin: win.spacing
                    anchors.horizontalCenter: parent.horizontalCenter
                    implicitWidth: labelText.implicitWidth + 1.6 * win.spacing
                    implicitHeight: labelText.implicitHeight + 0.5 * win.spacing
                    radius: height / 2
                    color: card.teamColor

                    Text {
                        id: labelText
                        anchors.centerIn: parent
                        text: win.service.label(card.modelData)
                        color: win.inkFor(card.teamColor)
                        font.family: win.fontFamily
                        font.pixelSize: win.scoreSize * 0.32
                        font.weight: 800
                    }
                }

                Text {
                    id: scoreText

                    anchors.top: pill.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: card.score
                    color: Theme.fg
                    font.family: win.fontFamily
                    font.pixelSize: win.scoreSize
                    font.weight: 900

                    SequentialAnimation {
                        id: bump
                        NumberAnimation {
                            target: scoreText
                            property: "scale"
                            to: 1.25
                            duration: 90
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            target: scoreText
                            property: "scale"
                            to: 1
                            duration: 280
                            easing.type: Easing.OutBack
                        }
                    }
                }

                // the last change, rising and fading next to the score
                Text {
                    id: flash

                    readonly property real restY: scoreText.y + (scoreText.height - height) / 2

                    x: scoreText.x + scoreText.width + win.spacing * 0.3
                    y: restY
                    opacity: 0
                    color: card.teamColor
                    font.family: win.fontFamily
                    font.pixelSize: win.scoreSize * 0.45
                    font.weight: 900

                    ParallelAnimation {
                        id: flashAnim
                        NumberAnimation {
                            target: flash
                            property: "opacity"
                            from: 1
                            to: 0
                            duration: 1100
                            easing.type: Easing.InQuad
                        }
                        NumberAnimation {
                            target: flash
                            property: "y"
                            from: flash.restY
                            to: flash.restY - win.scoreSize * 0.5
                            duration: 1100
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}
