-- Programs used throughout the config
local M = {}
M.terminal = "kitty"
M.fileManager = "dolphin"
M.browser = "firefox"
M.menu = "rofi -show drun"
M.clipboard = "cliphist list | rofi -dmenu -p clipboard | cliphist decode | wl-copy"
M.mainMod = "SUPER"
return M
