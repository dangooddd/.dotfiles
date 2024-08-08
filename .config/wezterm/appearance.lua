local wezterm = require "wezterm"

-- appearance options
local appearance = {
    use_fancy_tab_bar = true,
    color_scheme = "Kanagawa (Gogh)",
    font = wezterm.font "Cascadia Code",
    font_size = 16,
    default_cursor_style = "SteadyBlock",
    animation_fps = 60,
} 

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

-- tab bar theming
appearance.colors = {
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

appearance.window_frame = {
    active_titlebar_bg = colors.bg_dark,
    inactive_titlebar_bg = colors.bg_dark,

    active_titlebar_fg = colors.fg,
    inactive_titlebar_fg = colors.fg,
}

appearance.window_padding = {
    left = "1cell",
    right = "0.5cell",
    top = "0.5cell",
    bottom = "0.5cell",
}

appearance.inactive_pane_hsb = {
    saturation = 1.0,
    brightness = 0.8,
}

wezterm.on('update-status', function(window, pane)
    local name = window:active_key_table() or "NOR"

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
        { Text = " -- " .. name .. " -- "},
        { Background = { Color = colors.bg_dark } },
        { Text = "    "}
    })
end)

return appearance
