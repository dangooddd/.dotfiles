return {
    -- treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        branch = "main",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup()
            vim.api.nvim_create_autocmd('FileType', {
                pattern = "*",
                callback = function(event)
                    local ok, _ = pcall(vim.treesitter.start, event.buf)
                    if not ok then
                        local lang = vim.treesitter.language.get_lang(event.match)
                        require("nvim-treesitter").install(lang)
                    end
                end,
            })
        end,
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
