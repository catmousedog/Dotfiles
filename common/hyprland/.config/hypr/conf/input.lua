-- https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
    input = {
        kb_layout = "be,us",
        follow_mouse = 1,
        sensitivity = 0.5, -- -1.0 to 1.0, 0 means no modification
        numlock_by_default = false,
        -- binds follow the active layout, so SUPER+W is the key that types w,
        -- not wherever w sits on the first layout (AZERTY vs QWERTY keyboards)
        resolve_binds_by_sym = true,
        touchpad = {
            natural_scroll = true,
        },
        repeat_rate = 40,
        repeat_delay = 200,
    },
})

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
-- Three finger swipes move through the watrix grid. Content follows the fingers
-- like natural scrolling: swiping left brings in the workspace on the right.
local swipes = { left = "right", right = "left", up = "down", down = "up" }
for swipe, dir in pairs(swipes) do
    hl.gesture({
        fingers = 3,
        direction = swipe,
        action = function()
            hl.exec_cmd("~/.config/hypr/scripts/watrix.fish workspace " .. dir)
        end,
    })
end
