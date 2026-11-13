// BatteryIndicator.qml
// Click: battery details and the power profile

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.config
import qs.services
import qs.components.generic

Loader {
    active: BatteryService.hasBattery
    // hidden, not just empty, so the row doesn't keep spacing for it on the desktop
    visible: active

    sourceComponent: IconText {
        id: root

        icon: getIcon()
        text: getText()
        color: getColor()

        iconSize: ConfigService.get("right.battery.iconSize")
        iconYOffset: ConfigService.get("right.battery.iconYOffset")
        spacing: ConfigService.get("right.battery.spacing")

        readonly property var dischargingIcons: ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
        // bolt in the battery: the only charging icon as narrow as the others
        readonly property string chargingIcon: "󰂄"
        icons: [...dischargingIcons, chargingIcon, "󰂑"]

        readonly property bool low: BatteryService.percentage <= .1
        readonly property real fontSize: ConfigService.get("common.font.size")

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: popup.toggle()
        }

        Popup {
            id: popup
            anchorItem: root
            minWidth: 250

            /* ------------------------------------- Charge ------------------------------------- */

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                Layout.topMargin: 2
                spacing: 12

                Icon {
                    text: root.getIcon()
                    font.pointSize: root.fontSize * 2.4
                    color: root.accentColor()
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Bartext {
                        text: Math.round(BatteryService.percentage * 100) + "%"
                        font.pointSize: root.fontSize * 1.6
                    }

                    Bartext {
                        text: root.stateLine()
                        color: Theme.subtle
                        font.weight: Font.Medium
                    }
                }
            }

            Rectangle {
                id: track
                Layout.fillWidth: true
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                Layout.topMargin: 6
                Layout.bottomMargin: 6
                implicitHeight: 6
                radius: height / 2
                color: Theme.surface

                Rectangle {
                    width: Math.max(height, track.width * BatteryService.percentage)
                    height: parent.height
                    radius: height / 2
                    color: root.accentColor()

                    Behavior on width {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            MenuRow {
                visible: BatteryService.rate > 0.1 && (BatteryService.charging || BatteryService.discharging)
                clickable: false
                icon: "󱐋"
                text: BatteryService.charging ? "Charging at" : "Power draw"
                detail: BatteryService.rate.toFixed(1) + " W"
            }

            MenuRow {
                visible: BatteryService.health >= 0
                clickable: false
                icon: "󰣐"
                text: "Health"
                detail: Math.round(BatteryService.health) + "%"
            }

            /* ---------------------------------- Power profile --------------------------------- */

            Separator {}

            SectionHeader {
                text: "Power profile"
                detail: BatteryService.currentProfile.name
                detailColor: Theme.getColor(BatteryService.currentProfile.color)
            }

            Segmented {
                options: BatteryService.profiles
                current: BatteryService.profile
                onSelected: value => BatteryService.setProfile(value)
            }
        }

        function getIcon() {
            if (BatteryService.discharging)
                return dischargingIcons[Math.floor(BatteryService.percentage * 10)];
            if (BatteryService.charging)
                return chargingIcon;
            if (BatteryService.full)
                return "󰁹";
            return "󰂑";
        }

        // time left is only in the popup
        function getText() {
            return Math.round(BatteryService.percentage * 100) + "%";
        }

        function getColor() {
            return low ? Theme.red : null; // null: default color
        }

        // the big icon and the charge bar
        function accentColor() {
            if (low)
                return Theme.red;
            if (BatteryService.charging || BatteryService.full)
                return Theme.green;
            return Theme.accent;
        }

        function stateLine() {
            const time = BatteryService.timeLeft > 0 ? BatteryService.formatTime(BatteryService.timeLeft, false) : "";
            if (BatteryService.discharging)
                return time ? `${time} left` : "On battery";
            if (BatteryService.charging)
                return time ? `Charging, full in ${time}` : "Charging";
            return BatteryService.stateName;
        }
    }
}
