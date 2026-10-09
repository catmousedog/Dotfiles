#!/usr/bin/env python3
"""rofi script mode: show only the apps listed in ~/.config/rofi/apps.txt.

rofi's drun mode lists every desktop entry (Steam games, Avahi, Qt test tools...)
and can't filter by name, so this mode reads an allowlist instead.
"""

import os
import subprocess
import sys
from pathlib import Path

HOME = Path.home()
CONFIG = Path(os.environ.get("XDG_CONFIG_HOME", HOME / ".config"))
DATA_HOME = Path(os.environ.get("XDG_DATA_HOME", HOME / ".local/share"))
DATA_DIRS = os.environ.get("XDG_DATA_DIRS", "/usr/local/share:/usr/share").split(":")
APP_DIRS = [DATA_HOME / "applications"] + [Path(d) / "applications" for d in DATA_DIRS if d]


def entry(app_id):
    """Name and icon from the first matching .desktop file, like the XDG lookup order."""
    for d in APP_DIRS:
        path = d / f"{app_id}.desktop"
        if not path.is_file():
            continue
        fields, section = {}, None
        for line in path.read_text(encoding="utf-8-sig", errors="replace").splitlines():
            line = line.strip()
            if line.startswith("["):
                section = line
            elif section == "[Desktop Entry]" and "=" in line:
                key, value = line.split("=", 1)
                fields.setdefault(key.strip(), value.strip())
        return fields.get("Name", app_id), fields.get("Icon", "")
    return None


def main():
    if os.environ.get("ROFI_RETV") == "1":
        # an entry was picked: launch it detached so it outlives rofi
        subprocess.Popen(["gtk-launch", os.environ["ROFI_INFO"]], start_new_session=True,
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return
    print("\0no-custom\x1ftrue")
    for line in (CONFIG / "rofi/apps.txt").read_text().splitlines():
        words = line.split("#", 1)[0].split()
        if not words:
            continue
        app_id, options = words[0], dict(w.split("=", 1) for w in words[1:] if "=" in w)
        found = entry(app_id)
        if found:
            name, icon = found
            icon = options.get("icon", icon)
            print(f"{name}\0icon\x1f{icon}\x1finfo\x1f{app_id}")


if __name__ == "__main__":
    sys.exit(main())
