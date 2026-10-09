-- See https://wiki.hypr.land/Configuring/Basics/Binds/
local vars = require("conf/variables")
local mainMod = vars.mainMod

-- Main binds
hl.bind(mainMod .. " + return", hl.dsp.exec_cmd(vars.terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(vars.fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(vars.menu))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd("~/.config/hypr/scripts/watrix-reset.fish"))
hl.bind(mainMod .. " + H", hl.dsp.exec_cmd('grim -g "$(slurp)" - | satty --filename -'))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("~/.config/hypr/scripts/theme-toggle.sh"))

-- cyclenext + alterzorder top combo (verify hl.dsp.window naming against
-- the wiki for your installed version — this dispatcher was renamed
-- more than once during the hyprlang -> lua migration)
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
hl.bind("ALT + " .. mainMod .. " + right", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), { repeating = true })
hl.bind("ALT + " .. mainMod .. " + left", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true })
hl.bind("ALT + " .. mainMod .. " + up", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
hl.bind("ALT + " .. mainMod .. " + down", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), { repeating = true })

-- Move windows
hl.bind("SHIFT + " .. mainMod .. " + right", hl.dsp.window.move({ direction = "right" }))
hl.bind("SHIFT + " .. mainMod .. " + left", hl.dsp.window.move({ direction = "left" }))
hl.bind("SHIFT + " .. mainMod .. " + up", hl.dsp.window.move({ direction = "up" }))
hl.bind("SHIFT + " .. mainMod .. " + down", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Switch workspaces (your custom script-driven directional switching)
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

-- Move active window to a workspace (your custom script-driven version)
hl.bind("CTRL + SHIFT + " .. mainMod .. " + left", hl.dsp.exec_cmd("~/.config/hypr/scripts/watrix.fish movetoworkspace left"))
hl.bind("CTRL + SHIFT + " .. mainMod .. " + right", hl.dsp.exec_cmd("~/.config/hypr/scripts/watrix.fish movetoworkspace right"))
hl.bind("CTRL + SHIFT + " .. mainMod .. " + up", hl.dsp.exec_cmd("~/.config/hypr/scripts/watrix.fish movetoworkspace up"))
hl.bind("CTRL + SHIFT + " .. mainMod .. " + down", hl.dsp.exec_cmd("~/.config/hypr/scripts/watrix.fish movetoworkspace down"))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Laptop multimedia keys for volume / brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Media keys (requires playerctl)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl --player=spotify,%any next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl --player=spotify,%any play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl --player=spotify,%any play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl --player=spotify,%any previous"), { locked = true })
