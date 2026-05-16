#!/usr/bin/fish

set matrix 3
set num_workspaces (math "$matrix * $matrix")

# Convert any workspace id back into the primary monitor range
function normalize_workspace
    set -l wid $argv[1]

    # Hyprland workspaces start at 1
    math "(($wid - 1) % $num_workspaces) + 1"
end

# Get all windows
set clients (hyprctl clients -j)

# All hyprland dispatch commands appended
set -l hypr_disp "keyword animation "workspaces,1,$speed,almostLinear,fade""

# Move every window back to monitor 0 workspace range
echo $clients | jq -c '.[]' | while read -l client
    set addr (echo $client | jq -r '.address')
    set wid  (echo $client | jq '.workspace.id')

    # Skip invalid/special workspaces
    if test $wid -lt 1
        continue
    end

    set target (normalize_workspace $wid)

    set hypr_disp "$hypr_disp dispatch movetoworkspacesilent $target,address:$addr ; "
end

# Dispatch full command
hyprctl --batch $hypr_disp

# Focus monitor 0
hyprctl dispatch focusmonitor 0

# Go to center workspace (5 in a 3x3)
hyprctl dispatch workspace 5