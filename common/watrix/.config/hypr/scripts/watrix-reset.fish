#!/usr/bin/fish

source (dirname (status --current-filename))/watrix-common.fish

# Rules first, so workspaces created by the moves below land on monitor 0
watrix_rules

# Move every window back into monitor 0's workspace range, keeping its place
# in the grid (e.g. workspace 12, top right of monitor 1, becomes 3)
set clients (hyprctl clients -j)
hyprctl eval "hl.animation({ leaf = 'workspaces', enabled = true, speed = $speed, bezier = 'almostLinear', style = 'fade' })"
set -l hypr_disp ""

echo $clients | jq -c '.[]' | while read -l client
    set addr (echo $client | jq -r '.address')
    set wid  (echo $client | jq '.workspace.id')

    # Skip invalid/special workspaces
    if test $wid -lt 1
        continue
    end

    set target (normalize_workspace $wid)
    set hypr_disp "$hypr_disp eval hl.dispatch(hl.dsp.window.move({ workspace = '$target', silent = true, window = 'address:$addr' })) ; "
end

hyprctl --batch $hypr_disp

# Every monitor back to its center workspace, ending on monitor 0
watrix_center
