# Host specific config and secrets go in conf.d/*.fish, which fish loads
# automatically before this file (see hosts/<host>/... and .gitignore).

fish_add_path ~/.local/bin

if status is-interactive
    set fish_greeting
    abbr -a wlc wl-copy
end
