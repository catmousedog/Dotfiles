// Bar.qml

import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.services
import qs.config
import qs.components

PanelWindow {
    required property var modelData
    screen: modelData

    anchors {
        top: true
    }

    margins.top: Config.barMarginTop

    color: "transparent"

    implicitHeight: screen.height * Config.barHeightFactor
    implicitWidth: screen.width - Config.barMarginSide * 2

    /* ========================================================================================== */
    /*                                            Clock                                           */
    /* ========================================================================================== */
    Barbox {
        implicitHeight: parent.height
        implicitWidth: parent.width * Config.clockBarWidthFactor
        anchors.centerIn: parent

        Bartext {
            anchors.centerIn: parent
            text: TimeService.format(Config.clockFormat)
        }
    }

    /* ========================================================================================== */
    /*                                          Workspace                                         */
    /* ========================================================================================== */

    RowLayout {

        implicitHeight: parent.height
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        layoutDirection: Qt.LeftToRight

        Barbox {
            implicitHeight: parent.height
            implicitWidth: parent.height * 1.1

            Bartext {
                anchors.centerIn: parent
                text: WorkspaceService.activeWorkspace?.name ?? ""
            }
        }

        Barbox {
            id: test
            implicitHeight: parent.height
            implicitWidth: {
                let len = TrayService.items.length;
                if (len == 0) {
                    return 0;
                } else {
                    return len * 100;
                }
            }

            Bartext {
                function trayStatusText() {
                    let len = TrayService.items.length;
                    text = "";
                    for (let i = 0; i < len; i++) {
                        const item = TrayService.items[i];
                        text += item.id;
                    }
                    return text;
                }

                anchors.centerIn: parent
                text: trayStatusText()
            }
        }
    }

    /* ========================================================================================== */
    /*                                        Control Panel                                       */
    /* ========================================================================================== */

    /* ---------------------------------------- Sound Bar --------------------------------------- */
    Barbox {
        implicitHeight: parent.height
        implicitWidth: parent.width * Config.soundBarWidthFactor
        anchors.right: parent.right

        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: Config.barMarginSide
            layoutDirection: Qt.RightToLeft
            spacing: 10

            Bartext {
                WheelHandler {
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    onWheel: event => {
                        const delta = event.angleDelta.y > 0 ? 1 : -1;
                        var volume = SoundService.getVolume();
                        volume = Math.min(1, Math.max(0, volume + delta * Config.soundScrollInterval / 100));
                        SoundService.setVolume(volume);
                    }
                }

                function soundText() {
                    var volume = Math.round(SoundService.getVolume() * 100);
                    var volumeText = volume.toString().padStart(2, " ");

                    var deviceIcon = SoundService.icon;
                    var iconText = ""; // default icon
                    if (deviceIcon == "audio-card-analog") {
                        iconText = "";
                    } else if (deviceIcon == "audio-headset") {
                        iconText = "󱡏";
                    } else if (deviceIcon == "audio-card") {
                        iconText = "";
                    }

                    return iconText + " " + volumeText + "%";
                }
                text: soundText()
            }

            Bartext {
                // font.pointSize: Config.barFontSizeSmall
                text: BluetoothService.statusText()
            }
        }
    }
}
