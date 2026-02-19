// Bar.qml

import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.services
import qs.components

PanelWindow {
    required property var modelData
    screen: modelData

    anchors {
        top: true
    }

    margins.top: ConfigService.get("common.layout.marginTop")

    color: "transparent"

    implicitHeight: screen.height * ConfigService.get("common.layout.heightFactor")
    implicitWidth: screen.width - 2 * ConfigService.get("common.layout.marginSide")

    /* ========================================================================================== */
    /*                                            Clock                                           */
    /* ========================================================================================== */
    Barbox {
        implicitHeight: parent.height
        implicitWidth: parent.width * ConfigService.get("center.clock.widthFactor")
        anchors.centerIn: parent

        Bartext {
            anchors.centerIn: parent
            text: TimeService.format(ConfigService.get("center.clock.format"))
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
        implicitWidth: parent.width * ConfigService.get("right.audio.widthFactor")
        anchors.right: parent.right

        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: ConfigService.get("common.layout.marginSide")
            layoutDirection: Qt.RightToLeft
            spacing: 10

            Bartext {
                WheelHandler {
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    onWheel: event => {
                        const delta = event.angleDelta.y > 0 ? 1 : -1;
                        var volume = SoundService.getVolume();
                        volume = Math.min(1, Math.max(0, volume + delta * ConfigService.get("right.audio.scrollInterval") / 100));
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
