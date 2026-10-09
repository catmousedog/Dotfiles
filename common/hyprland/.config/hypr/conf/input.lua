-- https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
    input = {
        kb_layout = "be,us",
        follow_mouse = 1,
        sensitivity = 0.5, -- -1.0 to 1.0, 0 means no modification
        numlock_by_default = false,
        touchpad = {
            natural_scroll = true,
        },
        repeat_rate = 30,
        repeat_delay = 300,
    },
})

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
