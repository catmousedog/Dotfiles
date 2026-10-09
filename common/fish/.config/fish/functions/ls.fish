function ls --wraps eza --description 'List files with eza'
    eza --group-directories-first --icons=auto $argv
end
