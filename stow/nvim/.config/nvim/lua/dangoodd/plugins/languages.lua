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
                split_horizontal = false,
                split_ratio = 0.5,
                style = "gruvbox-dark",
                image_max_width_ratio = 0.4,
                image_max_height_ratio = 0.4,
            })

            vim.keymap.set("n", "<leader>js", function()
                pyrepl.send_statement()
            end, { noremap = true })

            vim.keymap.set("v", "<leader>jv", function()
                pyrepl.send_visual()
            end, { noremap = true })

            vim.keymap.set("n", "<leader>jb", function()
                pyrepl.send_buffer()
            end, { noremap = true })

            vim.keymap.set("n", "<leader>ji", function()
                pyrepl.open_images()
            end, { noremap = true })
        end,
    },
}
