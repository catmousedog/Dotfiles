// Left.qml

import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.services
import qs.components.generic

RowLayout {

    implicitHeight: parent.height
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    layoutDirection: Qt.LeftToRight

    WorkspaceIndicator {}

    TrayIndicator {}
}
