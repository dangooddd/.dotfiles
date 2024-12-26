return {
    "nvim-lualine/lualine.nvim",
    dependencies = { 
        "nvim-tree/nvim-web-devicons",
        "rebelot/kanagawa.nvim",
    },
    config = function()
        local kanagawa = require("lualine.themes.kanagawa")
        local theme = require("kanagawa.colors").setup().theme
        local palette = require("kanagawa.colors").setup().palette

        local function accent_status(accent)
            return {
                a = { bg = accent, fg = theme.ui.bg },
                b = { bg = theme.ui.bg_p1, fg = accent },
                c = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
            }
        end

        kanagawa.normal = accent_status(palette.springGreen)
        kanagawa.insert = accent_status(palette.carpYellow)
        kanagawa.visual = accent_status(palette.oniViolet)
        kanagawa.replace = accent_status(palette.surimiOrange)
        kanagawa.command = accent_status(palette.peachRed)
        kanagawa.inactive = {
            a = { bg = theme.ui.bg_m3, fg = theme.ui.nontext },
            b = { bg = theme.ui.bg_m3, fg = theme.ui.nontext },
            c = { bg = theme.ui.bg_m3, fg = theme.ui.nontext },
        }

        require("lualine").setup({
            options = {
                theme = kanagawa,
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                globalstatus = true
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = { "filename" },
                lualine_x = { "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" }
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { "filename" },
                lualine_x = { "progress", "location" },
                lualine_y = {},
                lualine_z = {}
            }
        })
    end
}
