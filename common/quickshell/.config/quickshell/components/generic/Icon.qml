// Icon.qml
// A Nerd Font glyph in the bar's font style.

import QtQuick
import qs.services

Bartext {
    // named explicitly: fontconfig's fallback can pick another font that has
    // something else at the same private-use codepoint (gsfonts, U+EFCF)
    font.family: ConfigService.get("common.font.iconFamily")
}
