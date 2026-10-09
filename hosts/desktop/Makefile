# Variables
STOW_PKGS := eldenring
SYS_STOW_PKGS := 

.PHONY: all install user system clean

# Stow to $HOME and root
user:
	stow --target=$(HOME) --restow $(STOW_PKGS)

system:
	sudo stow --target=/ --restow $(SYS_STOW_PKGS)

user-delete:
	stow --target=$(HOME) $(STOW_PKGS) -D

system-delete:
	sudo stow --target=/ $(SYS_STOW_PKGS) -D

# Unstow everything
clean:
	stow --target=$(HOME) -D $(STOW_PKGS)
	sudo stow --target=/ -D $(SYS_STOW_PKGS)
