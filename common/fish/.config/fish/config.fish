if status is-interactive
	set fish_greeting
end

# Load all scripts from local/
if test -d ~/.config/fish/local
    for f in ~/.config/fish/local/*.fish
        source $f
    end
end