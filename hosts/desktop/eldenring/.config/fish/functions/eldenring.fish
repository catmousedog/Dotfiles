function eldenring --description 'Launch Elden Ring with a me3 profile (default: randomizer_solo)'
    set -l profile randomizer_solo
    set -q argv[1]; and set profile $argv[1]
    ~/.local/bin/me3 launch --game eldenring --profile ~/.config/me3/profiles/eldenring-$profile.me3
end
