local wezterm = require "wezterm"
local act = wezterm.action
local mainMod = "ALT"        -- main key mod
local hardMod = "CTRL|SHIFT" -- secondary key mod

local M = {}
function M.merge(config)
    config.keys = {
        -- hard
        { key = "j", mods = hardMod, action = act.ScrollByLine(1) },
        { key = "k", mods = hardMod, action = act.ScrollByLine(-1) },
        { key = "f", mods = hardMod, action = act.ActivateKeyTable { name = "FONT", one_shot = false} },
        { key = "v", mods = hardMod, action = act.PasteFrom "Clipboard" },
        { key = "c", mods = hardMod, action = act.CopyTo "ClipboardAndPrimarySelection" },
        { key = "l", mods = hardMod, action = act.ShowLauncherArgs { flags = "WORKSPACES" } },
        -- main
        { key = "e", mods = mainMod, action = act.ActivateKeyTable { name = "PANE", one_shot = false } },
        { key = "r", mods = mainMod, action = act.ActivateKeyTable { name = "RESIZE", one_shot = false } },
        { key = "t", mods = mainMod, action = act.ActivateKeyTable { name = "TAB", one_shot = false} },
        { key = "q", mods = mainMod, action = act.CloseCurrentPane { confirm = false } },
        { key = "h", mods = mainMod, action = act.ActivatePaneDirection "Left" },
        { key = "j", mods = mainMod, action = act.ActivatePaneDirection "Down" },
        { key = "k", mods = mainMod, action = act.ActivatePaneDirection "Up" },
        { key = "l", mods = mainMod, action = act.ActivatePaneDirection "Right" },
    }

    config.key_tables = {
        PANE = {
            -- open/close panes
            { key = "h", action = act.Multiple { act.SplitPane { direction = "Left" }, act.PopKeyTable } },
            { key = "j", action = act.Multiple { act.SplitPane { direction = "Down" }, act.PopKeyTable } },
            { key = "k", action = act.Multiple { act.SplitPane { direction = "Up" }, act.PopKeyTable } },
            { key = "l", action = act.Multiple { act.SplitPane { direction = "Right" }, act.PopKeyTable } },
            { key = "q", action = act.Multiple { act.CloseCurrentPane { confirm = false }, act.PopKeyTable } },
            -- exit
            { key = "e", mods = paneMod, action = act.PopKeyTable },
            { key = "Escape", action = act.PopKeyTable },
        },
        TAB = {
            -- open/close tabs
            { key = "q", action = act.Multiple { act.CloseCurrentTab { confirm = false }, act.PopKeyTable } },
            { key = "n", action = act.Multiple { act.SpawnTab "CurrentPaneDomain", act.PopKeyTable } },
            { key = "h", action = act.Multiple { act.ActivateTabRelative(-1), act.PopKeyTable } },
            { key = "l", action = act.Multiple { act.ActivateTabRelative(1), act.PopKeyTable } },
            -- exit
            { key = "t", mods = mainMod, action = act.PopKeyTable },
            { key = "Escape", action = act.PopKeyTable },
        },
        RESIZE = {
            -- resize panes
            { key = "h", action = act.AdjustPaneSize { "Left", 5 } },
            { key = "j", action = act.AdjustPaneSize { "Down", 5 } },
            { key = "k", action = act.AdjustPaneSize { "Up", 5 } },
            { key = "l", action = act.AdjustPaneSize { "Right", 5 } },
            -- exit
            { key = "r", mods = paneMod, action = act.PopKeyTable },
            { key = "Escape", action = act.PopKeyTable },
        },
        FONT = {
            -- resize font
            { key = "=", action = act.IncreaseFontSize },
            { key = "-", action = act.DecreaseFontSize },
            { key = "0", action = act.Multiple { act.ResetFontSize, act.PopKeyTable } },
            -- exit
            { key = "f", mods = mainMod, action = act.PopKeyTable },
            { key = "Escape", action = act.PopKeyTable },
        },
    }

    -- tab movement
    for i = 1, 10 do 
        table.insert(config.keys, {
            key = tostring(i%10),
            mods = mainMod,
            action = act.Multiple { act.ActivateTab(i-1), act.PopKeyTable }
        })
    end

    config.mouse_bindings = {
        -- wheel
        {
            event = { Down = { streak = 1, button = { WheelUp = 1 } } },
            mods = 'NONE',
            action = act.ScrollByLine(-2),
        },
        {
            event = { Down = { streak = 1, button = { WheelDown = 1 } } },
            mods = 'NONE',
            action = act.ScrollByLine(2),
        },
    }
end

return M
