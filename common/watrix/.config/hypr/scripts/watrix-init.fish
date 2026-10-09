#!/usr/bin/fish
# watrix-init.fish          rules + focus the center workspace (startup)
# watrix-init.fish --rules  only re-apply the rules (config reload)

source (dirname (status --current-filename))/watrix-common.fish

if contains -- --rules $argv
    watrix_rules
else
    watrix_sync
end
