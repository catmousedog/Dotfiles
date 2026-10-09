function lt --description 'Tree view, two levels deep by default: lt [depth] [path...]'
    set -l depth 2
    if string match -qr '^\d+$' -- "$argv[1]"
        set depth $argv[1]
        set -e argv[1]
    end
    eza --tree --all --level=$depth --group-directories-first --icons=auto --ignore-glob=.git $argv
end
