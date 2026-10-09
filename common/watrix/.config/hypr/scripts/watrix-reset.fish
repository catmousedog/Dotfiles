#!/usr/bin/fish

source (dirname (status --current-filename))/watrix-common.fish

# Move every window back into monitor 0's workspace range
set clients (hyprctl clients -j)
set -l hypr_disp "keyword animation workspaces,1,$speed,almostLinear,fade ; "

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

hyprctl --batch $hypr_disp

# Re-sync every monitor to its correct workspace range/center (not just primary)
watrix_sync
