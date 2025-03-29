return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "ellisonleao/gruvbox.nvim",
    },
    config = function()
        -- custom lualine theme with gruvbox colors
        local function gruvbox_custom()
            local palette = require("gruvbox").palette

            local function accent_status(accent)
                return {
                    a = { bg = accent, fg = palette.dark0_hard },
                    b = { bg = palette.dark1, fg = accent },
                    c = { bg = palette.dark0, fg = palette.light1 }
                }
            end

            return {
                normal = accent_status(palette.bright_green),
                insert = accent_status(palette.bright_yellow),
                visual = accent_status(palette.bright_purple),
                replace = accent_status(palette.bright_orange),
                command = accent_status(palette.bright_red),
                inactive = {
                    a = { bg = palette.dark1, fg = palette.light4 },
                    b = { bg = palette.dark1, fg = palette.light4 },
                    c = { bg = palette.dark1, fg = palette.light4 },
                }
            }
        end

        require("lualine").setup({
            options = {
                theme = gruvbox_custom(),
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                globalstatus = true,
                refresh = {
                    statusline = 50,
                    tabline = 50,
                    winbar = 50,
                },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diagnostics" },
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

        vim.api.nvim_create_autocmd("ColorScheme", {
            pattern = "gruvbox*",
            callback = function()
                require("lualine").setup({
                    options = { theme = gruvbox_custom() },
                })
            end,
        })
    end,
}
