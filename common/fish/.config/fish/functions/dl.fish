function dl --description 'Display disk usage with symlink dereferencing'
    for item in *
        if test -L "$item"
            set_color cyan --bold
            # -h for human readable, -s for summary, -L to follow the link
            du -shL "$item" 2>/dev/null
        else if test -d "$item"
            set_color blue --bold
            du -sh "$item" 2>/dev/null
        else if test -x "$item"
            set_color green --bold
            du -sh "$item" 2>/dev/null
        else
            set_color normal
            du -sh "$item" 2>/dev/null
        end
    end
    set_color normal
end
