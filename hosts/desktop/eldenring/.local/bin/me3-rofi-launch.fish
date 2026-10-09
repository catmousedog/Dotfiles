#!/usr/bin/env fish
# Pick a me3 profile and an executable via rofi, then launch.

set PROFILE_DIR "$HOME/.config/me3/profiles"
set GAME_DIR "$HOME/.local/share/Steam/steamapps/common/ELDEN RING/Game"

# 1. pick a profile (.me3 files only, recursively)
set profile (find "$PROFILE_DIR" -maxdepth 2 -name '*.me3' -printf '%f\n' | sort | rofi -dmenu -i -p "me3 profile")
if test -z "$profile"
    exit 0
end
set profile_path (find "$PROFILE_DIR" -maxdepth 2 -name "$profile" | head -n1)

# 3. launch
~/.local/bin/me3 launch --profile "$profile_path"
