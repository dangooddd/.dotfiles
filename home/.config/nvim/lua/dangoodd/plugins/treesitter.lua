return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "bash",
                "c",
                "lua",
                "luadoc",
                "diff",
                "html",
                "markdown",
                "vim",
                "vimdoc",
                "query",
            },
            sync_install = false,
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            textobjects = {
                select = {
                    enable = true,
                    keymaps = {
                        ["if"] = "@function.inner",
                        ["af"] = "@function.outer",
                        ["ic"] = "@class.inner",
                        ["ac"] = "@class.outer",
                        ["ip"] = "@parameter.inner",
                        ["ap"] = "@parameter.outer",
                    },
                },
                swap = {
                    enable = true,
                    swap_next = {
                        ["<leader>s"] = "@parameter.inner",
                    },
                    swap_previous = {
                        ["<leader>S"] = "@parameter.inner",
                    }
                },
                move = {
                    enable = true,
                    goto_next_start = {
                        ["]p"] = "@parameter.inner",
                    },
                    goto_previous_start = {
                        ["[p"] = "@parameter.inner",
                    },
                }
            }
        })
    end,
}
