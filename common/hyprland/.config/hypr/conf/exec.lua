-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Runs once, at Hyprland startup
local vars = require("conf.variables")

hl.on("hyprland.start", function()
    -- GTK apps read the cursor from gsettings, not XCURSOR_THEME
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme " .. vars.cursorTheme)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size " .. vars.cursorSize)
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("quickshell")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("dunst")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("~/.config/hypr/scripts/watrix-init.fish")
    hl.exec_cmd("awww-daemon")
    -- wait for the daemon socket instead of guessing with a fixed sleep
    hl.exec_cmd("sh -c 'until awww query >/dev/null 2>&1; do sleep 0.05; done; ~/.local/bin/theme wallpaper'")
end)

-- Runs on every config (re)load: a reload drops the workspace rules watrix
-- creates at runtime, so re-apply them without moving any monitor.
hl.exec_cmd("~/.config/hypr/scripts/watrix-init.fish --rules")
