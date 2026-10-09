-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
local vars = require("conf.variables")

-- XDG / Session
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Cursors, GTK gets the same in exec.lua
hl.env("XCURSOR_THEME", vars.cursorTheme)
hl.env("XCURSOR_SIZE", tostring(vars.cursorSize))
hl.env("HYPRCURSOR_SIZE", tostring(vars.cursorSize))
