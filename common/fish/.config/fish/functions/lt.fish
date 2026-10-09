function lt -a depth
    if not set -q depth[1]
		set depth 2
	end
    tree -aCL $depth
end