-- What each external screen does, picked per connector with `display` (SUPER+P)
-- or the bar: extend | mirror (copies the laptop screen) | off.
--
-- host.lua declares its screens with display.screen{...}: a normal hl.monitor spec
-- plus `label` (shown in the menus), and `internal = true` for the laptop screen,
-- which is always on and is what mirroring copies. Then display.apply().
-- The chosen modes live in ~/.local/state/display/modes ("<output> <mode>" lines).
-- `display set` writes that file and calls apply() through `hyprctl eval`.
--
-- Per-screen settings (`display settings`, SUPER+SHIFT+P) live next to it in
-- ~/.local/state/display/settings ("<output> <key> <value>" lines), on top of
-- the host.lua spec. Only `hdr on|off` for now.

local M = { screens = {} }
local applied = {} -- last mode sent per output, so unchanged rules aren't resent

local STATE_DIR = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")) .. "/display"
local STATE = STATE_DIR .. "/modes"
local SETTINGS = STATE_DIR .. "/settings"

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

-- { [output] = { [key] = value } }
local function saved_settings()
    local settings = {}
    local f = io.open(SETTINGS)
    if f then
        for line in f:lines() do
            local name, key, value = line:match("^(%S+)%s+(%S+)%s+(%S+)")
            if name then
                settings[name] = settings[name] or {}
                settings[name][key] = value
            end
        end
        f:close()
    end
    return settings
end

-- The settings on top of a host.lua spec
local function tweak(spec, settings)
    if settings.hdr == "on" then
        spec.cm = "hdr"
        spec.bitdepth = 10
    else
        -- a rule without cm keeps the old one, so turning HDR off needs it spelled out
        spec.cm = spec.cm or "srgb"
    end
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
    local settings = saved_settings()
    local mirror_of = internal_output()
    for _, s in ipairs(M.screens) do
        local mode = mode_of(s, saved)
        local own = settings[s.output] or {}
        local keys = {}
        for k, v in pairs(own) do
            keys[#keys + 1] = k .. "=" .. v
        end
        table.sort(keys)
        local key = mode .. " " .. table.concat(keys, " ")
        if applied[s.output] ~= key then
            applied[s.output] = key
            local spec = {}
            for k, v in pairs(s) do
                if k ~= "label" and k ~= "internal" then
                    spec[k] = v
                end
            end
            spec.disabled = (mode == "off")
            -- an empty mirror is what clears a mirror set earlier
            spec.mirror = (mode == "mirror" and mirror_of) or ""
            tweak(spec, own)
            hl.monitor(spec)
        end
    end
end

-- Declare a screen (see the top of this file). Call apply() after the last one.
function M.screen(spec)
    spec.internal = spec.internal == true
    table.insert(M.screens, spec)
end

-- One line per screen for the `display` script: output, label, mode, internal
function M.list()
    local saved = saved_modes()
    local lines = {}
    for _, s in ipairs(M.screens) do
        lines[#lines + 1] = table.concat(
            { s.output, s.label or s.output, mode_of(s, saved), tostring(s.internal) }, "\t")
    end
    return table.concat(lines, "\n")
end

return M
