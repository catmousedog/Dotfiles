#!/usr/bin/fish
# Shared config + helpers for watrix / watrix-init / watrix-reset / watrix-watch.
# Source with: source (dirname (status --current-filename))/watrix-common.fish

set -g matrix 3
set -g num_workspaces (math "$matrix * $matrix")
set -g center_id (math "($num_workspaces - 1) / 2")  # middle cell, e.g. 4 for 3x3
set -g clamp true
set -g speed 2

# Monitor NAMES, sorted for a consistent logical order: built-in laptop
# panels (eDP-*) always come first, everything else alphabetically after.
# Portable across machines — on a desktop with no eDP output this is just a
# plain alphabetical sort, same as before.
function get_monitors
    hyprctl monitors -j | jq -r 'sort_by([(.name | startswith("eDP") | not), .name]) | .[].name'
end

# Convert a logical (0-based) workspace id on monitor $mon (0-based) to the actual workspace id
function logical_to_actual -a id mon
    math "$id + $mon * $num_workspaces + 1"
end

# Convert any actual workspace id back into the [1, num_workspaces] range (monitor 0's range)
function normalize_workspace -a wid
    math "(($wid - 1) % $num_workspaces) + 1"
end

# Assign the workspace keyword rules for every monitor and focus each monitor's
# center workspace, ending focused back on the first (primary) monitor.
# This is the actual "make everything line up" step — used by both init and reset.
function watrix_sync
    set -l monitors (get_monitors)
    set -l hypr_disp ""

    for i in (seq 1 (count $monitors))
        set -l mon_name $monitors[$i]
        set -l mon (math "$i - 1")

        for id in (seq 0 (math "$num_workspaces - 1"))
            set -l mid (logical_to_actual $id $mon)
            if test $id -eq $center_id
                hyprctl eval "hl.workspace_rule({ workspace = '$mid', monitor = '$mon_name', default = true })"
            else
                hyprctl eval "hl.workspace_rule({ workspace = '$mid', monitor = '$mon_name' })"
            end
        end

        set -l center (logical_to_actual $center_id $mon)
        set hypr_disp "$hypr_disp eval hl.dispatch(hl.dsp.focus({ monitor = '$mon_name' })) ; eval hl.dispatch(hl.dsp.focus({ workspace = '$center' })) ; "
    end

    if test (count $monitors) -gt 0
        set hypr_disp "$hypr_disp eval hl.dispatch(hl.dsp.focus({ monitor = '$monitors[1]' })) ; "
    end

    hyprctl --batch $hypr_disp
end
