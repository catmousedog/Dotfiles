-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Runs once, at Hyprland startup (old exec-once)
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("quickshell")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("dunst")
    hl.exec_cmd("awww-daemon & sleep 0.1 && awww img ~/.config/backgrounds/background.png")
    hl.exec_cmd("~/.config/hypr/watrix-init.fish")
end)

-- Runs every time the config (re)loads (old plain exec)
hl.exec_cmd("~/.config/hypr/watrix-init.fish")
