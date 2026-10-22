-- See https://wiki.hypr.land/Configuring/Basics/Binds/
local vars = require("conf.variables")
local mainMod = vars.mainMod

-- Hyprland
hl.bind(mainMod .. " + C", hl.dsp.window.close())
-- Toggle floating; a window that becomes floating takes half the monitor, centered
hl.bind(mainMod .. " + V", function()
    local window = hl.get_active_window()
    if not window then
        return
    end
    local monitor = not window.floating and window.monitor
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    if monitor then
        hl.dispatch(hl.dsp.window.resize({ x = monitor.width / 2, y = monitor.height / 2 }))
        hl.dispatch(hl.dsp.window.center())
    end
end)
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

-- Apps
hl.bind(mainMod .. " + return", hl.dsp.exec_cmd(vars.terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(vars.fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(vars.menu))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd(vars.clipboard))

-- Watrix reset
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd("~/.config/hypr/scripts/watrix-reset.fish"))
-- Watrix overview, see OverviewService.qml in quickshell
hl.bind(mainMod .. " + W", hl.dsp.global("quickshell:overview"))

-- Region screenshot, see ScreenshotService.qml in quickshell
hl.bind(mainMod .. " + H", hl.dsp.global("quickshell:screenshot"))
hl.bind("PRINT", hl.dsp.global("quickshell:screenshot"))

-- Theme selection
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("~/.local/bin/theme toggle"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("~/.local/bin/theme menu"))

-- Notifications
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("dunstctl close"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("dunstctl history-pop"))

-- Cycle windows and raise the newly focused one
hl.bind(mainMod .. " + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
end)

-- Move focus
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Resize active window (repeats while held)
hl.bind("ALT + " .. mainMod .. " + right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
hl.bind("ALT + " .. mainMod .. " + left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind("ALT + " .. mainMod .. " + up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind("ALT + " .. mainMod .. " + down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })

-- Move windows. Fullscreen (or maximized) windows can't move, so they leave it
-- for the move and get the same mode back where they land.
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind("SHIFT + " .. mainMod .. " + " .. dir, function()
        local window = hl.get_active_window()
        if not window then
            return
        end
        local fs = window.fullscreen or 0
        local mode = fs >= 2 and "fullscreen" or fs == 1 and "maximized" or nil
        if mode then
            hl.dispatch(hl.dsp.window.fullscreen({ mode = mode, action = "unset" }))
        end
        hl.dispatch(hl.dsp.window.move({ direction = dir }))
        if mode then
            hl.dispatch(hl.dsp.window.fullscreen({ mode = mode, action = "set" }))
        end
    end)
end
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Switch workspaces in the watrix grid
hl.bind("CTRL + " .. mainMod .. " + left", hl.dsp.exec_cmd("~/.config/hypr/scripts/watrix.fish workspace left"))
hl.bind("CTRL + " .. mainMod .. " + right", hl.dsp.exec_cmd("~/.config/hypr/scripts/watrix.fish workspace right"))
hl.bind("CTRL + " .. mainMod .. " + up", hl.dsp.exec_cmd("~/.config/hypr/scripts/watrix.fish workspace up"))
hl.bind("CTRL + " .. mainMod .. " + down", hl.dsp.exec_cmd("~/.config/hypr/scripts/watrix.fish workspace down"))

local kpWorkspaces = {
    KP_End = 7, KP_Down = 8, KP_Next = 9,
    KP_Left = 4, KP_Begin = 5, KP_Right = 6,
    KP_Home = 1, KP_Up = 2, KP_Prior = 3,
}
for key, ws in pairs(kpWorkspaces) do
    hl.bind("CTRL + " .. mainMod .. " + " .. key, hl.dsp.focus({ workspace = ws }))
end

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- The bar never sees modifiers (layer surfaces don't get keyboard focus), so tell
-- it shift is held right before a scroll reaches it. Non-consuming: apps still get it.
hl.bind("SHIFT + mouse_down", hl.dsp.global("quickshell:shiftScroll"), { non_consuming = true })
hl.bind("SHIFT + mouse_up", hl.dsp.global("quickshell:shiftScroll"), { non_consuming = true })

-- Move active window through the watrix grid
hl.bind("CTRL + SHIFT + " .. mainMod .. " + left", hl.dsp.exec_cmd("~/.config/hypr/scripts/watrix.fish movetoworkspace left"))
hl.bind("CTRL + SHIFT + " .. mainMod .. " + right", hl.dsp.exec_cmd("~/.config/hypr/scripts/watrix.fish movetoworkspace right"))
hl.bind("CTRL + SHIFT + " .. mainMod .. " + up", hl.dsp.exec_cmd("~/.config/hypr/scripts/watrix.fish movetoworkspace up"))
hl.bind("CTRL + SHIFT + " .. mainMod .. " + down", hl.dsp.exec_cmd("~/.config/hypr/scripts/watrix.fish movetoworkspace down"))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
-- Toggle: a window in the scratchpad goes to the workspace underneath it
hl.bind(mainMod .. " + SHIFT + S", function()
    local win = hl.get_active_window()
    local target = "special:magic"
    if win and win.workspace and win.workspace.special then
        target = hl.get_active_workspace()
    end
    hl.dispatch(hl.dsp.window.move({ workspace = target }))
end)

-- Laptop multimedia keys for volume / brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Media keys (requires playerctl)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl --player=spotify_player,spotify,%any next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl --player=spotify_player,spotify,%any play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl --player=spotify_player,spotify,%any play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl --player=spotify_player,spotify,%any previous"), { locked = true })
