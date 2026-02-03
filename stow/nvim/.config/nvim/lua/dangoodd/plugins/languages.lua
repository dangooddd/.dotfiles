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
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "3rd/image.nvim",
        },
        build = ":UpdateRemotePlugins",
        config = function()
            local pyrepl = require("pyrepl")

            pyrepl.setup({
                style = "gruvbox-dark",
            })

            vim.keymap.set("n", "<leader>jo", ":PyREPLOpen<CR>", { silent = true })
            vim.keymap.set("n", "<leader>jh", ":PyREPLHide<CR>", { silent = true })
            vim.keymap.set("n", "<leader>jc", ":PyREPLClose<CR>", { silent = true })
            vim.keymap.set("n", "<leader>js", ":PyREPLSendStatement<CR>", { silent = true })
            vim.keymap.set("n", "<leader>jb", ":PyREPLSendBuffer<CR>", { silent = true })
            vim.keymap.set("v", "<leader>jv", ":<C-u>PyREPLSendVisual<CR>gv", { silent = true })
            vim.keymap.set("n", "<leader>ji", ":PyREPLOpenImages<CR>", { silent = true })
        end,
    },
}
