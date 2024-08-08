local wezterm = require "wezterm"
local act = wezterm.action
local paneMod = "ALT"      -- fast pane moves
local mainMod = "CTRL|ALT" -- general mod

local keybinds = {
    keys = {
        -- general
        { key = "f", mods = mainMod, action = act.ActivateKeyTable { name = "FON", one_shot = false} },
        { key = "t", mods = mainMod, action = act.ActivateKeyTable { name = "TAB", one_shot = false} },
        { key = "v", mods = mainMod, action = act.PasteFrom "Clipboard" },
        { key = "c", mods = mainMod, action = act.CopyTo "ClipboardAndPrimarySelection" },
        -- panes
        { key = "e", mods = paneMod, action = act.ActivateKeyTable { name = "PAN", one_shot = false } },
        { key = "r", mods = paneMod, action = act.ActivateKeyTable { name = "RES", one_shot = false } },
        { key = "q", mods = paneMod, action = act.CloseCurrentPane { confirm = false } },
        { key = "h", mods = paneMod, action = act.ActivatePaneDirection "Left" },
        { key = "j", mods = paneMod, action = act.ActivatePaneDirection "Down" },
        { key = "k", mods = paneMod, action = act.ActivatePaneDirection "Up" },
        { key = "l", mods = paneMod, action = act.ActivatePaneDirection "Right" },
    },
    key_tables = {
        PAN = {
            -- open/close panes
            { key = "h", action = act.Multiple { act.SplitPane { direction = "Left" }, act.PopKeyTable } },
            { key = "j", action = act.Multiple { act.SplitPane { direction = "Down" }, act.PopKeyTable } },
            { key = "k", action = act.Multiple { act.SplitPane { direction = "Up" }, act.PopKeyTable } },
            { key = "l", action = act.Multiple { act.SplitPane { direction = "Right" }, act.PopKeyTable } },
            { key = "q", action = act.Multiple { act.CloseCurrentPane { confirm = false }, act.PopKeyTable } },
            -- exit
            { key = "Escape", action = act.PopKeyTable },
        },
        TAB = {
            -- open/close tabs
            { key = "q", action = act.Multiple { act.CloseCurrentTab { confirm = false }, act.PopKeyTable } },
            { key = "n", action = act.Multiple { act.SpawnTab "CurrentPaneDomain", act.PopKeyTable } },
            { key = "h", action = act.Multiple { act.ActivateTabRelative(-1), act.PopKeyTable } },
            { key = "l", action = act.Multiple { act.ActivateTabRelative(1), act.PopKeyTable } },
            -- exit
            { key = "Escape", action = act.PopKeyTable },
        },
        RES = {
            -- resize panes
            { key = "h", action = act.AdjustPaneSize { "Left", 5 } },
            { key = "j", action = act.AdjustPaneSize { "Down", 5 } },
            { key = "k", action = act.AdjustPaneSize { "Up", 5 } },
            { key = "l", action = act.AdjustPaneSize { "Right", 5 } },
            -- exit
            { key = "Escape", action = act.PopKeyTable },
        },
        FON = {
            -- resize font
            { key = "=", action = act.IncreaseFontSize },
            { key = "-", action = act.DecreaseFontSize },
            { key = "0", action = act.Multiple { act.ResetFontSize, act.PopKeyTable } },
            -- exit
            { key = "Escape", action = act.PopKeyTable },
        },
    },
}

-- tab movement
for i = 1, 10 do 
    table.insert(keybinds.key_tables.TAB, {
        key = tostring(i%10),
        action = act.Multiple { act.ActivateTab(i-1), act.PopKeyTable }
    })
end

return keybinds
