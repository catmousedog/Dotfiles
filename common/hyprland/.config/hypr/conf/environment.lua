-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- XDG / Session
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_MENU_PREFIX", "arch-")

-- Cursors
hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "24")

-- Qt apps (Dolphin) take palette, icons and style from qt6ct, whose config
-- ~/.local/bin/theme generates. Needs the qt6ct package.
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
