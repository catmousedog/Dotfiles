// shell.qml

import Quickshell
import QtQuick
import qs.components

Variants {
    model: Quickshell.screens

    delegate: StatusBar {}
}
