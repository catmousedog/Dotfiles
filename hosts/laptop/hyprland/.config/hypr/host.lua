hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"))

-- laptop screen
hl.monitor({
    output = "eDP-1",
    mode = "preferred",
    position = "0x0",
    scale = 1,
})

-- usb-c screen (above)
hl.monitor({
    output = "DP-1",
    mode = "preferred",
    position = "auto-center-up",
    scale = 1,
})

-- HDMI screen (mirror)
hl.monitor({
    output = "HDMI-A-1",
    mode = "preferred",
    position = "auto-center-up",
    scale = 1,
    mirror = "eDP-1",
})

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
