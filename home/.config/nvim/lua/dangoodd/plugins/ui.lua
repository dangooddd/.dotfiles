return {
    -- statusline
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "rebelot/kanagawa.nvim",
        },
        config = function()
            -- custom lualine theme with kanagawa colors
            local function kanagawa_custom()
                local kanagawa = require("lualine.themes.kanagawa")
                local theme = require("kanagawa.colors").setup().theme

                local function accent_status(accent)
                    return {
                        a = { bg = accent, fg = theme.ui.bg },
                        b = { bg = theme.ui.bg_p1, fg = accent },
                        c = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim }
                    }
                end

                kanagawa.normal = accent_status(theme.term[11])
                kanagawa.insert = accent_status(theme.term[12])
                kanagawa.visual = accent_status(theme.term[14])
                kanagawa.replace = accent_status(theme.term[17])
                kanagawa.command = accent_status(theme.term[10])
                kanagawa.inactive = {
                    a = { bg = theme.ui.bg_m3, fg = theme.ui.nontext },
                    b = { bg = theme.ui.bg_m3, fg = theme.ui.nontext },
                    c = { bg = theme.ui.bg_m3, fg = theme.ui.nontext }
                }

                return kanagawa
            end

            require("lualine").setup({
                options = {
                    theme = kanagawa_custom(),
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

            -- update colorscheme when it changes to light/dark
            vim.api.nvim_create_autocmd("ColorScheme", {
                pattern = "kanagawa*",
                callback = function()
                    require("lualine").setup({
                        options = { theme = kanagawa_custom() },
                    })
                end,
            })
        end,
    },

    -- vim.notify and lsp progress
    {
        "j-hui/fidget.nvim",
        config = function()
            require("fidget").setup({
                progress = {
                    display = { done_ttl = 1 },
                    ignore = {
                        "lua_ls",
                        function(msg)
                            if msg.lsp_client.name == "rust_analyzer" and
                                string.find(msg.title, "cargo check")
                            then
                                return true
                            end
                        end,
                    }
                },
                notification = {
                    override_vim_notify = true,
                    window = {
                        winblend = 0,
                    },
                },
            })

            require("fidget.notification").set_config("default", { icon = "<" }, true)
        end
    },
}
