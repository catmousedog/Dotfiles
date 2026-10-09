-- Entry point, loaded from $XDG_CONFIG_HOME/hypr/hyprland.lua
-- Mirrors your old conf.d split; require() replaces `source =`.
require("conf.environment")
require("conf.exec")
require("conf.appearance")
require("conf.input")
require("conf.keybinds")
require("conf.misc")

-- Your old hyprland.conf globbed ~/.config/hypr/local/*.conf for overrides.
-- require() doesn't support globbing, so list any local override files here
-- explicitly, e.g.:
require("local.hardware")
