-- # See https://wiki.hypr.land/Configuring/Monitors/
hl.monitor({
    output = "DP-2",
    mode = "3440x1440@174.962006",
    position = "0x0",
    scale = 1,
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
    input = {
        kb_layout = "us,ru",
        kb_variant = ",phonetic_YAZHERTY",
        kb_options = "grp:win_space_toggle",
        sensitivity = -0.8,
    },
})

-- appearance.lua --
hl.config({
    general = {
        border_size = 3
	}
})
