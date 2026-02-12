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

    -- markdown
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("render-markdown").setup({
                completions = { lsp = { enabled = true } },
            })
        end
    },

    -- python repl
    {
        "dangooddd/pyrepl.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            local pyrepl = require("pyrepl")

            pyrepl.setup({
                style = "gruvbox-dark",
            })

            vim.keymap.set("n", "<leader>jo", ":PyreplOpen<CR>", { silent = true })
            vim.keymap.set("n", "<leader>jh", ":PyreplHide<CR>", { silent = true })
            vim.keymap.set("n", "<leader>jc", ":PyreplClose<CR>", { silent = true })
            vim.keymap.set("v", "<leader>jv", ":<C-u>PyreplSendVisual<CR>gv<Esc>", { silent = true })
            vim.keymap.set("n", "<leader>jf", ":PyreplSendBuffer<CR>", { silent = true })
            vim.keymap.set("n", "<leader>jb", ":PyreplSendBlock<CR>", { silent = true })
            vim.keymap.set("n", "<leader>jp", ":PyreplBlockBackward<CR>", { silent = true })
            vim.keymap.set("n", "<leader>jn", ":PyreplBlockForward<CR>", { silent = true })
            vim.keymap.set("n", "<leader>ji", ":PyreplOpenImages<CR>", { silent = true })
            vim.keymap.set("n", "<leader>js", ":PyreplInstall")
        end,
    },
}
