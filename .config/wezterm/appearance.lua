local wezterm = require "wezterm"

-- colors for tab bar theming
-- in accordance with helix kanagawa theme
local colors = {
    oniViolet = "#957FB8",
    carpYellow = "#E6C384",
    springGreen = "#98BB6C",
    crystalBlue = "#7E9CD8",
    waveAqua2 = "#7AA89F",
    springGreen = "#98BB6C",
    oldWhite = "#C8C093",
    sumiInk0 = "#16161D",
    sumiInk1 = "#1F1F28",
    sumiInk2 = "#2A2A37",
}

-- status line main function
function status(window, pane)
    -- mode name
    local name = window:active_key_table() or "NOR"

    -- fg color
    local color
    if (name == "NOR") then
        color = colors.crystalBlue
    elseif (name == "PAN") then
        color = colors.oniViolet
    elseif (name == "TAB") then
        color = colors.carpYellow
    elseif (name == "RES") then
        color = colors.waveAqua2
    elseif (name == "FON") then
        color = colors.springGreen
    else
        color = colors.crystalBlue
    end

    window:set_right_status(wezterm.format {
        { Foreground = { Color = color } },
        { Background = { Color = colors.sumiInk0 } },
        { Text = "  -- " .. name .. " --  "},
    })
end

-- get title from tab
function tab_title(tab)
    local title = tab.tab_title
    if title and #title > 0 then
        return title
    end
    return tab.active_pane.title
end

-- truncate long tab names
function tab_style(tab, tabs, panes, config, hover, max_width) 
    local title = tab_title(tab)
    local lenght = 20
    if (string.len(title) > lenght) then
        title = wezterm.truncate_right(title, lenght - 3) .. "..."
    end
    return title
end

local M = {}
function M.merge(config)
    -- appearance options
    config.use_fancy_tab_bar = true
    config.color_scheme = "Kanagawa (Gogh)"
    config.font = wezterm.font "Cascadia Code"
    config.font_size = 16
    config.default_cursor_style = "SteadyBlock"
    config.animation_fps = 60
    config.show_tab_index_in_tab_bar = false


    -- tab bar theming
    config.colors = {
        tab_bar = {
            active_tab = {
                fg_color = colors.waveAqua2,
                bg_color = colors.sumiInk2,
            },
        
            inactive_tab = {
                bg_color = colors.sumiInk0,
                fg_color = colors.oldWhite,
            },

            inactive_tab_hover = {
                bg_color = colors.sumiInk1,
                fg_color = colors.oldWhite,
            },

            new_tab = {
                bg_color = colors.sumiInk0,
                fg_color = colors.oldWhite,
            },

            new_tab_hover = {
                bg_color = colors.sumiInk2,
                fg_color = colors.waveAqua2,
            },
        }
    }

    config.window_frame = {
        active_titlebar_bg = colors.sumiInk0,
        inactive_titlebar_bg = colors.sumiInk0,

        active_titlebar_fg = colors.oldWhite,
        inactive_titlebar_fg = colors.oldWhite,

        font = wezterm.font { family = "Roboto", weight = "Bold" },
        font_size = 13,
    }

    -- window theming
    config.window_padding = {
        left = "1cell",
        right = "0.5cell",
        top = "0.5cell",
        bottom = "0.5cell",
    }

    config.inactive_pane_hsb = {
        saturation = 1.0,
        brightness = 0.8,
    }

    wezterm.on('update-status', status)
    wezterm.on('format-tab-title', tab_style)
end

return M
