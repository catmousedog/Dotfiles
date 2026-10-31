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

-- Quiz scoreboard (temporary), see hosts/laptop/scoreboard
-- Keycodes 10-13 are the 1-4 keys: on the Belgian layout they only type digits with shift
for i = 1, 4 do
    hl.bind("SUPER + ALT + code:" .. (9 + i), hl.dsp.global("quickshell:scoreUp" .. i))
    hl.bind("SUPER + ALT + SHIFT + code:" .. (9 + i), hl.dsp.global("quickshell:scoreDown" .. i))
end
hl.bind("SUPER + ALT + Z", hl.dsp.global("quickshell:scoreUndo"))
hl.bind("SUPER + ALT + S", hl.dsp.global("quickshell:scoreToggle"))
