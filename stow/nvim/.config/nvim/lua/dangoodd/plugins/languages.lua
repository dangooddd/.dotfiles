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
                },
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
        end,
    },

    -- python repl
    {
        "dangooddd/pyrepl.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            local pyrepl = require("pyrepl")
            pyrepl.setup()

            -- main commands
            vim.keymap.set("n", "<leader>jo", pyrepl.open_repl)
            vim.keymap.set("n", "<leader>jh", pyrepl.hide_repl)
            vim.keymap.set("n", "<leader>jc", pyrepl.close_repl)
            vim.keymap.set({ "n", "t" }, "<C-j>", pyrepl.toggle_repl_focus)
            vim.keymap.set("n", "<leader>ji", pyrepl.open_images)

            -- send commands
            vim.keymap.set("n", "<leader>jf", pyrepl.send_buffer)
            vim.keymap.set("n", "<leader>jb", pyrepl.send_block)
            vim.keymap.set("v", "<leader>jv", pyrepl.send_visual)

            -- utility commands
            vim.keymap.set("n", "<leader>jp", pyrepl.block_backward)
            vim.keymap.set("n", "<leader>jn", pyrepl.block_forward)
            vim.keymap.set("n", "<leader>je", pyrepl.export_notebook)
            vim.keymap.set("n", "<leader>js", function()
                pyrepl.install_packages("uv")
            end)
        end,
    },
}
