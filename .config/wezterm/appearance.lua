local wezterm = require "wezterm"

-- colors for tab bar theming
local colors = {
    bg = "#1F1F28",
    fg = "#DCD7BA",
    bg_dark = "#131319",
    fg_bright = "#E6C384",
    blue = "#7E9CD8",
    dark = "#16161D",
    red = "#C34043",
    yellow = "#E6C384",
    magenta = "#957FB8",
    green = "#76946A",
}

-- status line main function
function status(window, pane)
    -- mode name
    local name = window:active_key_table() or "NOR"

    -- fg color
    local color
    if (name == "NOR") then
        color = colors.blue
    elseif (name == "PAN") then
        color = colors.magenta
    elseif (name == "TAB") then
        color = colors.yellow
    elseif (name == "RES") then
        color = colors.red
    elseif (name == "FON") then
        color = colors.green
    else
        color = colors.blue
    end

    window:set_right_status(wezterm.format {
        { Foreground = { Color = color } },
        { Background = { Color = colors.bg_dark } },
        { Text = "  -- " .. name .. " --  "},
    })
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


    -- tab bar theming
    config.colors = {
        tab_bar = {
            active_tab = {
                bg_color = colors.bg,
                fg_color = colors.fg_bright,
            },
        
            inactive_tab = {
                bg_color = colors.bg_dark,
                fg_color = colors.fg,
            },

            inactive_tab_hover = {
                bg_color = colors.bg,
                fg_color = colors.fg,
            },

            new_tab = {
                bg_color = colors.bg_dark,
                fg_color = colors.fg,
            },

            new_tab_hover = {
                bg_color = colors.bg,
                fg_color = colors.fg_bright,
            },
        }
    }

    config.window_frame = {
        active_titlebar_bg = colors.bg_dark,
        inactive_titlebar_bg = colors.bg_dark,

        active_titlebar_fg = colors.fg,
        inactive_titlebar_fg = colors.fg,

        font = wezterm.font { family = "Inter", weight = "Medium" },
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
end

return M
