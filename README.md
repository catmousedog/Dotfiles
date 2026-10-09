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
| bluetooth quick-connect | `quickshell/.config/quickshell/host/bluetooth_devices.json` |
| fish                    | `fish/.config/fish/conf.d/*.fish`                       |

**Secrets** (tokens, API keys) go in a file named `secrets.*` (e.g.
`fish/.config/fish/conf.d/secrets.fish`). It is gitignored but still stowed.

## Setup

```sh
git clone <repo> ~/Dotfiles/dotfiles && cd ~/Dotfiles/dotfiles
echo desktop > .host           # or laptop; picks hosts/<host>/
sudo pacman -S --needed - < hosts/desktop/pkglist.txt
yay -S --needed - < hosts/desktop/pkglist-aur.txt
make                           # stow everything + generate the theme
make system                    # copy system/ files into / (sudo)
```

Other targets: `make unlink`, `make pkglist` (snapshot installed packages),
`make pkgdiff` (compare installed packages with the snapshot).

After adding a **new file** to a package, run `make` again to link it.

## Theme

Colors come from one place: `common/themes/.config/themes/palettes/<flavor>.json`.
`theme` (in `~/.local/bin`) renders the palette for every program into
`~/.local/state/theme/current/` and reloads what it can:

```sh
theme toggle      # mocha <-> latte   (also SUPER+T)
theme latte       # pick one
theme init        # regenerate the current flavor (after editing a palette)
```

Hyprland, kitty, rofi, quickshell and hyprlock read the generated files; GTK and
VS Code follow the system `color-scheme`. To add a flavor, drop a new palette
JSON next to the others. Run `python preview.py` to render the palette PNGs.

## Adding a machine

```sh
cp -r hosts/laptop hosts/<new>   # then edit the files listed above
echo <new> > .host && make
```
