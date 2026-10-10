hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"))

-- TODO: replace with the laptop's real settings (its old hypr/local/*.lua)
-- See https://wiki.hypr.land/Configuring/Monitors/
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

-- a little more room between windows than the default (4 / 6)
hl.config({
    general = {
        gaps_in = 6,
        gaps_out = 9,
    },
})
