-- What each external screen does, picked per connector with `display` (SUPER+P)
-- or the bar: extend | mirror (copies the laptop screen) | off.
--
-- host.lua declares its screens with display.screen{...}: a normal hl.monitor spec
-- plus `label` (shown in the menus), and `internal = true` for the laptop screen,
-- which is always on and is what mirroring copies. Then display.apply().
-- The chosen modes live in ~/.local/state/display/modes ("<output> <mode>" lines).
-- `display set` writes that file and calls apply() through `hyprctl eval`.

local M = { screens = {} }
local applied = {} -- last mode sent per output, so unchanged rules aren't resent

local STATE = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")) .. "/display/modes"

local function saved_modes()
    local modes = {}
    local f = io.open(STATE)
    if f then
        for line in f:lines() do
            local name, mode = line:match("^(%S+)%s+(%S+)")
            if name then
                modes[name] = mode
            end
        end
        f:close()
    end
    return modes
end

local function mode_of(s, saved)
    if s.internal then
        return "on"
    end
    return saved[s.output] or "extend"
end

local function internal_output()
    for _, s in ipairs(M.screens) do
        if s.internal then
            return s.output
        end
    end
end

function M.apply()
    local saved = saved_modes()
    local mirror_of = internal_output()
    for _, s in ipairs(M.screens) do
        local mode = mode_of(s, saved)
        if applied[s.output] ~= mode then
            applied[s.output] = mode
            local spec = {}
            for k, v in pairs(s) do
                if k ~= "label" and k ~= "internal" then
                    spec[k] = v
                end
            end
            spec.disabled = (mode == "off")
            -- an empty mirror is what clears a mirror set earlier
            spec.mirror = (mode == "mirror" and mirror_of) or ""
            hl.monitor(spec)
        end
    end
end

-- Declare a screen (see the top of this file). Call apply() after the last one.
function M.screen(spec)
    spec.internal = spec.internal == true
    table.insert(M.screens, spec)
end

-- One line per external screen for the `display` script: output, label, mode
function M.list()
    local saved = saved_modes()
    local lines = {}
    for _, s in ipairs(M.screens) do
        if not s.internal then
            lines[#lines + 1] = table.concat({ s.output, s.label or s.output, mode_of(s, saved) }, "\t")
        end
    end
    return table.concat(lines, "\n")
end

return M
