-- While streaming to the laptop, ~/.local/bin/stream leaves a state file here:
-- the name of the virtual monitor it created and the mode Moonlight asked for.
local streamOutput, streamMode
local stream = io.open((os.getenv("XDG_RUNTIME_DIR") or "") .. "/stream")
if stream then
    streamOutput, streamMode = stream:read("*l", "*l")
    stream:close()
end

if streamOutput and streamMode then
    -- the virtual monitor takes over and the OLED goes dark
    hl.monitor({ output = "DP-2", disabled = true })
    hl.monitor({
        output = streamOutput,
        mode = streamMode,
        position = "0x0",
        scale = 1,
    })
else
    -- ultrawide screen
    hl.monitor({
        output = "DP-2",
        mode = "3440x1440@174.962006",
        position = "0x0",
        scale = 1,
    })
end

-- Back to the real monitor, for when a stream didn't end cleanly
hl.bind("SUPER + SHIFT + O", hl.dsp.exec_cmd("~/.local/bin/stream stop"))

-- US, RU keyboards
hl.config({
    input = {
        kb_layout = "us,ru",
        kb_variant = ",phonetic_YAZHERTY",
        kb_options = "grp:win_space_toggle",
        sensitivity = -0.8,
    },
})
