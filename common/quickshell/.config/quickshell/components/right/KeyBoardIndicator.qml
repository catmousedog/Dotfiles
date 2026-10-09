// KeyBoardIndicator.qml

import QtQuick
import Quickshell
import qs.services
import qs.components.generic

Bartext {
    text: {
        if (KeyboardService.layout.includes("Belgian"))
            return "BE";
        if (KeyboardService.layout.includes("English (US)"))
            return "US";
        if (KeyboardService.layout.includes("Russian"))
            return "RU";
        return KeyboardService.layout;
    }
}
