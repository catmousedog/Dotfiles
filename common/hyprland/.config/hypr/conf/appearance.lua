-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/

-- NOTE: your original col.* values referenced $blue/$red/$mauve from
-- ~/.config/themes/theme.conf, which wasn't included in what you gave me.
-- Replace these placeholders with your real theme colors (or require()
-- a theme.lua module that returns them).
local blue = "rgba(89b4faee)"
local red = "rgba(f38ba8ee)"
local mauve = "rgba(cba6f7aa)"

hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 6,
        border_size = 2,
        col = {
            active_border = { colors = { blue, red }, angle = 0 },
            inactive_border = mauve,
            nogroup_border = red,
            nogroup_border_active = blue,
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 20,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 0.8,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a, -- was rgba(1a1a1aee); Lua form is 0xAARRGGBB
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },
    animations = {
        enabled = true,
    },
})

-- Curves, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear", { type = "bezier", points = { {0, 0}, {1, 1} } })
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5}, {0.75, 1} } })
hl.curve("quick", { type = "bezier", points = { {0.15, 0}, {0.1, 1} } })

-- Animations
hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- Window rules for float-on-open apps
hl.window_rule({ name = "matplotlib-float", match = { class = "Matplotlib" }, float = true })
hl.window_rule({ name = "python3-float", match = { class = "python3" }, float = true })
hl.window_rule({ name = "ds9-float", match = { class = "Ds9.tcl" }, float = true })

-- Layouts
hl.config({ dwindle = { preserve_split = true } })
hl.config({ master = { new_status = "master" } })

-- Misc
hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = true,
    },
})
