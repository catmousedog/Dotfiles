function la --wraps eza --description 'Long listing with git status'
    eza -l --group-directories-first --icons=auto --git --time-style=relative $argv
end
