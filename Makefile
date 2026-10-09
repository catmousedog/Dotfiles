SHELL := /bin/bash

# Which machine this checkout belongs to: a directory name under hosts/.
# Stored in the (gitignored) .host file, override with `make HOST=laptop ...`.
HOST ?= $(shell cat .host 2>/dev/null)

# Every directory in common/ and hosts/$(HOST)/ is a stow package.
COMMON_PKGS := $(notdir $(patsubst %/,%,$(wildcard common/*/)))
HOST_PKGS   := $(notdir $(patsubst %/,%,$(wildcard hosts/$(HOST)/*/)))

# --no-folding: always link individual files, never whole directories. This lets
# common/ and hosts/ packages share a directory (e.g. ~/.config/hypr) and keeps
# files that programs write themselves (fish_variables, ...) out of the repo.
STOW := stow --no-folding --target=$(HOME)

# Symlinks pointing into this repo look like ../../Dotfiles/dotfiles/common/...
REPO_LINK := */$(notdir $(patsubst %/,%,$(dir $(CURDIR))))/$(notdir $(CURDIR))/*

.PHONY: install link unlink prune system theme pkglist pkgdiff check

install: link theme

check:
	@test -n "$(HOST)" || { echo "No host set: echo <name> > .host  (one of: $(notdir $(wildcard hosts/*)))"; exit 1; }
	@test -d hosts/$(HOST) || { echo "hosts/$(HOST) does not exist"; exit 1; }

# Create/refresh all symlinks in $HOME, and drop links to files that are gone
link: check prune
	$(STOW) --dir=common --restow $(COMMON_PKGS)
	$(STOW) --dir=hosts/$(HOST) --restow $(HOST_PKGS)

# Remove all symlinks from $HOME
unlink: check
	$(STOW) --dir=common --delete $(COMMON_PKGS)
	$(STOW) --dir=hosts/$(HOST) --delete $(HOST_PKGS)

# Remove symlinks into this repo whose target no longer exists (a file was
# deleted, renamed or moved between packages). Stow can't do this itself: it
# only looks at files that still exist in the package.
prune:
	@find $(HOME)/.config $(HOME)/.local -xtype l -lname '$(REPO_LINK)' -print -delete 2>/dev/null || true

# Files outside $HOME are copied, not symlinked: root-owned services (greetd)
# should not depend on files inside a user's private home directory.
system:
	cd system && find . -type f -path './*/*' | while read -r f; do \
		dest="/$${f#./*/}"; \
		echo "install $$f -> $$dest"; \
		sudo install -Dm644 "$$f" "$$dest"; \
	done

# Generate the theme files and apply the current (or default) theme
theme:
	common/themes/.local/bin/theme init

# Snapshot explicitly installed packages for this host
pkglist: check
	pacman -Qqen > hosts/$(HOST)/pkglist.txt
	pacman -Qqem > hosts/$(HOST)/pkglist-aur.txt

# Show packages in the snapshot that are not installed (and vice versa)
pkgdiff: check
	@echo "--- in pkglist, not installed:"
	@comm -23 <(sort -u hosts/$(HOST)/pkglist*.txt) <(pacman -Qqe | sort -u) || true
	@echo "--- installed, not in pkglist:"
	@comm -13 <(sort -u hosts/$(HOST)/pkglist*.txt) <(pacman -Qqe | sort -u) || true
