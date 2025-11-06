return {
    "echasnovski/mini.nvim",
    version = "*",
    config = function()
        -- textobjects
        require("mini.ai").setup({
            n_lines = 25,
        })

        -- git integration
        require("mini.git").setup()

        -- icons
        require("mini.icons").setup()

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
                        { hl = mode_hl,                 strings = { mode } },
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

        -- indentscope
        require("mini.indentscope").setup({
            draw = {
                delay = 50,
                animation = require("mini.indentscope").gen_animation.linear({
                    ease = "out",
                    duration = 15,
                })
            },
            options = {
                border = "top",
                try_as_border = true,
                indent_at_cursor = false,
            },
        })

        -- disable indentscope for certain filetypes
        vim.api.nvim_create_autocmd("BufEnter", {
            pattern = "*",
            callback = function(args)
                if vim.bo[args.buf].buftype ~= "" then
                    vim.b[args.buf].miniindentscope_disable = true
                end
            end,
        })
    end
}
