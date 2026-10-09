-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- XDG / Session
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Cursors (Bibata was never installed, it's AUR only; Adwaita is what was shown)
hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("HYPRCURSOR_SIZE", "24")
