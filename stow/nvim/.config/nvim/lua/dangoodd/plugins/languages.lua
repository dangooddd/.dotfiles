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

    {
        "dangooddd/pyrola.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        build = ":UpdateRemotePlugins",
        config = function()
            local pyrola = require("pyrola")

            pyrola.setup({
                kernel_map = {
                    python = "python"
                },
                split_horizontal = false,
                split_ratio = 0.5,
            })

            vim.keymap.set("n", "<leader>js", function()
                pyrola.send_statement_definition()
            end, { noremap = true })

            vim.keymap.set("v", "<leader>jv", function()
                pyrola.send_visual_to_repl()
            end, { noremap = true })

            vim.keymap.set("n", "<leader>jb", function()
                pyrola.send_buffer_to_repl()
            end, { noremap = true })

            vim.keymap.set("n", "<leader>ji", function()
                pyrola.inspect()
            end, { noremap = true })

            vim.keymap.set("n", "<leader>jh", function()
                pyrola.open_history_manager()
            end, { noremap = true })
        end,
    },
}
