#!/usr/bin/fish

set matrix 3
set num_workspaces (math "$matrix * $matrix")

function get_num_monitors
    hyprctl monitors -j | jq 'length'
end

# Loop over all monitors
for mon in (seq 0 (math (get_num_monitors) - 1))
    # Loop over logical ids [0, 9[
    for id in (seq 0 (math "$num_workspaces - 1"))
        set -l mid (math "$id + $mon * $num_workspaces + 1")

        if test $id -eq 4 # Set middle 
            # hyprctl keyword workspace "$mid, monitor:$mon, default:true"
            # hyprctl dispatch workspace "$mid"
            echo "middle $mid $mon"
        else
            # hyprctl keyword workspace "$mid, monitor:$mon"
            echo "$mid $mon"
        end
    end
end
