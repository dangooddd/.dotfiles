return {
    -- default lsp configs
    {
        "neovim/nvim-lspconfig",
        config = function() end,
    },

    -- manager
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup({
                ui = {
                    backdrop = 100,
                },
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

    -- python repl
    {
        "dangooddd/pyrepl.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        build = ":UpdateRemotePlugins",
        config = function()
            local pyrepl = require("pyrepl")

            pyrepl.setup({
                style = "gruvbox-dark",
                filetypes = { "python", "markdown" }
            })

            vim.keymap.set("n", "<leader>jo", ":PyreplOpen<CR>", { silent = true })
            vim.keymap.set("n", "<leader>jh", ":PyreplHide<CR>", { silent = true })
            vim.keymap.set("n", "<leader>jc", ":PyreplClose<CR>", { silent = true })
            vim.keymap.set("n", "<leader>jf", ":PyreplSendBuffer<CR>", { silent = true })
            vim.keymap.set("n", "<leader>jb", ":PyreplSendBlock<CR>", { silent = true })
            vim.keymap.set("v", "<leader>jv", ":<C-u>PyreplSendVisual<CR>gv<Esc>", { silent = true })
            vim.keymap.set("n", "<leader>ji", ":PyreplOpenImages<CR>", { silent = true })
        end,
    },
}
