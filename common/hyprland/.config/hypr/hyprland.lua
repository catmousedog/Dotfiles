-- Entry point, loaded from $XDG_CONFIG_HOME/hypr/hyprland.lua
require("conf.environment")
require("conf.exec")
require("conf.appearance")
require("conf.input")
require("conf.keybinds")
require("conf.misc")

-- Machine specific settings (monitors, keyboard, ...), from hosts/<host>/hyprland.
-- Loaded last so it can override anything above.
local ok, err = pcall(require, "host")
if not ok then
    hl.notification.create({ text = "hypr: failed to load host.lua: " .. tostring(err), duration = 10000 })
end
