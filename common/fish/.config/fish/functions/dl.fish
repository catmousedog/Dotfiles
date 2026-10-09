function dl --wraps eza --description 'Disk usage of everything here, biggest last (follows symlinks)'
    eza -lA --total-size --dereference --sort=size --no-permissions --no-user --no-time --icons=auto $argv
end
