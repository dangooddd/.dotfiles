return {
    -- treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        branch = "main",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup()

            local langs = {}
            for _, value in ipairs(require("nvim-treesitter").get_available()) do
                langs[value] = true
            end

            vim.api.nvim_create_autocmd('FileType', {
                pattern = "*",
                callback = function(event)
                    local ok, _ = pcall(vim.treesitter.start, event.buf)
                    if not ok then
                        local lang = vim.treesitter.language.get_lang(event.match)
                        if langs[lang] then
                            require("nvim-treesitter").install(lang)
                        end
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

    -- typst
    {
        "chomosuke/typst-preview.nvim",
        ft = "typst",
        version = "1.*",
        config = function()
            require("typst-preview").setup({
                dependencies_bin = {
                    ["tinymist"] = vim.fn.exepath("tinymist"),
                }
            })
        end,
    },

    -- {
    --     "OXY2DEV/markview.nvim",
    --     lazy = false,
    -- },
}
