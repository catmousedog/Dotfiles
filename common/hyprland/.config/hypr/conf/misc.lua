-- Ignore maximize requests from apps
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

-- The screenshot overlay shows a frozen copy of the screen: always fade it, whatever
-- the layers animation is set to, so only the dim is seen coming in
hl.layer_rule({
    name = "screenshot-fade",
    match = { namespace = "screenshot" },
    animation = "fade",
})
