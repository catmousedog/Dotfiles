hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"))

-- Screens: what each external one does (extend / mirror / off) is picked with
-- SUPER+P or the bar and remembered per connector, see conf/display.lua. With two
-- external screens extended, give one of them its own position here.
local display = require("conf.display")

display.screen({
    output = "eDP-1",
    internal = true, -- always on, what mirror copies
    mode = "preferred",
    position = "0x0",
    scale = 1,
})

display.screen({
    output = "DP-1",
    label = "USB-C",
    mode = "preferred",
    position = "auto-center-up",
    scale = 1,
})

display.screen({
    output = "HDMI-A-1",
    label = "HDMI",
    mode = "preferred",
    position = "auto-center-up",
    scale = 1,
})

display.apply()

-- appearance.lua
hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 9
    },
})

-- BE, US, RU keyboards
hl.config({
    input = {
        kb_layout = "be,us,ru",
        kb_variant = ",,phonetic_YAZHERTY",
        kb_options = "grp:win_space_toggle"
    },
})
