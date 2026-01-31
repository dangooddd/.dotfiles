return {
    -- surround actions
    {
        "kylechui/nvim-surround",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup()
        end,
    },

    -- auto pairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup()

            local pairs = require("nvim-autopairs")
            local rule = require('nvim-autopairs.rule')
            local cond = require('nvim-autopairs.conds')

            pairs.add_rules({
                rule("$", "$", { "tex", "latex", "plaintex" })
                    :with_move(cond.none())
            })
        end,
    },

    -- mini
    {
        "nvim-mini/mini.nvim",
        version = "*",
        config = function()
            -- icons
            require("mini.icons").setup()

            -- textobjects
            require("mini.ai").setup({
                n_lines = 25,
            })

            -- statusline
            require("mini.statusline").setup({
                content = {
                    active = function()
                        local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 100 })
                        local git           = MiniStatusline.section_git({ trunc_width = 40 })
                        local diagnostics   = MiniStatusline.section_diagnostics({ trunc_width = 75 })
                        local lsp           = MiniStatusline.section_lsp({ trunc_width = 75 })
                        local filename      = MiniStatusline.section_filename({ trunc_width = 140 })
                        local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
                        local location      = MiniStatusline.section_location({ trunc_width = 75 })
                        local search        = MiniStatusline.section_searchcount({ trunc_width = 75 })

                        return MiniStatusline.combine_groups({
                            { hl = mode_hl,                 strings = { mode:upper() } },
                            { hl = "MiniStatuslineDevinfo", strings = { git, diagnostics, lsp } },
                            "%<",
                            { hl = "MiniStatuslineFilename", strings = { filename } },
                            "%=",
                            { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
                            { hl = mode_hl,                  strings = { search, location } },
                        })
                    end,
                    inactive = function()
                        local filename = MiniStatusline.section_filename({ trunc_width = 140 })

                        return MiniStatusline.combine_groups({
                            { hl = "MiniStatuslineFilename", strings = { filename } },
                        })
                    end
                },
            })
        end
    }
}
