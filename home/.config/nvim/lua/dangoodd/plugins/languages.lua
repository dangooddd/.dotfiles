return {
    -- treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        branch = "main",
        build = ":TSUpdate",
        config = function() end,
    },

    -- lua
    {
        "folke/lazydev.nvim",
        ft = "lua",
        config = function()
            require("lazydev").setup({
                library = {
                    {
                        path = "${3rd}/luv/library",
                        words = { "vim%.uv" },
                    },
                },
            })
        end,
    },

    -- rendering for html, latex, md
    {
        "OXY2DEV/markview.nvim",
        lazy = false,
        -- to load before treesitter
        priority = 45,
        config = function()
            require("markview").setup({
                markdown = {
                    code_blocks = { sign = false },
                },
            })
        end,
    },
}
