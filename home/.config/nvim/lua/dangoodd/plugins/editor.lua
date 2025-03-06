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

            -- add new rules
            local pairs = require("nvim-autopairs")
            local rule = require('nvim-autopairs.rule')
            local cond = require('nvim-autopairs.conds')
            pairs.add_rules({
                rule("$", "$", { "tex", "latex", "plaintex" })
                -- do not move right when repeat character
                    :with_move(cond.none())
            })
        end,
    },

    -- indent guides
    {
        "echasnovski/mini.indentscope",
        event = "VeryLazy",
        config = function()
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

            -- disable for certain filetypes
            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = "*",
                callback = function(args)
                    if vim.bo[args.buf].buftype ~= "" then
                        vim.b[args.buf].miniindentscope_disable = true
                    end
                end,
            })
        end,
    },

    -- textobjects
    {
        "echasnovski/mini.ai",
        version = "*",
        config = function()
            require("mini.ai").setup({
                silent = true,
            })
        end
    },
}
