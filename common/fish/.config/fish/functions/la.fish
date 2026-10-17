function la --wraps eza --description 'Long listing with git status'
    eza -la --group-directories-first --icons=auto --git --time-style=relative $argv
end
