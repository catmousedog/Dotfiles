# dotfiles

Arch Linux + Hyprland config for all my machines, managed with GNU stow.

```
common/           stow packages shared by every machine
hosts/<host>/     stow packages for one machine only, plus its pkglist*.txt
system/           files outside $HOME (copied with `make system`, not symlinked)
```

Every directory in `common/` and `hosts/<host>/` is a stow package whose
contents mirror `$HOME`. Packages are stowed with `--no-folding`, so only files
are linked, never whole directories. This means `common/hyprland` and
`hosts/desktop/hyprland` can both put files in `~/.config/hypr`, and files that
programs create themselves stay out of the repo.

## Machine-specific config

Anything that differs per machine lives in `hosts/<host>/` and is committed:

| what                    | file                                                    |
| ----------------------- | ------------------------------------------------------- |
| monitors, keyboard, ... | `hyprland/.config/hypr/host.lua` (loaded last)          |
| idle / lock / suspend   | `hypridle/.config/hypr/hypridle.conf`                   |
| status bar overrides    | `quickshell/.config/quickshell/host/config.json`        |
| fish                    | `fish/.config/fish/conf.d/*.fish`                       |

**Secrets** (tokens, API keys) go in a file named `secrets.*` (e.g.
`fish/.config/fish/conf.d/secrets.fish`). It is gitignored but still stowed.

## Setup

```sh
git clone <repo> ~/Dotfiles && cd ~/Dotfiles
echo desktop > .host           # or laptop; picks hosts/<host>/
sudo pacman -S --needed - < hosts/desktop/pkglist.txt
yay -S --needed - < hosts/desktop/pkglist-aur.txt
make                           # stow everything + generate the theme
make system                    # copy system/ files into / (sudo)
```

## Day to day

| situation                                         | run                  |
| ------------------------------------------------- | -------------------- |
| added, deleted, renamed or moved a file/package   | `make`               |
| only edited an existing file                      | nothing (it's a link) |
| edited something in `system/`                     | `make system`        |
| edited a palette                                  | `theme init`         |
| remove every link from `$HOME`                    | `make unlink`        |
| installed/removed packages                        | `make pkglist`       |

`make` re-stows everything and prunes links whose file no longer exists in the
repo. If stow refuses because a real file is in the way, move that file aside
(or merge it into the repo) and run `make` again.

`system/` is copied instead of symlinked on purpose: greetd runs as root and
its config decides which command runs as which user. A symlink into this repo
would let anything running as my user rewrite that, i.e. become root.

## Theme

Colors come from one place: `common/themes/.config/themes/palettes/<theme>-<dark|light>.json`.
Each palette has the theme's own colors under their own names (`colors`) and a
`roles` map that picks which of them each part of the desktop uses: `bg`, `bg_alt`,
`surface*`, `fg`, `accent` (borders, selection, folders), `accent2` (start of the
border gradient) and the terminal colors. Everything reads roles only, so a theme
decides its own look; the list of roles is `ROLES` in the `theme` script.
`theme` (in `~/.local/bin`) renders the palette for every program into
`~/.local/state/theme/current/` and reloads what it can:

```sh
theme toggle      # dark <-> light                     (also SUPER+T)
theme menu        # pick a theme with rofi            (also SUPER+SHIFT+T)
theme rose-pine   # or by name, keeps dark/light; `theme list` shows them all
theme init        # regenerate the current flavor (after editing a palette)
```

Hyprland, kitty, rofi, quickshell, dunst, eza, yazi and hyprlock (laptop only) read
the generated files. GTK apps (Thunar, file dialogs) get a recolored adw-gtk3
theme per flavor and switch live. VS Code gets its color theme written directly. Thunar's folder icons take the theme's accent color. For a wallpaper per theme, put
`<theme>-<dark|light>.png` (or `<theme>.png`) in `~/.config/backgrounds/`; otherwise
`background.png` is used. Themes: Catppuccin and Rosé Pine. To add one, drop `<name>-dark.json`
and `<name>-light.json` next to the others with the same roles. Run
`python preview.py` to render the palette PNGs (every role and where it comes from).

## App launcher

SUPER+R shows only the apps listed in `common/rofi/.config/rofi/apps.txt`
(desktop entry ids; Steam games and tool entries stay out). Edit the list to add
one. The Run tab (shift+arrow) still runs any command.

## Status bar

| item       | scroll            | left click             | right click     |
| ---------- | ----------------- | ---------------------- | --------------- |
| workspace  | move in the grid (shift: sideways) |       |                 |
| volume     | volume            | pick output device     | mute            |
| bluetooth  |                   | connect paired devices | power on / off  |
| battery    |                   | cycle power profile    |                 |

Devices are paired once with `bluetoothctl` (`scan on`, `pair <mac>`, `trust <mac>`);
after that they show up in the bluetooth menu. Output devices can get nicer
names with `right.audio.names` in the host's `config.json`, e.g.
`{"right": {"audio": {"names": {"JBL": "Speaker"}}}}` (part of the device name -> label).
On the laptop the volume menu also lists HDMI card profiles (`right.audio.profiles`),
which is what `pactl set-card-profile` did before.

## Adding a machine

```sh
cp -r hosts/laptop hosts/<new>   # then edit the files listed above
echo <new> > .host && make
```
